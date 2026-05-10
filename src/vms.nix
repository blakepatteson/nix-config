{ lib, pkgs, ... }:
let
  isDesktop = builtins.pathExists /var/lib/libvirt/images/win11-new.qcow2;
  isLaptop = builtins.pathExists /var/lib/libvirt/images/win11-work.qcow2;

  vmXml =
    if isDesktop then ./vms/win11-desktop.xml
    else if isLaptop then ./vms/win11-laptop.xml
    else null;
in
lib.mkIf (vmXml != null) {
  systemd.services.define-vms = {
    description = "Register libvirt VM definitions";
    wantedBy = [ "multi-user.target" ];
    after = [ "libvirtd.service" ];
    requires = [ "libvirtd.service" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
    script = ''
      ${pkgs.libvirt}/bin/virsh define ${vmXml} --validate 2>/dev/null || \
      ${pkgs.libvirt}/bin/virsh define ${vmXml}
    '';
  };
}
