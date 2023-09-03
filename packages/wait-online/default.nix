{ lib, stdenv, rustPlatform, fetchFromGitHub, cargo, rustc, ... }:

let
  pname = "wait-online";
  version = "0.1.1";

  tag = "v${version}";
in
stdenv.mkDerivation rec {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "vdbe";
    repo = pname;
    rev = "refs/tags/${tag}";
    sha256 = "sha256-hbNer/tmoikqreQms1RaXaHpu0VbaJMdGSVvDIu5Dy8=";
  };

  cargoDeps = rustPlatform.importCargoLock {
    lockFile = "${src}/Cargo.lock";
  };

  nativeBuildInputs = [
    cargo
    rustc
    rustPlatform.cargoSetupHook
  ];

  makeFlags = [ "prefix=$(out)" ];

  meta = {
    homepage = "https://github.com/vdbe/wait-online/";
    description = "A program that waits untill all interfaces are up";
    platforms = lib.platforms.linux;
    maintainers = [ ];
  };
}
