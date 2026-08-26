---
name: recall
description: Use when the user wants to recall or recover anything from past opencode conversations - previous sessions, prior decisions, what was said or done before, debugging history, "remember when", "last time we", "as discussed earlier", "did we already". Provides the `recall` CLI to search and read local opencode session databases.
---

# Recall

Search past opencode sessions on this machine (`~/.local/share/opencode/*.db`, read-only).

## Workflow

1. **Search** with 2-4 distinctive keywords (default requires ALL of them):

   ```
   recall search <keyword> [<keyword>...]
   ```

   - Nothing found → try synonyms, then `--mode or` to widen.
   - Too many hits → add keywords, or narrow with `--project <dir>` (prefix match on working directory) and `--after`/`--before YYYY-MM-DD`.
   - Results are ranked by score with per-keyword hit counts and a category breakdown (`user` / `assistant` / `reasoning` / `tool` / `patch` / `title`) plus last-updated date. Use title + directory + date + hit distribution to judge which session is relevant.

2. **Retrieve context** from the best 1-3 candidates:

   ```
   recall show <session-id-or-prefix> --keywords <kw> [<kw>...]
   ```

   - Accepts full id, unique id prefix (e.g. `ses_fcaa0f27`), or exact slug.
   - With `--keywords`: prints only messages containing any keyword.
   - Without: prints user + assistant text; tool calls appear as one-line summaries, thinking is hidden.
   - Each block is capped at 2000 chars (`--max-chars N` to change). Use `--tools` for full tool input/output, `--reasoning` for agent thinking, `--full` for everything uncapped.

3. **Answer** citing the source: session id prefix, slug/title and date.

## Rules

- Never dump a whole session into context. Search first, then read narrowly; widen only if the excerpts miss needed context.
- Report honestly when nothing matches - do not guess from partial hits.
- Only sees local history on the current machine.
- `recall sessions [--project X] [--limit N] [--json]` lists recent sessions when browsing is enough; `--json` on search/sessions gives machine-readable output.
