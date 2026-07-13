package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"
)

func main() {
	port := flag.Int("port", 4200, "port to listen on")
	opencodeURL := flag.String("opencode-url", "http://localhost:4096", "opencode server URL")
	flag.Parse()

	oc := newOpenCodeClient(*opencodeURL, os.Getenv("OPENCODE_SERVER_PASSWORD"))

	if err := oc.createSession(); err != nil {
		log.Printf("initial connection failed: %v — retrying...", err)
		for i := 0; i < 30; i++ {
			time.Sleep(2 * time.Second)
			if err := oc.createSession(); err == nil {
				goto connected
			}
		}
		log.Fatalf("failed to connect to opencode server after 30 attempts")
	}
connected:
	log.Printf("connected to opencode server at %s (session: %s)", *opencodeURL, oc.sessionID)

	srv := &mcpServer{
		oc:        oc,
		sessions:  make(map[string]*sseConn),
		tools:     registerTools(),
	}

	http.HandleFunc("/sse", srv.handleSSE)
	http.HandleFunc("/messages", srv.handleMessages)
	http.HandleFunc("/mcp", srv.handleMCP)
	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		fmt.Fprintf(w, "ok")
	})

	addr := fmt.Sprintf(":%d", *port)
	log.Printf("MCP bridge listening on %s", addr)
	if err := http.ListenAndServe(addr, nil); err != nil {
		fmt.Fprintf(os.Stderr, "server error: %v\n", err)
		os.Exit(1)
	}
}
