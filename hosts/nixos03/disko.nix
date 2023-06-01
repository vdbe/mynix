{ disks ? [ "/dev/xvda" ], ... }: {
  disko.devices = {
    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [
          "defaults"
          "size=2G"
          "mode=755"
        ];
      };
    };
    disk.main = {
      device = builtins.elemAt disks 0;
      type = "disk";
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            name = "ESP";
            start = "1MiB";
            end = "128MiB";
            fs-type = "fat32";
            bootable = true;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          }
          {
            name = "root";
            start = "128MiB";
            end = "100%";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ]; # Override existing partition
              subvolumes = {
                "/@nix" = {
                  mountOptions = [ "compress=zstd:1" "noatime" ];
                  mountpoint = "/nix";
                };
                "/@persist" = {
                  mountOptions = [ "compress=zstd:1" "noatime" ];
                  mountpoint = "/persist";
                };
              };
            };
          }
        ];
      };
    };
  };
}
