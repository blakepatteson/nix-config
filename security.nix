{ ... }:
{
  security = {
    rtkit.enable = true;
    sudo.wheelNeedsPassword = true;
    auditd.enable = true;
  };
}
