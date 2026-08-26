package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"net/url"
	"os"
	"path/filepath"
	"sort"
	"strings"

	_ "modernc.org/sqlite"
)

type Part struct {
	Type   string
	Text   string
	Tool   string
	Input  string
	Output string
}

type Message struct {
	ID    string
	Role  string
	Time  int64
	Parts []*Part
}

type Session struct {
	ID       string
	Slug     string
	Dir      string
	Title    string
	ParentID string
	Created  int64
	Updated  int64
	db       *sql.DB
	msgs     []*Message
}

type Store struct {
	sessions []*Session
}

func defaultDBPaths() ([]string, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return nil, err
	}
	matches, err := filepath.Glob(filepath.Join(home, ".local", "share", "opencode", "*.db"))
	if err != nil {
		return nil, err
	}
	return matches, nil
}

func openRO(path string) (*sql.DB, error) {
	u := url.URL{Scheme: "file", Path: path}
	q := url.Values{}
	q.Add("mode", "ro")
	q.Add("_pragma", "busy_timeout(5000)")
	u.RawQuery = q.Encode()
	db, err := sql.Open("sqlite", u.String())
	if err != nil {
		return nil, err
	}
	var n int
	err = db.QueryRow(
		`SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name IN ('session','message','part')`,
	).Scan(&n)
	if err != nil {
		db.Close()
		return nil, err
	}
	if n < 3 {
		db.Close()
		return nil, fmt.Errorf("not an opencode session db")
	}
	return db, nil
}

func OpenStore(explicit []string) (*Store, error) {
	paths := explicit
	if len(paths) == 0 {
		var err error
		paths, err = defaultDBPaths()
		if err != nil {
			return nil, err
		}
	}
	if len(paths) == 0 {
		return nil, fmt.Errorf("no opencode databases found")
	}
	s := &Store{}
	for _, p := range paths {
		p = expandHome(p)
		db, err := openRO(p)
		if err != nil {
			fmt.Fprintf(os.Stderr, "recall: skipping %s: %v\n", p, err)
			continue
		}
		if err := s.loadSessions(db); err != nil {
			fmt.Fprintf(os.Stderr, "recall: skipping %s: %v\n", p, err)
			db.Close()
			continue
		}
	}
	if len(s.sessions) == 0 {
		return nil, fmt.Errorf("no readable sessions in %d database(s)", len(paths))
	}
	sort.Slice(s.sessions, func(i, j int) bool { return s.sessions[i].Updated > s.sessions[j].Updated })
	return s, nil
}

func (s *Store) loadSessions(db *sql.DB) error {
	rows, err := db.Query(`SELECT id, slug, directory, title, parent_id, time_created, time_updated FROM session`)
	if err != nil {
		return err
	}
	defer rows.Close()
	for rows.Next() {
		var (
			sess     Session
			parentID sql.NullString
		)
		if err := rows.Scan(&sess.ID, &sess.Slug, &sess.Dir, &sess.Title, &parentID, &sess.Created, &sess.Updated); err != nil {
			return err
		}
		sess.ParentID = parentID.String
		sess.db = db
		s.sessions = append(s.sessions, &sess)
	}
	return rows.Err()
}

func (s *Store) Close() {
	seen := map[*sql.DB]bool{}
	for _, sess := range s.sessions {
		if sess.db != nil && !seen[sess.db] {
			seen[sess.db] = true
			sess.db.Close()
		}
	}
}

// Resolve matches a full session id, a unique id prefix (min 4 chars), or an exact slug.
func (s *Store) Resolve(ref string) (*Session, error) {
	for _, sess := range s.sessions {
		if sess.ID == ref || (sess.Slug != "" && sess.Slug == ref) {
			return sess, nil
		}
	}
	if len(ref) >= 4 {
		var hits []*Session
		for _, sess := range s.sessions {
			if strings.HasPrefix(sess.ID, ref) {
				hits = append(hits, sess)
			}
		}
		switch len(hits) {
		case 1:
			return hits[0], nil
		case 0:
		default:
			return nil, fmt.Errorf("ambiguous prefix %q matches %d sessions", ref, len(hits))
		}
	}
	for _, sess := range s.sessions {
		if sess.Slug != "" && strings.EqualFold(sess.Slug, ref) {
			return sess, nil
		}
	}
	return nil, fmt.Errorf("no session matching %q", ref)
}

func (s *Store) LoadMessages(sess *Session) ([]*Message, error) {
	if sess.msgs != nil {
		return sess.msgs, nil
	}
	msgTime := map[string]int64{}
	rows, err := sess.db.Query(`SELECT id, data FROM message WHERE session_id = ? ORDER BY time_created, id`, sess.ID)
	if err != nil {
		return nil, err
	}
	order := []string{}
	raw := map[string]string{}
	for rows.Next() {
		var id, data string
		if err := rows.Scan(&id, &data); err != nil {
			rows.Close()
			return nil, err
		}
		var md struct {
			Role string `json:"role"`
			Time struct {
				Created int64 `json:"created"`
			} `json:"time"`
		}
		json.Unmarshal([]byte(data), &md)
		msgTime[id] = md.Time.Created
		order = append(order, id)
		raw[id] = md.Role
	}
	rows.Close()
	if err := rows.Err(); err != nil {
		return nil, err
	}

	partsByMsg := map[string][]*Part{}
	rows2, err := sess.db.Query(`SELECT message_id, data FROM part WHERE session_id = ? ORDER BY time_created, id`, sess.ID)
	if err != nil {
		return nil, err
	}
	defer rows2.Close()
	for rows2.Next() {
		var msgID, data string
		if err := rows2.Scan(&msgID, &data); err != nil {
			return nil, err
		}
		part := parsePart(data)
		if part != nil {
			partsByMsg[msgID] = append(partsByMsg[msgID], part)
		}
	}
	if err := rows2.Err(); err != nil {
		return nil, err
	}

	for _, id := range order {
		sess.msgs = append(sess.msgs, &Message{
			ID:    id,
			Role:  raw[id],
			Time:  msgTime[id],
			Parts: partsByMsg[id],
		})
	}
	return sess.msgs, nil
}

func parsePart(data string) *Part {
	var pd struct {
		Type string `json:"type"`
		Text string `json:"text"`
		Tool string `json:"tool"`
		State *struct {
			Input  map[string]any `json:"input"`
			Output string         `json:"output"`
		} `json:"state"`
		Files []string `json:"files"`
	}
	if err := json.Unmarshal([]byte(data), &pd); err != nil {
		return nil
	}
	switch pd.Type {
	case "text", "reasoning":
		return &Part{Type: pd.Type, Text: pd.Text}
	case "tool":
		in := ""
		out := ""
		if pd.State != nil {
			in = renderToolInput(pd.State.Input)
			out = pd.State.Output
		}
		return &Part{Type: "tool", Tool: pd.Tool, Input: in, Output: out}
	case "patch":
		return &Part{Type: "patch", Text: strings.Join(pd.Files, ", ")}
	default:
		return nil
	}
}

var toolInputKeys = []string{"command", "description", "filePath", "pattern", "query", "url"}

func renderToolInput(input map[string]any) string {
	for _, k := range toolInputKeys {
		if v, ok := input[k].(string); ok && v != "" {
			return v
		}
	}
	b, err := json.Marshal(input)
	if err != nil {
		return ""
	}
	return string(b)
}

// searchable returns the category and text to index for a part.
// Non-empty categories: user, assistant, reasoning, tool, patch.
func (p *Part) searchable(role string) (cat, text string) {
	switch p.Type {
	case "text":
		if role == "" {
			role = "assistant"
		}
		return role, p.Text
	case "reasoning":
		return "reasoning", p.Text
	case "tool":
		return "tool", p.Input + "\n" + p.Output
	case "patch":
		return "patch", p.Text
	default:
		return "", ""
	}
}

func expandHome(p string) string {
	if p == "~" || strings.HasPrefix(p, "~/") {
		home, err := os.UserHomeDir()
		if err == nil {
			return filepath.Join(home, strings.TrimPrefix(p, "~"))
		}
	}
	return p
}
