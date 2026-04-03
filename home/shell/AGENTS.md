# AGENTS.md - Global AI Agent Directives

## ⚠️ NixOS Environment

You are running on NixOS. These constraints apply to ALL projects on ALL machines.

### Package Management
- **NEVER** use global package managers: `apt`, `yum`, `pacman`, `pip install --user`, `npm install -g`, etc.
- **ALWAYS** check if packages are already installed before using `nix shell`
- **Nix is immutable**: ASK and edit config files declaratively in `~/nixcfg` if needed, then ask for rebuild

### Architecture Detection
```bash
ARCH=$(uname -m)
OS=$(uname -s)
```
- **x86_64-linux**: swordfish (desktop), parrot (laptop)
- **aarch64-linux**: beaver (VPS Hetzner), gecko (Raspberry Pi)
- **aarch64-darwin**: owl (Mac M1, nix-darwin)

Nix packages are architecture-specific. `nix shell` commands must match the system architecture.

## 🛠️ Preferred Tools & Languages

### Primary Languages
- **Go** — primary backend language (nix-managed)
- **Python** — scripting, automation (nix-managed)
- **Bash** — shell scripting, system tasks

### Other Languages
- Lua, C/C++, JavaScript/TypeScript, Java

### Key Tools
- **git** + lazygit — version control
- **vim** / neovim — text editing
- **opencode** — AI assistant (this tool)
- **rtk** — file management
- **fzf**, **ripgrep**, **zoxide** — navigation & search
- **sops** — secrets management (age encryption)

## 💬 Response Style

- **Concise and direct** — get straight to the point, no preamble
- **KISS** — simple solutions, no over-engineering
- **Critical and relevant** — challenge assumptions when needed, point out problems
- **Thoughtful** — analyze before responding
- **No useless comments** in code unless asked
- **Clean code** — readable, maintainable, well-structured
- **English by default** for all communication and code

## 🧠 Brainstorming & Planning

- **Propose directions** for planning and architecture decisions
- **1 to 3 options** when relevant, with brief pros/cons
- **Recommend one option** clearly when there is a choice
- **Structure plans** in numbered steps

## 🚨 Critical Rules

1. **NEVER** commit secrets or keys
2. **NEVER** change git config (user.name, user.email) autonomously
3. **NEVER** commit or push changes autonomously — always ask first
4. **NEVER** run long commands autonomously — ask for confirmation
5. **ALWAYS** use sops for secrets, never plain text
6. **ALWAYS** check existing packages before installing
7. **ALWAYS** test config syntax before applying changes
