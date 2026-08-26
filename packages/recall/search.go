package main

import (
	"encoding/json"
	"fmt"
	"os"
	"sort"
	"strings"
	"time"
)

type tally struct {
	Keywords map[string]int `json:"keywords"`
	Cats     map[string]int `json:"categories"`
	Score    int            `json:"score"`
}

func newTally() *tally {
	return &tally{
		Keywords: map[string]int{},
		Cats:     map[string]int{},
	}
}

const perPartCap = 20

func (t *tally) count(cat, text string, keywords []string) {
	lower := strings.ToLower(text)
	for _, kw := range keywords {
		lk := strings.ToLower(kw)
		n := strings.Count(lower, lk)
		if n <= 0 {
			continue
		}
		if n > perPartCap {
			n = perPartCap
		}
		t.Keywords[kw] += n
		t.Cats[cat] += n
		t.Score += n
	}
}

func (t *tally) matched(keywords []string, mode string) bool {
	for _, kw := range keywords {
		ok := t.Keywords[kw] > 0
		if mode == "or" && ok {
			return true
		}
		if mode != "or" && !ok {
			return false
		}
	}
	return mode != "or"
}

func parseDate(s string) (int64, error) {
	t, err := time.ParseInLocation("2006-01-02", s, time.Local)
	if err != nil {
		return 0, fmt.Errorf("bad date %q (want YYYY-MM-DD)", s)
	}
	return t.UnixMilli(), nil
}

type hit struct {
	Session *Session
	T       *tally
}

func cmdSearch(args []string) error {
	fl, pos, err := parseArgs(args,
		[]string{"json"},
		[]string{"mode", "project", "after", "before", "role", "limit"},
		[]string{"db"})
	if err != nil {
		return err
	}
	if len(pos) < 1 {
		return fmt.Errorf("search needs at least one keyword\n\n%s", usage)
	}
	keywords := pos
	mode := fl.val("mode")
	if mode == "" {
		mode = "and"
	}
	if mode != "and" && mode != "or" {
		return fmt.Errorf("--mode must be and|or")
	}
	role := fl.val("role")
	if role == "" {
		role = "any"
	}
	project := fl.val("project")
	var afterMs, beforeMs int64
	if v := fl.val("after"); v != "" {
		if afterMs, err = parseDate(v); err != nil {
			return err
		}
	}
	if v := fl.val("before"); v != "" {
		if beforeMs, err = parseDate(v); err != nil {
			return err
		}
		beforeMs += 86_399_999
	}
	limit := fl.intVal("limit", 20)

	store, err := OpenStore(fl["db"])
	if err != nil {
		return err
	}
	defer store.Close()

	var hits []hit
	for _, sess := range store.sessions {
		if project != "" && !strings.HasPrefix(sess.Dir, expandHome(project)) {
			continue
		}
		if afterMs > 0 && sess.Created < afterMs {
			continue
		}
		if beforeMs > 0 && sess.Created > beforeMs {
			continue
		}
		msgs, err := store.LoadMessages(sess)
		if err != nil {
			fmt.Fprintf(os.Stderr, "recall: skipping session %s: %v\n", sess.ID, err)
			continue
		}
		t := newTally()
		t.count("title", strings.ToLower(sess.Title), keywords)
		for _, m := range msgs {
			for _, p := range m.Parts {
				cat, text := p.searchable(m.Role)
				if cat == "" {
					continue
				}
				if role != "any" && cat != role && !(role == "tool" && cat == "patch") {
					continue
				}
				t.count(cat, text, keywords)
			}
		}
		if t.matched(keywords, mode) {
			hits = append(hits, hit{Session: sess, T: t})
		}
	}

	sort.Slice(hits, func(i, j int) bool {
		if hits[i].T.Score != hits[j].T.Score {
			return hits[i].T.Score > hits[j].T.Score
		}
		return hits[i].Session.Updated > hits[j].Session.Updated
	})
	if len(hits) > limit {
		hits = hits[:limit]
	}

	if fl.has("json") {
		out := make([]map[string]any, 0, len(hits))
		for _, h := range hits {
			out = append(out, map[string]any{
				"id":         h.Session.ID,
				"slug":       h.Session.Slug,
				"title":      h.Session.Title,
				"directory":  h.Session.Dir,
				"parent_id":  h.Session.ParentID,
				"created":    h.Session.Created,
				"updated":    h.Session.Updated,
				"updated_at": msTime(h.Session.Updated).Format(time.RFC3339),
				"score":      h.T.Score,
				"keywords":   h.T.Keywords,
				"categories": h.T.Cats,
			})
		}
		enc := json.NewEncoder(os.Stdout)
		enc.SetIndent("", "  ")
		return enc.Encode(out)
	}

	if len(hits) == 0 {
		fmt.Println("no matching sessions")
		return nil
	}
	for i, h := range hits {
		s := h.Session
		fmt.Printf("%d. score=%d  %s  updated=%s\n", i+1, h.T.Score, s.ID, msTime(s.Updated).Format("2006-01-02"))
		child := ""
		if s.ParentID != "" {
			child = fmt.Sprintf("\n   child-of: %s", s.ParentID)
		}
		fmt.Printf("   %s%s\n   dir: %s\n", s.Title, child, s.Dir)
		fmt.Printf("   hits: %s | %s\n", formatKw(h.T, keywords), formatCats(h.T))
	}
	return nil
}

func formatKw(t *tally, keywords []string) string {
	parts := make([]string, 0, len(keywords))
	for _, kw := range keywords {
		parts = append(parts, fmt.Sprintf("%s=%d", kw, t.Keywords[kw]))
	}
	return strings.Join(parts, " ")
}

func formatCats(t *tally) string {
	order := []string{"user", "assistant", "reasoning", "tool", "patch", "title"}
	parts := []string{}
	for _, c := range order {
		if n := t.Cats[c]; n > 0 {
			parts = append(parts, fmt.Sprintf("%s=%d", c, n))
		}
	}
	return strings.Join(parts, " ")
}

func cmdSessions(args []string) error {
	fl, _, err := parseArgs(args,
		[]string{"json"},
		[]string{"project", "limit"},
		[]string{"db"})
	if err != nil {
		return err
	}
	limit := fl.intVal("limit", 50)
	project := fl.val("project")

	store, err := OpenStore(fl["db"])
	if err != nil {
		return err
	}
	defer store.Close()

	list := store.sessions
	if project != "" {
		prefix := expandHome(project)
		var filtered []*Session
		for _, s := range list {
			if strings.HasPrefix(s.Dir, prefix) {
				filtered = append(filtered, s)
			}
		}
		list = filtered
	}
	if len(list) > limit {
		list = list[:limit]
	}

	if fl.has("json") {
		out := make([]map[string]any, 0, len(list))
		for _, s := range list {
			out = append(out, map[string]any{
				"id":        s.ID,
				"slug":      s.Slug,
				"title":     s.Title,
				"directory": s.Dir,
				"parent_id": s.ParentID,
				"created":   s.Created,
				"updated":   s.Updated,
			})
		}
		enc := json.NewEncoder(os.Stdout)
		enc.SetIndent("", "  ")
		return enc.Encode(out)
	}

	for _, s := range list {
		child := ""
		if s.ParentID != "" {
			child = " [child]"
		}
		fmt.Printf("%s  %s  %-45s %s%s\n",
			msTime(s.Updated).Format("2006-01-02"), s.ID, truncate(s.Dir, 45), s.Title, child)
	}
	return nil
}

func cmdShow(args []string) error {
	fl, pos, err := parseArgs(args,
		[]string{"reasoning", "tools", "full"},
		[]string{"max-chars"},
		[]string{"keywords", "db"})
	if err != nil {
		return err
	}
	if len(pos) != 1 {
		return fmt.Errorf("show needs exactly one session ref\n\n%s", usage)
	}
	full := fl.has("full")
	maxChars := fl.intVal("max-chars", 2000)
	if full {
		maxChars = -1
	} else if fl.has("max-chars") && maxChars <= 0 {
		return fmt.Errorf("--max-chars must be positive")
	}
	showReasoning := full || fl.has("reasoning")
	showTools := full || fl.has("tools")
	keywords := fl["keywords"]

	store, err := OpenStore(fl["db"])
	if err != nil {
		return err
	}
	defer store.Close()

	sess, err := store.Resolve(pos[0])
	if err != nil {
		return err
	}
	msgs, err := store.LoadMessages(sess)
	if err != nil {
		return err
	}

	fmt.Printf("== %s — %s\n", sess.ID, sess.Title)
	fmt.Printf("dir %s · created %s · updated %s · %d messages\n\n",
		sess.Dir, msTime(sess.Created).Format("2006-01-02 15:04"), msTime(sess.Updated).Format("2006-01-02 15:04"), len(msgs))

	shown := 0
	for _, m := range msgs {
		if !messageMatches(m, keywords) {
			continue
		}
		renderMessage(m, showReasoning, showTools, maxChars)
		shown++
	}
	if shown == 0 && len(keywords) > 0 {
		fmt.Println("(no messages match the given keywords)")
	}
	return nil
}

func messageMatches(m *Message, keywords []string) bool {
	if len(keywords) == 0 {
		return true
	}
	for _, p := range m.Parts {
		cat, text := p.searchable(m.Role)
		if cat == "" {
			continue
		}
		lower := strings.ToLower(text)
		for _, kw := range keywords {
			if strings.Contains(lower, strings.ToLower(kw)) {
				return true
			}
		}
	}
	return false
}

func renderMessage(m *Message, showReasoning, showTools bool, maxChars int) {
	for _, p := range m.Parts {
		switch p.Type {
		case "text":
			who := m.Role
			if who == "" {
				who = "assistant"
			}
			printfCapped("["+who+"]\n%s\n\n", p.Text, maxChars)
		case "reasoning":
			if showReasoning {
				printfCapped("[thinking]\n%s\n\n", p.Text, maxChars)
			}
		case "tool":
			summary := oneLine(p.Input)
			if summary == "" {
				summary = p.Tool
			}
			if showTools {
				fmt.Printf("[tool %s] %s\n", p.Tool, summary)
				printfCapped("[tool-output]\n%s\n\n", p.Output, maxChars)
			} else {
				fmt.Printf("[tool %s] %s\n\n", p.Tool, truncate(summary, 160))
			}
		case "patch":
			fmt.Printf("[patch] %s\n\n", oneLine(p.Text))
		}
	}
}

func printfCapped(format, text string, maxChars int) {
	if maxChars >= 0 && len(text) > maxChars {
		text = truncate(text, maxChars) + fmt.Sprintf("\n[%d more chars truncated; use --max-chars or --full]", len(text)-maxChars)
	}
	fmt.Printf(format, text)
}

func oneLine(s string) string {
	s = strings.ReplaceAll(s, "\n", " ")
	return strings.TrimSpace(s)
}

func truncate(s string, n int) string {
	if n >= 0 && len(s) > n {
		return s[:n]
	}
	return s
}

func msTime(ms int64) time.Time {
	return time.UnixMilli(ms)
}
