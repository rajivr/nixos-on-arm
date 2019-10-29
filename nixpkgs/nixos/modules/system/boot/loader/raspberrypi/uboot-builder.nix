{ pkgs, hostPackages, version, configTxt }:

let
  isAarch64 = hostPackages.stdenv.hostPlatform.isAarch64;

  uboot = with hostPackages;
    if version == 0 then
      ubootRaspberryPiZero
    else if version == 1 then
      ubootRaspberryPi
    else if version == 2 then
      ubootRaspberryPi2
    else
      if isAarch64 then
        ubootRaspberryPi3_64bit
      else
        ubootRaspberryPi3_32bit;

  dtbs = {
    "0" = [
      "bcm2835-rpi-zero.dtb"
      "bcm2835-rpi-zero-w.dtb"
    ];
    "1" = [
      "bcm2835-rpi-a.dtb"
      "bcm2835-rpi-a-plus.dtb"
      "bcm2835-rpi-b.dtb"
      "bcm2835-rpi-b-plus.dtb"
      "bcm2835-rpi-b-rev2.dtb"
      "bcm2835-rpi-cm1-io1.dtb"
    ];
    "2" = [
      "bcm2836-rpi-2-b.dtb"
    ];
    "3" = [
      "broadcom/bcm2837-rpi-3-b.dtb"
      "broadcom/bcm2837-rpi-3-b-plus.dtb"
      "broadcom/bcm2837-rpi-cm3-io3.dtb"
    ];
  }."${toString version}";

  extlinuxConfBuilder = pkgs.callPackage
    ../generic-extlinux-compatible/extlinux-conf-builder.nix { inherit dtbs; };
in
pkgs.substituteAll {
  src = ./uboot-builder.sh;
  isExecutable = true;
  inherit (pkgs) bash;
  path = with pkgs; [coreutils gnused gnugrep];
  firmware = hostPackages.raspberrypifw;
  inherit uboot;
  inherit configTxt;
  inherit extlinuxConfBuilder;
  inherit version;
}
