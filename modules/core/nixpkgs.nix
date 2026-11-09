{ pkgs, inputs, ... }:
{
  nixpkgs = {
    overlays = [
      (
        final: prev:
        (import ../../pkgs {
          inherit inputs;
          inherit pkgs;
          inherit (prev) system;
        })
      )
      inputs.nur.overlays.default
      inputs.millennium.overlays.default

      # ВРЕМЕННО: scooter 0.10.0 не собирается — onig_sys ищет системный oniguruma
      # через pkg-config (RUSTONIG_SYSTEM_LIBONIG), а pkg-config в derivation нет.
      # Issue: https://github.com/NixOS/nixpkgs/issues/585399
      # Фикс:  https://github.com/NixOS/nixpkgs/pull/584958 (влит в master 08.11.2026).
      # Убрать, когда PR дойдёт до nixos-unstable: иначе pkg-config/oniguruma в списках
      # задвоятся (сборке не мешает, но overlay станет лишним).
      (final: prev: {
        scooter = prev.scooter.overrideAttrs (old: {
          nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ final.pkg-config ];
          buildInputs = (old.buildInputs or [ ]) ++ [ final.oniguruma ];
        });
      })
    ];
  };
}
