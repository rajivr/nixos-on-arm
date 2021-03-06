{ config, lib, pkgs, ... }:

with lib;

let
  blCfg = config.boot.loader;
  cfg = blCfg.generic-extlinux-compatible;

  timeoutStr = if blCfg.timeout == null then "-1" else toString blCfg.timeout;

  makeBuilder = pkgs: pkgs.callPackage ./extlinux-conf-builder.nix { dtbs = cfg.dtbs; };
  builder = makeBuilder pkgs;
  nativeBuilder = makeBuilder pkgs.buildPackages;
in
{
  options = {
    boot.loader.generic-extlinux-compatible = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = ''
          Whether to generate an extlinux-compatible configuration file
          under <literal>/boot/extlinux.conf</literal>.  For instance,
          U-Boot's generic distro boot support uses this file format.

          See <link xlink:href="http://git.denx.de/?p=u-boot.git;a=blob;f=doc/README.distro;hb=refs/heads/master">U-boot's documentation</link>
          for more information.
        '';
      };

      dtbs = mkOption {
        default = [];
        type = types.listOf types.string;
        description = ''
          which DTBs to install to the boot partition,
          if the list is empty the script will copy over all DTBs.
        '';
      };

      configurationLimit = mkOption {
        default = 20;
        example = 10;
        type = types.int;
        description = ''
          Maximum number of configurations in the boot menu.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    system.build = let
      makeInstaller = b: "${b} -g ${toString cfg.configurationLimit} -t ${timeoutStr} -c";
    in {
      installBootLoader = makeInstaller builder;
      installBootLoaderNative = makeInstaller nativeBuilder;
    };
    system.boot.loader.id = "generic-extlinux-compatible";
  };
}
