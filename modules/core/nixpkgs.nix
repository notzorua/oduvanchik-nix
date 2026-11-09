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

      # ВРЕМЕННО: nix-web 0.4.2 не собирается — libsqlite3-sys (через sqlx) теперь
      # линкуется с системной sqlite вместо встроенной копии, а sqlite в buildInputs нет:
      # «cannot find -lsqlite3». pkg-config в derivation уже есть.
      # Трекинг: https://github.com/NixOS/nixpkgs/issues/570940 (пункт nix-web);
      # отдельного issue/PR на 09.11.2026 нет. Убрать, когда починят в nixpkgs.
      (final: prev: {
        nix-web = prev.nix-web.overrideAttrs (old: {
          buildInputs = (old.buildInputs or [ ]) ++ [ final.sqlite ];
        });
      })
    ];
  };
}
