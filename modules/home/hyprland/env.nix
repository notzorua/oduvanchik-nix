{ lib, osConfig, ... }:
let
  # Hyprland запускается через обёртку nixpkgs /run/wrappers/bin/Hyprland с cap_sys_nice
  # (programs.hyprland, ради SCHED_RR). Из-за capability процесс получает AT_SECURE, и glibc
  # при старте удаляет из окружения «небезопасные» переменные (UNSECURE_ENVVARS в
  # sysdeps/generic/unsecvars.h), — среди них TZDIR из environment.sessionVariables. Без неё
  # у всего, что запущено из Hyprland, часовой пояс Europe/Moscow превращался в UTC (+0000).
  # PAM (lightdm) переменные даёт верно: у start-hyprland они есть, теряются в самом Hyprland.
  # Возвращаем через hl.env — Hyprland передаёт своё окружение всему, что запускает.
  # LD_* и прочие не возвращаем: в sessionVariables их нет, а LD_* лучше не трогать.
  stripped = [
    "GCONV_PATH"
    "GETCONF_DIR"
    "HOSTALIASES"
    "LOCALDOMAIN"
    "LOCPATH"
    "NIS_PATH"
    "NLSPATH"
    "RESOLV_HOST_CONF"
    "RES_OPTIONS"
    "TMPDIR"
    "TZDIR"
  ];
  vars = lib.filterAttrs (name: _: lib.elem name stripped) osConfig.environment.sessionVariables;
  toValue = v: if lib.isList v then lib.concatStringsSep ":" v else toString v;
in
{
  wayland.windowManager.hyprland.extraConfig = lib.mkBefore (
    lib.concatMapAttrsStringSep "\n" (
      name: value: "hl.env(${builtins.toJSON name}, ${builtins.toJSON (toValue value)})"
    ) vars
  );
}
