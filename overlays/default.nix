{ extraPackages ? { }, ... }:
{
  default = final: prev:
    let
      extraPackages' =
        if extraPackages ? ${final.system}
        then
          extraPackages.${final.system}
        else
          { };
    in
    extraPackages' // { };
}

