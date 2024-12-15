# network-configs/samba-legacy.nix
{
  services.samba = {
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = Samba Server
      server role = standalone server
      map to guest = bad user
      client min protocol = NT1
      ntlm auth = yes
      lanman auth = yes
      client lanman auth = yes
      encrypt passwords = yes
      server min protocol = NT1
      local master = yes
      domain master = no
      preferred master = yes
      create mask = 0755
      directory mask = 0755
      map archive = yes
      map system = yes
      map hidden = yes
    '';
  };
}
