{ extraPackages ? { }, ... }:
{
  default = final: _prev:
    let
      extraPackages' =
        extraPackages.${final.system} or { };
    in
    extraPackages' // { };
}

