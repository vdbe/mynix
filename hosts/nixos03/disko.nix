{ disks ? [ "/dev/sda" ], ... }: {
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
            name = "luks";
            start = "128MiB";
            end = "100%";
            content = {
              type = "luks";
              name = "crypted";
              extraFormatArgs = [
                "--type luks2"
                "--cipher aes-xts-plain64"
                "--hash sha512"
                "--pbkdf argon2id"
                "--use-random"
              ];
              extraOpenArgs = [ "--allow-discards" ];
              # if you want to use the key for interactive login be sure there is no trailing newline
              # for example use `echo -n "password" > /tmp/secret.key`
              keyFile = "/root/secret.key";
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
            };
          }
          # {
          #   name = "root";
          #   start = "128MiB";
          #   end = "100%";
          #   content = {
          #     type = "btrfs";
          #     extraArgs = [ "-f" ]; # Override existing partition
          #     subvolumes = {
          #       "/@nix" = {
          #         mountOptions = [ "compress=zstd:1" "noatime" ];
          #         mountpoint = "/nix";
          #       };
          #       "/@persist" = {
          #         mountOptions = [ "compress=zstd:1" "noatime" ];
          #         mountpoint = "/persist";
          #       };
          #     };
          #   };
          # }
        ];
      };
    };
  };
}
