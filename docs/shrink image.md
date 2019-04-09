# Shrink Raspberry Pi Images using VirtualBox and KaliLinux
1. Install PiShrink script
	* Follow tutorial: https://linuxundich.de/raspberry-pi/pishrink-verkleinert-raspberry-pi-images/
2. Copy the big size image to SharedFolder into Linux Distribition using VirutalMaschine and KaliLinux
	* VBox GuestAdditions are required. 
	* Follow tutorial how to install additions and create SharedFolder: https://docs.kali.org/general-use/kali-linux-virtual-box-guest
2. Copy the Image inside the VM from SharedFolder (`/media/sf_SharedFolder/`) to Home folder, where the `pishrink.sh` script lays.
3. Remove error "Error: Can't have a partition outside the disk!" by adding one 512 bytes sector (Same problem as here: https://unix.stackexchange.com/questions/319922/error-cant-have-a-partition-outside-the-disk-even-though-number-of-sectors)
```
dd if=/dev/zero bs=512 count=1 >> honeypi-20181125-v0.0.3.img
```
4. Shrink image with PiShrink
```
sudo ./pishrink.sh ./honeypi-20181125-v0.0.3.img honeypi-20181125-v0.0.3-shrinked.img
```