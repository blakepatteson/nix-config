{ ... }:
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
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
      persistent = true;
    };
    settings = {
      cores = 0;
      max-jobs = "auto";
      auto-optimise-store = true;
    };
  };

  users.users.blake = {
    isNormalUser = true;
    description = "blake";
    extraGroups = [ "networkmanager" "wheel" "audio" "libvirtd" "video" "kvm" ];
  };

  nixpkgs.config.allowUnfree = true;
  programs.firefox.enable = true;
  zramSwap.enable = true;

  system.autoUpgrade.enable = true;
  system.stateVersion = "24.05";
}
