{ config, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    # cli i use constantly
    ripgrep   # fast search
    fd        # fast find
    fzf       # fuzzy finder
    eza       # modern ls with type/git-aware colors
    jq        # json on the command line
    gh        # github cli
    lazygit
    neovim
    codex     # openai's terminal coding agent (pinned to unstable, see flake.nix overlay)
    # latex toolchain for resume_latex/ - xelatex plus the exact package set
    # both cv_12 (two-column) and cv_ats (single-column) need. verified to
    # compile both before declaring, so no missing-package surprises.
    (texlive.combine {
      inherit (texlive)
        scheme-medium
        titlesec enumitem setspace needspace
        fontawesome5 paracol moresize textpos isodate substr multirow;
    })
    # the font everything renders in
    nerd-fonts.hack
  ];
  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    initContent = ''
      bindkey '^f' autosuggest-accept
    '';
    shellAliases = {
      ".." = "cd ..";
      ls = "eza --group-directories-first";
      ll = "eza -l --git --group-directories-first";
      la = "eza -la --git --group-directories-first";
      lt = "eza -la --git --sort=modified --reverse";  # newest first (ls -ltra)
      add = "git add .";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
      cc = "claude --dangerously-skip-permissions";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";
  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";

  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".codex/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.codex/config.toml";
  home.file.".config/opencode/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";

  # codex rewrites ~/.codex/config.toml at runtime (per-project trust levels,
  # nux flags). that file is an out-of-store symlink into this repo, so its
  # writes would otherwise show up as churn in a public repo. skip-worktree
  # tells git to ignore local edits; re-applied here so it survives fresh clones.
  home.activation.codexConfigSkipWorktree =
    config.lib.dag.entryAfter [ "writeBoundary" ] ''
      if [ -d "${dotfiles}/.git" ]; then
        ${pkgs.git}/bin/git -C "${dotfiles}" update-index --skip-worktree home/.codex/config.toml 2>/dev/null || true
      fi
    '';
}
