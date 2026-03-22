{ pkgs, host, ... }:
{
  programs.amnezia-vpn.enable = true;   
  networking = {
    nftables.enable = true;
    hostName = "${host}";
    networkmanager.enable = true;
    networkmanager.insertNameservers = [ "8.8.8.8" "1.1.1.1" ];
    nameservers = [
      "8.8.8.8"
      "8.8.4.4"
      "1.1.1.1"
    ];
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        80
        443
        59010
        59011
      ];
      allowedUDPPorts = [
        59010
        59011
      ];
    };
  };

  environment.systemPackages = with pkgs; [ networkmanagerapplet ];
}
