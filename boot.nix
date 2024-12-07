{ config, lib, ... }:
{
  assertions = [{
    assertion = lib.versionAtLeast config.system.nixos.version "23.11";
    message = ''
      Your NixOS version (${config.system.nixos.version}) is older than required (23.11).
      Please run:
        sudo nix-channel --update
        sudo nixos-rebuild switch
    '';
  }];

  boot.plymouth.enable = false;
  boot.loader = {
    systemd-boot = { enable = true; configurationLimit = 10; };
    efi.canTouchEfiVariables = true;
  };
  boot.kernelParams = [ "intel_iommu=on" "snd_hda_intel.dmic_detect=0" ];
  boot.tmp.cleanOnBoot = true;
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "fs.inotify.max_user_watches" = 524288;
  };
}

