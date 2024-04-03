#!/bin/bash

#The script converts LiveCD-iso-to-disk. By running this it will install the kernel and generate the grub.cfg and install the grub on the disk. The disk then can be attached to VM on GCP to prepare for a Disaster Recovery replication. 

# Script requires AWS Region, Disk name and a partition name.


echo "Enter the region name: "
read region_name

echo "Enter the Disk name i.e /dev/sda : "
read disk_name

echo "Enter the Partition name i.e /dev/sda1 : "
read part_name

if [ -z "$region_name" -o -z "$disk_name" -o -z "$part_name" ]; then
    echo "One or more input is missing, try again..."
    exit 1
fi

iso_name="/root/aws-failback-livecd-64bit.iso"


echo "Downloading Failback Client ISO"
wget -O aws-failback-livecd-64bit.iso https://aws-elastic-disaster-recovery-${region_name}.s3.${region_name}.amazonaws.com/latest/failback_livecd/aws-failback-livecd-64bit.iso

echo "Mounting the Downloaded Failback Client ISO to /mnt"
mount -v -o loop $iso_name /mnt
if [ $? -eq 0 ]; then echo "Mounted successfully"; else  echo "$iso_name is not mounted"; exit 1; fi

mkdir /squashfs /rootfs /secondery_root
if [ $? -eq 0 ]; then echo "mkdir successfully"; else  echo "mkdir failed"; exit 1; fi

mount -t squashfs /mnt/LiveOS/squashfs.img -o loop /squashfs
if [ $? -eq 0 ]; then echo "squashfs.img mounted successfully"; else  echo "squashfs.img not mounted"; exit 1; fi
mount /squashfs/LiveOS/rootfs.img /rootfs
if [ $? -eq 0 ]; then echo "rootfs.img mounted successfully"; else  echo "rootfs.img  not mounted"; exit 1; fi

echo "mounting the filesystem"
mount $part_name /secondery_root
if [ $? -eq 0 ]; then echo "$part_name mounted successfully"; else  echo "$part_name not mounted"; exit 1; fi

echo "Downloading the kernel"
yumdownloader kernel-4.14.268-205.500.amzn2.x86_64 || { echo "yumdownloader failed"; exit 1; }
cp kernel-* /secondery_root || { echo "cp kernel failed"; exit 1; }
cp -av /rootfs/* /secondery_root || { echo "cp rootfs failed"; exit 1; }

echo "Mounting /proc, /sys and /dev in /secondery_root"

mount -v -o bind /proc /secondery_root/proc || { echo "mount /proc failed"; exit 1; }
mount -v -o bind /sys /secondery_root/sys || { echo "mount /sys failed"; exit 1; }
mount -v  -o bind  /dev /secondery_root/dev || { echo "mount /dev failed"; exit 1; }

echo "installing kernel"
chroot /secondery_root/ rpm -ivh kernel-* --force || { echo "rpm installation inside chroot failed"; exit 1; }

echo "generating grub2.cfg"
chroot /secondery_root/ grub2-mkconfig -o /boot/grub2/grub.cfg || { echo "grub2.cfg creation inside chroot failed"; exit 1; }

echo "installing grub"
chroot /secondery_root/ grub2-install $disk_name || { echo "grub install inside chroot failed"; exit 1; }
