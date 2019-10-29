{ pkgs, hostPackages, configTxt }:

pkgs.substituteAll {
  src = ./raspberrypi-builder.sh;
  isExecutable = true;
  inherit (pkgs) bash;
  path = with pkgs; [coreutils gnused gnugrep];
  firmware = hostPackages.raspberrypifw;
  inherit configTxt;
}
