# global agent instructions

- Never use the em dash "—". Use plain dash "-" instead
- When writing commit messages, NEVER auto-add your agent name as co-author
- When making technical decisions, do not give much weight to development cost.
  Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability.
- For project-level agent instructions, keep `AGENTS.md` as the single canonical file and make
  `CLAUDE.md` a symlink to it (`ln -s AGENTS.md CLAUDE.md`), so every agent reads the same notes.
  Write content only to `AGENTS.md`, never to `CLAUDE.md` directly. If a repo already has a plain
  `CLAUDE.md` and no `AGENTS.md`, convert it: `git mv CLAUDE.md AGENTS.md && ln -s AGENTS.md CLAUDE.md`.
- This Mac is managed declaratively with nix-darwin + home-manager (source of truth: `~/.dotfiles`).
  NEVER install software ad-hoc (`brew install`, `npm install -g`, `pip`/`pipx install`, `cargo
  install`, `go install`, `mas`, dragging a `.app` in). Homebrew is set to `cleanup = "zap"`, so
  anything not declared in the config is uninstalled on the next rebuild. Instead: declare it, then
  run `cd ~/.dotfiles && ./rebuild.sh`.
  - nixpkgs CLI tool -> `home.packages` in `home.nix` (prefer this for CLI tools)
  - GUI app -> `casks` in `configuration.nix`
  - Homebrew-only formula -> `brews` (and `taps` if needed) in `configuration.nix`
  - App Store app -> `masApps` in `configuration.nix`
  For a genuine throwaway, use `nix shell nixpkgs#<pkg>` or `nix run nixpkgs#<pkg>` instead of installing.
