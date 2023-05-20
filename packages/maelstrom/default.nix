{ lib, stdenv, jre, fennel, runtimeShell, ... }:

let
  pname = "maelstrom";
  version = "0.2.3";

  tag = "v${version}";
in
stdenv.mkDerivation {
  inherit pname version;

  myWrapper = ''
    #!${runtimeShell}
    exec "${jre}/bin/java" -Djava.awt.headless=true -jar "${placeholder "out"}/lib/maelstrom.jar" "$@"
  '';

  src = fetchTarball {
    url = "https://github.com/jepsen-io/maelstrom/releases/download/${tag}/${pname}.tar.bz2";
    sha256 = "1hkczlbgps3sl4mh6hk49jimp6wmks8hki0bqijxsqfbf0hcakwq";
  };

  buildInputs = [ fennel ];
  passAsFile = [ "myWrapper" ];

  phases = "installPhase";
  installPhase = ''
    mkdir -p "$out/bin"
    cp -r $src/lib $out/lib

    cp $myWrapperPath $out/bin/maelstrom
    chmod +x $out/bin/maelstrom

  '';

  meta = {
    homepage = "https://github.com/jepsen-io/maelstrom";
    description = "Workbench for writing toy implementations of distributed systems";
    license = lib.licenses.epl10;
    maintainers = [ ];
  };
}
