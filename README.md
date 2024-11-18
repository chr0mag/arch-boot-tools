# arch boot tools

## update-arch-boot
Bash script to automatically download and install the current [Archboot](https://wiki.archlinux.org/title/Archboot) initrd and kernel files.

## Usage 
* run as root
```shell
./update-archboot.sh
```
* this will download the latest initramfs and kernel (vmlinuz), verify their signatures and install them to `/boot`.
* 
## systemd-boot-mkconfig
Bash script to update the kernel command line options for *systemd-boot* bootloader entries. This is essentially the poor man's *grub-mkconfig* for the *systemd* bootloader.

### Usage
* create */etc/cmdline* and add your kernel command line options to it on a single line
* an example might look like this
```
cryptdevice=/dev/mapper/VolumeGroup0-lvroot:root:allow-discards root=/dev/mapper/root rw init=/usr/lib/systemd/systemd fbcon=scrollback:128k
```
* copy the script to your desired location (eg. */usr/bin/local*) and make it executable
* run the script as root
```shell
./systemd-boot-mkconfig.sh
```

