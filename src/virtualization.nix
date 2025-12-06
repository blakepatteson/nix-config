{ pkgs, ... }:
{
  virtualisation = {
    libvirtd = {
      enable = true;
      onBoot = "ignore";
      qemu.package = pkgs.qemu_kvm;
      qemu.swtpm.enable = true;
    };

    docker = {
      enable = true;
      enableOnBoot = false;
      daemon.settings = {
        "storage-driver" = "overlay2";
        "log-driver" = "json-file";
        "log-opts" = { "max-size" = "10m"; "max-file" = "3"; };
      };
    };
    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;
  security.tpm2 = { enable = true; pkcs11.enable = true; };
}
