{ user, ... }:

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin"; # use x86_64-darwin for Intel CPU

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };
  system.stateVersion = 6;

  # Authenticate sudo with Touch ID. sudo_local writes /etc/pam.d/sudo_local,
  # which survives macOS updates (unlike patching /etc/pam.d/sudo directly).
  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      _HIHideMenuBar = false;  # keep the menu bar (and clock) always visible
      AppleShowAllExtensions = true;
    };
    dock.autohide = true;
    WindowManager.GloballyEnabled = false; # stage manager off: focusing an app must not shove others away
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = false;          # clean desktop
    trackpad.Clicking = true;              # tap to click
  };
  nix-homebrew = {
    enable = true;
    inherit user;
    autoMigrate = true;
  };
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";  # remove anything not listed here
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;  # upgrade declared brews/casks on every rebuild
    onActivation.extraFlags = [ "--force" ];
    taps = [ ];
    brews = [
      "herdr"
      # grype moved to home.packages (nixpkgs); the anchore tap formula was
      # disabled upstream 2025-07-01 and only builds from source.
    ];
    casks = [
      "wezterm"
      "claude-code"
      "surfshark"
      "chatgpt"
      "sublime-text"  # GUI text editor; yazi opens text files in it (home.nix)
    ];
  };
}
