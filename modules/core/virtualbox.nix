{ username, ... }:
{
  # VirtualBox с Extension Pack: USB 2.0/3.0 в гостевой системе (FPGA USB-Blaster
  # для лабораторных). С ним пакет не берётся из кэша, а собирается из исходников.
  # Одновременно с виртуалками libvirt/KVM не запускать: VT-x занят.
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  users.users.${username}.extraGroups = [ "vboxusers" ];
}
