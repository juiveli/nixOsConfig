{ pkgs, ... }: {
  services.kea.dhcp4 = {
    enable = true;
    settings = {
      interfaces-config = { interfaces = [ "enp6s0" ]; };
      lease-database = {
        name = "/var/lib/kea/dhcp4.leases";
        persist = true;
        type = "memfile";
      };
      rebind-timer = 2000;
      renew-timer = 1000;

      option-data = [{
        name = "domain-name-servers";
        data = "9.9.9.9, 149.112.112.112";
        always-send = true;
      }];

      subnet4 = [{
        id = 1;
        pools = [{ pool = "192.168.1.230 - 192.168.1.240"; }];

        option-data = [{
          name = "routers";
          data = "192.168.1.1";
        }];

        subnet = "192.168.1.0/24";
      }];
      valid-lifetime = 4000;
    };
  };
}
