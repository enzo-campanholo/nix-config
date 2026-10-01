{
  disko.devices.disk.main = {
    device = "/dev/disk/by-id/nvme-CL4-3D256-Q11_NVMe_SSSTC_256GB_TW0M3TJT9DH00268037P";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          type = "EF00";
          size = "1G";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
