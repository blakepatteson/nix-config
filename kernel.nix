{ pkgs, lib, ... }:

{
  # Use current running kernel to avoid module issues
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;

  # These lines help ensure kernel modules work properly
  boot.initrd.includeDefaultModules = true;

  # Force all kernel modules to be bundled with the system
  # This helps prevent the "not in Nix store" errors
  boot.modprobeConfig.package = lib.mkForce "";
}
