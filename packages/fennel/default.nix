{ lib, stdenv, luajit, ... }:

let
  pname = "fennel";
  version = "1.3.0";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchTarball {
    url = "https://fennel-lang.org/downloads/${pname}-${version}.tar.gz";
    sha256 = "0wciqn0ayqjxaz58hxfavwf4j63vv1v2b4ki7qgzxvzx38yhl8jl";
  };

  buildInputs = [
    luajit
  ];

  phases = "installPhase";
  installPhase = ''
    mkdir -p $out $out/bin
    cp $src/fennel $out/bin/fennel
    cp $src/fennel.lua $out/fennel.lua
    chmod +x $out/bin/fennel
    sed -i 's%^#!/usr/bin/env lua$%#!${luajit}/bin/luajit%' $out/bin/fennel
  '';

  meta = {
    homepage = "https://github.com/bakpakin/Fennel";
    description = "Lua Lisp Language";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
