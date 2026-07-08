# global agent instructions

- Never use the em dash "—". Use plain dash "-" instead
- When writing commit messages, NEVER auto-add your agent name as co-author
- When making technical decisions, do not give much weight to development cost.
  Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability.
- For project-level agent instructions, keep `AGENTS.md` as the single canonical file and make
  `CLAUDE.md` a symlink to it (`ln -s AGENTS.md CLAUDE.md`), so every agent reads the same notes.
  Write content only to `AGENTS.md`, never to `CLAUDE.md` directly. If a repo already has a plain
  `CLAUDE.md` and no `AGENTS.md`, convert it: `git mv CLAUDE.md AGENTS.md && ln -s AGENTS.md CLAUDE.md`.
