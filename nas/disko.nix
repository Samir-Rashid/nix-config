# Use disko (https://github.com/nix-community/disko) to declare filesystem
# state. Warning! This wipes the drive and will write partitions!

# Example config: https://github.com/nix-community/disko/blob/master/example/zfs.nix
# Example system: https://github.com/djacu/nixos-config/blob/main/hosts/adalon/disko-config.nix
{
  disko.devices = {
    disk = {
      disk1 = {
        type = "disk";
        device = "/dev/disk/by-uuid/46b46ae9-32cf-4941-809b-f6781e4d1560";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            swap = {
              size = "16G";
              type = "8200";
              content = {
                type = "swap";
                resumeDevice = true; # resume from hiberation from this device
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        rootFsOptions = {
          acltype = "posixacl";
          canmount = "off";
          checksum = "edonr";
          compression = "lz4";
          dnodesize = "auto";
          # encryption does not appear to work in vm test; only use on real system
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          keylocation = "prompt";
          normalization = "formD";
          relatime = "on";
          xattr = "sa";
        };
        mountpoint = null;
        options = {
          ashift = "12";
          autotrim = "on";
        };

        datasets = {
          local = {
            type = "zfs_fs";
            options.canmount = "off";
          };

          safe = {
            type = "zfs_fs";
            options.canmount = "off";
          };

          "local/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options.mountpoint = "/";
            postCreateHook = ''
              zfs snapshot zroot/local/root@empty
            '';
          };

          "local/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options.mountpoint = "/nix";
          };

          # only safe/ datasets will be persisted
          # don't need to persist home folder for server
          #"safe/home" = {
          #  type = "zfs_fs";
          #  mountpoint = "/home";
          #  options.mountpoint = "/home";
          #};

          "safe/persist" = {
            type = "zfs_fs";
            mountpoint = "/persist";
            options.mountpoint = "/persist";
          };
        };
      };
    };
  };
}

