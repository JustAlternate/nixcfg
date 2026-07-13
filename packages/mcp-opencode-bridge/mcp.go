package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strings"
	"sync"
)

type sseConn struct {
	mu     sync.Mutex
	writer http.ResponseWriter
	flusher http.Flusher
	closed bool
}

func (c *sseConn) send(eventType string, data any) error {
	c.mu.Lock()
	defer c.mu.Unlock()
	if c.closed {
		return fmt.Errorf("connection closed")
	}
	jsonData, _ := json.Marshal(data)
	fmt.Fprintf(c.writer, "event: %s\ndata: %s\n\n", eventType, jsonData)
	c.flusher.Flush()
	return nil
}

type mcpServer struct {
	mu       sync.Mutex
	oc       *openCodeClient
	sessions map[string]*sseConn
	tools    []ToolDef
}

type jsonRPCRequest struct {
	JSONRPC string          `json:"jsonrpc"`
	ID      any             `json:"id"`
	Method  string          `json:"method"`
	Params  json.RawMessage `json:"params"`
}

type jsonRPCResponse struct {
	JSONRPC string `json:"jsonrpc"`
	ID      any    `json:"id"`
	Result  any    `json:"result,omitempty"`
	Error   *rpcError `json:"error,omitempty"`
}

type rpcError struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}

func (s *mcpServer) handleSSE(w http.ResponseWriter, r *http.Request) {
	flusher, ok := w.(http.Flusher)
	if !ok {
		http.Error(w, "streaming not supported", http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "text/event-stream")
	w.Header().Set("Cache-Control", "no-cache")
	w.Header().Set("Connection", "keep-alive")
	flusher.Flush()

	sessionID := fmt.Sprintf("sess-%d", len(s.sessions)+1)
	endpoint := fmt.Sprintf("/messages?sessionId=%s", sessionID)

	conn := &sseConn{writer: w, flusher: flusher}

	s.mu.Lock()
	s.sessions[sessionID] = conn
	s.mu.Unlock()

	defer func() {
		s.mu.Lock()
		conn.mu.Lock()
		conn.closed = true
		conn.mu.Unlock()
		delete(s.sessions, sessionID)
		s.mu.Unlock()
	}()

	if err := conn.send("endpoint", endpoint); err != nil {
		return
	}
	if err := conn.send("event", "server.connected"); err != nil {
		return
	}

	<-r.Context().Done()
}

func (s *mcpServer) handleMessages(w http.ResponseWriter, r *http.Request) {
	sessionID := r.URL.Query().Get("sessionId")
	if sessionID == "" {
		http.Error(w, "missing sessionId", http.StatusBadRequest)
		return
	}

	s.mu.Lock()
	conn, ok := s.sessions[sessionID]
	s.mu.Unlock()

	if !ok {
		http.Error(w, "unknown session", http.StatusNotFound)
		return
	}

	var req jsonRPCRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		s.respond(w, r, jsonRPCResponse{
			JSONRPC: "2.0",
			ID:      nil,
			Error:   &rpcError{Code: -32700, Message: "parse error"},
		})
		return
	}

	result, rpcErr := s.dispatch(&req)

	response := jsonRPCResponse{
		JSONRPC: "2.0",
		ID:      req.ID,
		Result:  result,
		Error:   rpcErr,
	}

	jsonData, _ := json.Marshal(response)
	conn.send("message", json.RawMessage(jsonData))

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusAccepted)
	json.NewEncoder(w).Encode(map[string]string{"status": "accepted"})
}

func (s *mcpServer) respond(w http.ResponseWriter, r *http.Request, resp jsonRPCResponse) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func (s *mcpServer) handleMCP(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization, Mcp-Session-Id")

	if r.Method == http.MethodOptions {
		w.WriteHeader(http.StatusNoContent)
		return
	}

	if r.Method == http.MethodGet {
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]any{"status": "ok", "transport": "streamable-http"})
		return
	}

	var req jsonRPCRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(jsonRPCResponse{
			JSONRPC: "2.0",
			ID:      nil,
			Error:   &rpcError{Code: -32700, Message: "parse error"},
		})
		return
	}

	if req.ID == nil {
		result, _ := s.dispatch(&req)
		_ = result
		w.WriteHeader(http.StatusAccepted)
		return
	}

	result, rpcErr := s.dispatch(&req)
	s.respond(w, r, jsonRPCResponse{
		JSONRPC: "2.0",
		ID:      req.ID,
		Result:  result,
		Error:   rpcErr,
	})
}

func (s *mcpServer) dispatch(req *jsonRPCRequest) (any, *rpcError) {
	switch req.Method {
	case "initialize":
		return s.handleInitialize(req)
	case "notifications/initialized":
		return nil, nil
	case "tools/list":
		return s.handleToolsList(req)
	case "tools/call":
		return s.handleToolCall(req)
	default:
		return nil, &rpcError{Code: -32601, Message: fmt.Sprintf("method not found: %s", req.Method)}
	}
}

func (s *mcpServer) handleInitialize(req *jsonRPCRequest) (any, *rpcError) {
	return map[string]any{
		"protocolVersion": "2025-03-26",
		"capabilities": map[string]any{
			"tools": map[string]any{},
		},
		"serverInfo": map[string]any{
			"name":    "mcp-opencode-bridge",
			"version": "1.0.0",
		},
	}, nil
}

func (s *mcpServer) handleToolsList(req *jsonRPCRequest) (any, *rpcError) {
	return map[string]any{
		"tools": s.tools,
	}, nil
}

type toolCallParams struct {
	Name      string          `json:"name"`
	Arguments json.RawMessage `json:"arguments"`
}

func (s *mcpServer) handleToolCall(req *jsonRPCRequest) (any, *rpcError) {
	var p toolCallParams
	if err := json.Unmarshal(req.Params, &p); err != nil {
		return nil, &rpcError{Code: -32602, Message: "invalid params"}
	}

	result, err := s.executeTool(p.Name, p.Arguments)
	if err != nil {
		log.Printf("tool %s error: %v", p.Name, err)
		return map[string]any{
			"content": []map[string]any{
				{"type": "text", "text": fmt.Sprintf("Error: %v", err)},
			},
			"isError": true,
		}, nil
	}

	return map[string]any{
		"content": []map[string]any{
			{"type": "text", "text": result},
		},
	}, nil
}

func (s *mcpServer) executeTool(name string, args json.RawMessage) (string, error) {
	switch name {
	case "opencode_task":
		return s.toolOpenCodeTask(args)
	case "shell_command":
		return s.toolShellCommand(args)
	case "read_file":
		return s.toolReadFile(args)
	case "write_file":
		return s.toolWriteFile(args)
	case "edit_file":
		return s.toolEditFile(args)
	case "search_code":
		return s.toolSearchCode(args)
	case "glob_files":
		return s.toolGlobFiles(args)
	case "list_files":
		return s.toolListFiles(args)
	case "web_fetch":
		return s.toolWebFetch(args)
	default:
		return "", fmt.Errorf("unknown tool: %s", name)
	}
}

func (s *mcpServer) toolOpenCodeTask(args json.RawMessage) (string, error) {
	var p struct {
		Task string `json:"task"`
	}
	if err := json.Unmarshal(args, &p); err != nil {
		return "", fmt.Errorf("invalid args: %w", err)
	}
	if p.Task == "" {
		return "", fmt.Errorf("task is required")
	}
	return s.oc.runTask(p.Task)
}

func (s *mcpServer) toolShellCommand(args json.RawMessage) (string, error) {
	var p struct {
		Command string `json:"command"`
	}
	if err := json.Unmarshal(args, &p); err != nil {
		return "", fmt.Errorf("invalid args: %w", err)
	}
	if p.Command == "" {
		return "", fmt.Errorf("command is required")
	}
	return s.oc.execShell(p.Command)
}

func (s *mcpServer) toolReadFile(args json.RawMessage) (string, error) {
	var p struct {
		Path   string `json:"path"`
		Offset int    `json:"offset"`
		Limit  int    `json:"limit"`
	}
	if err := json.Unmarshal(args, &p); err != nil {
		return "", fmt.Errorf("invalid args: %w", err)
	}
	if p.Path == "" {
		return "", fmt.Errorf("path is required")
	}
	return s.oc.readFile(p.Path, p.Offset, p.Limit)
}

func (s *mcpServer) toolWriteFile(args json.RawMessage) (string, error) {
	var p struct {
		Path    string `json:"path"`
		Content string `json:"content"`
	}
	if err := json.Unmarshal(args, &p); err != nil {
		return "", fmt.Errorf("invalid args: %w", err)
	}
	if p.Path == "" {
		return "", fmt.Errorf("path is required")
	}

	escaped := strings.ReplaceAll(p.Content, "\\", "\\\\")
	escaped = strings.ReplaceAll(escaped, "'", "'\\''")
	cmd := fmt.Sprintf("mkdir -p \"$(dirname '%s')\" && printf '%%s' '%s' > '%s'", p.Path, escaped, p.Path)
	return s.oc.execShell(cmd)
}

func (s *mcpServer) toolEditFile(args json.RawMessage) (string, error) {
	var p struct {
		Path      string `json:"path"`
		OldString string `json:"old_string"`
		NewString string `json:"new_string"`
	}
	if err := json.Unmarshal(args, &p); err != nil {
		return "", fmt.Errorf("invalid args: %w", err)
	}

	checkCmd := fmt.Sprintf("grep -q '%s' '%s' || { echo 'ERROR: old_string not found in file'; exit 1; }",
		strings.ReplaceAll(p.OldString, "'", "'\\''"), p.Path)
	if out, err := s.oc.execShell(checkCmd); err != nil || strings.Contains(out, "ERROR") {
		return "", fmt.Errorf("old_string not found in file: %s", p.Path)
	}

	escapedOld := strings.ReplaceAll(p.OldString, "\\", "\\\\")
	escapedOld = strings.ReplaceAll(escapedOld, "'", "'\\''")
	escapedNew := strings.ReplaceAll(p.NewString, "\\", "\\\\")
	escapedNew = strings.ReplaceAll(escapedNew, "'", "'\\''")

	cmd := fmt.Sprintf(`
OLD=$(cat '%s')
NEW="${OLD/'%s'/'%s'}"
printf '%%s' "$NEW" > '%s'
`, p.Path, escapedOld, escapedNew, p.Path)

	return s.oc.execShell(cmd)
}

func (s *mcpServer) toolSearchCode(args json.RawMessage) (string, error) {
	var p struct {
		Pattern string `json:"pattern"`
		Include string `json:"include"`
	}
	if err := json.Unmarshal(args, &p); err != nil {
		return "", fmt.Errorf("invalid args: %w", err)
	}
	if p.Pattern == "" {
		return "", fmt.Errorf("pattern is required")
	}
	return s.oc.searchCode(p.Pattern, p.Include)
}

func (s *mcpServer) toolGlobFiles(args json.RawMessage) (string, error) {
	var p struct {
		Pattern string `json:"pattern"`
	}
	if err := json.Unmarshal(args, &p); err != nil {
		return "", fmt.Errorf("invalid args: %w", err)
	}
	if p.Pattern == "" {
		return "", fmt.Errorf("pattern is required")
	}
	return s.oc.globFiles(p.Pattern)
}

func (s *mcpServer) toolListFiles(args json.RawMessage) (string, error) {
	var p struct {
		Path string `json:"path"`
	}
	if err := json.Unmarshal(args, &p); err != nil {
		return "", fmt.Errorf("invalid args: %w", err)
	}
	return s.oc.listFiles(p.Path)
}

func (s *mcpServer) toolWebFetch(args json.RawMessage) (string, error) {
	var p struct {
		URL string `json:"url"`
	}
	if err := json.Unmarshal(args, &p); err != nil {
		return "", fmt.Errorf("invalid args: %w", err)
	}
	if p.URL == "" {
		return "", fmt.Errorf("url is required")
	}

	cmd := fmt.Sprintf("curl -sL --max-time 30 '%s'", strings.ReplaceAll(p.URL, "'", "'\\''"))
	return s.oc.execShell(cmd)
}
