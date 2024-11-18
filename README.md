# systemd-boot-mkconfig
Bash script to update the kernel command line options for systemd-boot bootloader entries.

## Usage
* create */etc/cmdline* and add your kernel command line options to it
* an example might look like this
```
cryptdevice=/dev/mapper/VolumeGroup0-lvroot:root:allow-discards root=/dev/mapper/root rw init=/usr/lib/systemd/systemd fbcon=scrollback:128k
```
* copy the script to */usr/bin/local* and make it executable

