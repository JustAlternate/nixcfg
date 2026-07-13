package main

import "encoding/json"

type ToolDef struct {
	Name        string          `json:"name"`
	Description string          `json:"description"`
	InputSchema json.RawMessage `json:"inputSchema"`
}

func registerTools() []ToolDef {
	return []ToolDef{
		{
			Name:        "opencode_task",
			Description: "Delegate a complex multi-step task to an OpenCode coding agent. The agent will autonomously explore the codebase, run shell commands, read/write/edit files, search code, and iterate until the task is complete. Use this for operations that require multiple steps like: updating nix flake dependencies, refactoring code, investigating bugs, implementing features, git workflows, nixos rebuilds. The agent has full access to the /root/nixcfg project. Note: this tool blocks until the task completes (may take 30s-2min).",
			InputSchema: toSchema(obj{
				"type": "object",
				"properties": obj{
					"task": obj{
						"type":        "string",
						"description": "The task for OpenCode to perform. Be detailed and specific. E.g. 'Update the nixpkgs flake input to the latest revision, run nix flake check, and commit the result.' or 'Investigate why the open-webui service is failing to build and suggest a fix.'",
					},
				},
				"required": []string{"task"},
			}),
		},
		{
			Name:        "shell_command",
			Description: "Execute a shell command in the nixcfg project directory on beaver. Returns stdout and stderr. Use for git operations, nix commands, file manipulation, building, testing, etc.",
			InputSchema: toSchema(obj{
				"type": "object",
				"properties": obj{
					"command": obj{
						"type":        "string",
						"description": "The shell command to execute",
					},
				},
				"required": []string{"command"},
			}),
		},
		{
			Name:        "read_file",
			Description: "Read a file's contents from the nixcfg project. Returns the file content with line numbers. Supports offset and limit for large files.",
			InputSchema: toSchema(obj{
				"type": "object",
				"properties": obj{
					"path": obj{
						"type":        "string",
						"description": "Path to the file to read, relative to the project root",
					},
					"offset": obj{
						"type":        "number",
						"description": "Line number to start reading from (1-indexed), optional",
					},
					"limit": obj{
						"type":        "number",
						"description": "Maximum number of lines to read, optional",
					},
				},
				"required": []string{"path"},
			}),
		},
		{
			Name:        "write_file",
			Description: "Create a new file or overwrite an existing one in the nixcfg project.",
			InputSchema: toSchema(obj{
				"type": "object",
				"properties": obj{
					"path": obj{
						"type":        "string",
						"description": "Path to write the file to, relative to the project root",
					},
					"content": obj{
						"type":        "string",
						"description": "Content to write to the file",
					},
				},
				"required": []string{"path", "content"},
			}),
		},
		{
			Name:        "edit_file",
			Description: "Edit a file by replacing an exact string match with new content. The old_string must match exactly, including whitespace.",
			InputSchema: toSchema(obj{
				"type": "object",
				"properties": obj{
					"path": obj{
						"type":        "string",
						"description": "Path to the file to edit, relative to the project root",
					},
					"old_string": obj{
						"type":        "string",
						"description": "Exact string to find and replace",
					},
					"new_string": obj{
						"type":        "string",
						"description": "Replacement string",
					},
				},
				"required": []string{"path", "old_string", "new_string"},
			}),
		},
		{
			Name:        "search_code",
			Description: "Search for a regex pattern in files within the nixcfg project. Returns matching file paths, line numbers, and line content.",
			InputSchema: toSchema(obj{
				"type": "object",
				"properties": obj{
					"pattern": obj{
						"type":        "string",
						"description": "Regex pattern to search for",
					},
					"include": obj{
						"type":        "string",
						"description": "File pattern to filter by, e.g. '*.nix' or '*.go', optional",
					},
				},
				"required": []string{"pattern"},
			}),
		},
		{
			Name:        "glob_files",
			Description: "Find files matching a glob pattern. E.g. '**/*.nix', 'hosts/*/system/**'.",
			InputSchema: toSchema(obj{
				"type": "object",
				"properties": obj{
					"pattern": obj{
						"type":        "string",
						"description": "Glob pattern to match file paths against",
					},
				},
				"required": []string{"pattern"},
			}),
		},
		{
			Name:        "list_files",
			Description: "List files and directories at a given path in the nixcfg project.",
			InputSchema: toSchema(obj{
				"type": "object",
				"properties": obj{
					"path": obj{
						"type":        "string",
						"description": "Directory path to list, relative to the project root. Use '' or '.' for root.",
					},
				},
				"required": []string{"path"},
			}),
		},
		{
			Name:        "web_fetch",
			Description: "Fetch content from a URL. Returns text/markdown content. Use for reading documentation, API references, or any web page.",
			InputSchema: toSchema(obj{
				"type": "object",
				"properties": obj{
					"url": obj{
						"type":        "string",
						"description": "URL to fetch content from",
					},
				},
				"required": []string{"url"},
			}),
		},
	}
}

type obj map[string]any

func toSchema(s obj) []byte {
	b, _ := json.Marshal(s)
	return b
}
