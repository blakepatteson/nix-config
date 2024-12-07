{ pkgs, ... }:
{
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu.package = pkgs.qemu_kvm;
      qemu.swtpm.enable = true;
      qemu.ovmf = {
        enable = true;
        packages = [ (pkgs.OVMF.override { secureBoot = true; tpmSupport = true; }).fd ];
      };
    };

    docker.enable = true;
    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;
  security.tpm2 = { enable = true; pkcs11.enable = true; };
}
