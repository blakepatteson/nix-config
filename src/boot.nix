{ ... }:
{
  boot.plymouth.enable = false;
  boot.loader = {
    systemd-boot = { enable = true; configurationLimit = 10; };
    efi.canTouchEfiVariables = true;
  };
  boot.kernelParams = [
    "intel_iommu=on"
    "snd_hda_intel.dmic_detect=0"
    "quiet"
    "splash"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "nowatchdog"
    "mitigations=off"
  ];
  boot.tmp.cleanOnBoot = true;
  boot.kernel.sysctl = { "vm.swappiness" = 10; "fs.inotify.max_user_watches" = 524288; };
}

