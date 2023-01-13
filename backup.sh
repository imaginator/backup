#!/bin/bash
set -xe

if [ ! -b /dev/mapper/auto-backup-disk-opened ] ; then
  cryptsetup luksOpen  /dev/disk/by-partlabel/auto-backup-disk auto-backup-disk-opened
fi

if [ ! -d /media/auto-backup-disk-mounted-subvolume-root  ] ; then
  mkdir /media/auto-backup-disk-mounted-subvolume-root 
fi
mount -t btrfs -o subvol=root  /dev/disk/by-label/auto-backup-disk-filesystem              /media/auto-backup-disk-mounted-subvolume-root 
  btrfs subvolume snapshot -r / /.snapshots/backup-script-snapshot
    ionice -c 3 rsync --delete --delete-excluded -aAvx /.snapshots/backup-script-snapshot/  /media/auto-backup-disk-mounted-subvolume-root --exclude=".snapshot/" 
  btrfs subvolume delete /.snapshots/backup-script-snapshot 
umount /media/auto-backup-disk-mounted-subvolume-root

if [ ! -d /media/auto-backup-disk-mounted-subvolume-home  ] ; then
  mkdir /media/auto-backup-disk-mounted-subvolume-home
fi
mount -t btrfs -o subvol=home   /dev/disk/by-label/auto-backup-disk-filesystem /media/auto-backup-disk-mounted-subvolume-home
  btrfs subvolume snapshot -r /home /home/.snapshots/backup-script-snapshot 
    ionice -c 3 rsync --delete --delete-excluded -aAvx /home/.snapshots/backup-script-snapshot/ /media/auto-backup-disk-mounted-subvolume-home --exclude=".snapshot/" 
  btrfs subvolume delete /home/.snapshots/backup-script-snapshot 
umount /media/auto-backup-disk-mounted-subvolume-home

if [ ! -d /media/auto-backup-disk-mounted-subvolume-photos ] ; then
  mkdir /media/auto-backup-disk-mounted-subvolume-photos
fi
mount -t btrfs -o subvol=photos /dev/disk/by-label/auto-backup-disk-filesystem /media/auto-backup-disk-mounted-subvolume-photos
  btrfs subvolume snapshot -r /srv/photos /srv/photos/.snapshots/backup-script-snapshot 
    ionice -c 3 rsync --delete --delete-excluded -aAvx /srv/photos/.snapshots/backup-script-snapshot/ /media/auto-backup-disk-mounted-subvolume-photos --exclude=".snapshot/" 
  btrfs subvolume delete /srv/photos/.snapshots/backup-script-snapshot 
umount /media/auto-backup-disk-mounted-subvolume-photos

cryptsetup luksClose  auto-backup-disk-opened

# spindown after 5 mins
sdparm --flexible -6 -l --save --set SCT=6000,STANDBY=1 /dev/disk/by-partlabel/auto-backup-disk
