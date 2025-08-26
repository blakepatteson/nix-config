{ pkgs, ... }:
{
  time.timeZone = "America/New_York";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  nix = {
    gc = {
      dates = "weekly";
      options = "--delete-older-than 14d";
      persistent = true;
    };
    settings = {
      max-jobs = 8;
      cores = 8;
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [ "https://cache.nixos.org" "https://nix-community.cachix.org" ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  users.users.blake = {
    isNormalUser = true;
    description = "blake";
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "libvirtd"
      "video"
      "kvm"
      "midi"
      "realtime"
      "pipewire"
    ];
  };

  security = {
    rtkit.enable = true;
    sudo.wheelNeedsPassword = true;
    auditd.enable = true;
  };

  fonts.packages = with pkgs;
    [
      noto-fonts
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
      victor-mono
      pkgs.nerd-fonts.victor-mono
    ];

  nixpkgs.config = {
    allowUnfree = true;
    firefox.enableWideVine = true;
  };

  programs.firefox = {
    enable = true;
    preferences = { "media.eme.enabled" = true; };
  };

  zramSwap.enable = true;

  # Fix systemd-modules-load timeout by masking it - modules load anyway
  systemd.services.systemd-modules-load.enable = false;

  # system.autoUpgrade.enable = true;
  system.stateVersion = "24.11";
}
