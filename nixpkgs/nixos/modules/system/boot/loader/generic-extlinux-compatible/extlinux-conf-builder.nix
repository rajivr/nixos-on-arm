{ substituteAll, bash, coreutils, gnused, gnugrep
, dtbs }:

substituteAll {
  src = ./extlinux-conf-builder.sh;
  isExecutable = true;
  path = [coreutils gnused gnugrep];
  inherit bash dtbs;
}
