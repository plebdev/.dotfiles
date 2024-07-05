#make sure booting in UEFI
#fdisk -l
#cgdisk /dev/sda
#600MB ef00 boot, rest 8300 system
#mkfs.fat -F32 /dev/sda1
#mkfs.ext4 /dev/sda2
#mount /dev/sda2 /mnt
#mkdir /mnt/boot
#mount /dev/sda1 /mnt/boot
#iwctl
#device list
#device name set-property Powered on
#adapter adapter set-property Powered on
#station name scan
#station name get-networks
#station name connect SSID

if [ "$(pwd)" != "/mnt" ]; then
    pacstrap /mnt base base-devel linux linux-firmware grub efibootmgr dhcpcd iwctl git

    genfstab -U /mnt >> /mnt/etc/fstab

    cp "$0" /mnt

    arch-chroot /mnt

    exit
fi

HOSTNAME=lappy
USER=geo
INTERFACE=wlan0

grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

grub-mkconfig -o /boot/grub/grub.cfg

ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime

hwclock --systohc

echo en_US.UTF-8 UTF-8 >> /etc/locale.genfstab

locale-gen

echo LANG=en_US.UTF-8 > /etc/locale.conf

touch /etc/hostname

echo $HOSTNAME > /etc/hostname

touch /etc/hosts
echo "127.0.0.1 localhost
::1 localhost
127.0.1.1 $HOSTNAME.localdomain $HOSTNAME" > /etc/hosts

systemctl enable dhcpcd@$INTERFACE.service

useradd -g users -G wheel,power,storage -m $USER
echo "$USER ALL=(ALL) ALL" >> /etc/sudoers

echo "Setting root password"
passwd
echo "Setting $USER password"
passwd $USER
