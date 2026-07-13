package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strings"
	"time"
)

type openCodeClient struct {
	baseURL  string
	password string
	client   *http.Client
	sessionID string
}

func newOpenCodeClient(baseURL, password string) *openCodeClient {
	return &openCodeClient{
		baseURL:  strings.TrimRight(baseURL, "/"),
		password: password,
		client: &http.Client{
			Timeout: 0,
		},
	}
}

func (c *openCodeClient) do(req *http.Request) (*http.Response, error) {
	if c.password != "" {
		req.SetBasicAuth("opencode", c.password)
	}
	return c.client.Do(req)
}

func (c *openCodeClient) createSession() error {
	body := map[string]any{"title": "mcp-bridge"}
	b, _ := json.Marshal(body)

	req, err := http.NewRequest("POST", c.baseURL+"/session", bytes.NewReader(b))
	if err != nil {
		return fmt.Errorf("create session: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")
	resp, err := c.do(req)
	if err != nil {
		return fmt.Errorf("create session: %w", err)
	}
	defer resp.Body.Close()

	var result struct {
		ID string `json:"id"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return fmt.Errorf("decode session response: %w", err)
	}
	if result.ID == "" {
		return fmt.Errorf("empty session id in response (status %d)", resp.StatusCode)
	}
	c.sessionID = result.ID
	return nil
}

func (c *openCodeClient) execShell(cmd string) (string, error) {
	body := map[string]any{"command": cmd, "agent": "build"}
	b, _ := json.Marshal(body)

	url := fmt.Sprintf("%s/session/%s/shell", c.baseURL, c.sessionID)
	req, err := http.NewRequest("POST", url, bytes.NewReader(b))
	if err != nil {
		return "", fmt.Errorf("shell exec: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")
	resp, err := c.do(req)
	if err != nil {
		return "", fmt.Errorf("shell exec: %w", err)
	}
	defer resp.Body.Close()

	return c.parseAssistantResponse(resp.Body)
}

func (c *openCodeClient) doGet(url string) (string, error) {
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return "", fmt.Errorf("create request: %w", err)
	}
	resp, err := c.do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()
	body, _ := io.ReadAll(resp.Body)
	return string(body), nil
}

func (c *openCodeClient) readFile(path string, offset, limit int) (string, error) {
	query := url.Values{}
	query.Set("path", path)
	if offset > 0 {
		query.Set("offset", fmt.Sprintf("%d", offset))
	}
	if limit > 0 {
		query.Set("limit", fmt.Sprintf("%d", limit))
	}

	reqURL := fmt.Sprintf("%s/file/content?%s", c.baseURL, query.Encode())
	return c.doGet(reqURL)
}

func (c *openCodeClient) listFiles(path string) (string, error) {
	query := url.Values{}
	query.Set("path", path)

	reqURL := fmt.Sprintf("%s/file?%s", c.baseURL, query.Encode())
	return c.doGet(reqURL)
}

func (c *openCodeClient) searchCode(pattern, include string) (string, error) {
	query := url.Values{}
	query.Set("pattern", pattern)
	if include != "" {
		query.Set("include", include)
	}

	reqURL := fmt.Sprintf("%s/find?%s", c.baseURL, query.Encode())
	return c.doGet(reqURL)
}

func (c *openCodeClient) globFiles(pattern string) (string, error) {
	query := url.Values{}
	query.Set("query", pattern)

	reqURL := fmt.Sprintf("%s/find/file?%s", c.baseURL, query.Encode())
	return c.doGet(reqURL)
}

func (c *openCodeClient) parseAssistantResponse(r io.Reader) (string, error) {
	body, _ := io.ReadAll(r)
	var result struct {
		Info  any `json:"info"`
		Parts []struct {
			Type string `json:"type"`
			Text string `json:"text"`
		} `json:"parts"`
	}
	if err := json.Unmarshal(body, &result); err != nil {
		return string(body), nil
	}

	var out strings.Builder
	for _, p := range result.Parts {
		if (p.Type == "text" || p.Type == "reasoning") && p.Text != "" {
			out.WriteString(p.Text)
			out.WriteString("\n")
		}
	}
	if out.Len() == 0 {
		return string(body), nil
	}
	return strings.TrimSpace(out.String()), nil
}

func (c *openCodeClient) runTask(task string) (string, error) {
	body := map[string]any{
		"parts": []map[string]any{
			{"type": "text", "text": task},
		},
	}
	b, _ := json.Marshal(body)

	url := fmt.Sprintf("%s/session/%s/message", c.baseURL, c.sessionID)
	req, err := http.NewRequest("POST", url, bytes.NewReader(b))
	if err != nil {
		return "", fmt.Errorf("run task: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")

	start := time.Now()
	resp, err := c.do(req)
	if err != nil {
		return "", fmt.Errorf("run task: %w", err)
	}
	defer resp.Body.Close()

	result, err := c.parseAssistantResponse(resp.Body)
	elapsed := time.Since(start).Round(time.Second)
	if err != nil {
		return result, nil
	}
	return fmt.Sprintf("%s\n\n(took %v)", result, elapsed), nil
}
