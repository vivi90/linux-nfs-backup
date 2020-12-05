# Backup & Restore scripts
This scripts are written to backup and restore a choosen directory on an [Linux](https://en.wikipedia.org/wiki/Linux) operating system, if the backup destination is an [NFS](https://en.wikipedia.org/wiki/Network_File_System) network storage ([NAS](https://en.wikipedia.org/wiki/Network-attached_storage)).

## Requirements
 * [DAR](http://dar.linux.free.fr)
 * NFS support
 * GnuPG v2.1 or higher
 * Super user rights

## Preparations
Create an suitable symmetric key file (for example by issuing `sudo openssl rand -out /home/backup_key_$USER.txt -base64 32 && sudo chmod 600 backup_key_$USER.txt`).

## Test conditions
 * DAR: v2.6.12
 * OS: [Manjaro](https://manjaro.org) 20.2 with Kernel 5.9
 * NAS: [D-Link DNS-323](https://eu.dlink.com/uk/en/products/dns-323-sharecenter-2-bay-network-storage-enclosure) with official firmware (v1.10) and NFS package (v1.01).

## License
This project is free software under the terms of the MIT license.  
For more details please see the LICENSE file or: [OpenSource.org](https://opensource.org/licenses/MIT)

## Credits
 * Git repository: [GitHub.com](https://github.com/vivi90/linux-nfs-backup.git)
