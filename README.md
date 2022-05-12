parted -s /dev/sdxxx  \
    mklabel gpt \
    unit mib mkpart auto-backup-disk 1 100% \
    set 1 lvm on

cryptsetup -y -v --type luks2 luksFormat /dev/disk/by-partlabel/auto-backup-disk

cryptsetup luksOpen  /dev/disk/by-partlabel/auto-backup-disk auto-backup-disk-opened

mkfs -t btrfs  --label auto-backup-disk-filesystem /dev/mapper/auto-backup-disk-opened



mkdir /media/auto-backup-disk-mounted
mkdir /media/auto-backup-disk-mounted-subvolume-root
mkdir /media/auto-backup-disk-mounted-subvolume-home
mkdir /media/auto-backup-disk-mounted-subvolume-photos

mount -t btrfs /dev/disk/by-label/auto-backup-disk-filesystem /media/auto-backup-disk-mounted

btrfs subvolume create                                        /media/auto-backup-disk-mounted/root
btrfs subvolume create                                        /media/auto-backup-disk-mounted/home
btrfs subvolume create                                        /media/auto-backup-disk-mounted/photos

umount /media/auto-backup-disk-mounted

mount -t btrfs -o subvol=root   /dev/disk/by-label/auto-backup-disk-filesystem /media/auto-backup-disk-mounted-subvolume-root
mount -t btrfs -o subvol=home   /dev/disk/by-label/auto-backup-disk-filesystem /media/auto-backup-disk-mounted-subvolume-home
mount -t btrfs -o subvol=photos /dev/disk/by-label/auto-backup-disk-filesystem /media/auto-backup-disk-mounted-subvolume-photos
