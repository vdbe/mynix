[
  (_final: _prev:
    let
      my = import <mypkgs> { };
    in
    { inherit my; })

  (_final: _prev:
    let
      unstable = import <nixpkgs-unstable> { };
    in
    { inherit unstable; })
]
