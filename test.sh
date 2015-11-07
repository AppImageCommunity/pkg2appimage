# Test AppImage on many distributions
# using Live CD ISO files

git clone https://github.com/probonopd/AppImageKit.git
cd AppImageKit

sudo apt-get install unionfs-fuse
cp /usr/bin/unionfs-fuse ./AppImageAssistant.AppDir/unionfs-fuse

rm -r log
sudo find /isodevice/boot/iso/*amd64*iso -exec bash ./AppImageAssistant.AppDir/testappimage {} /home/me/Downloads/Subsurface_4.5.1.109_x86_64.AppImage >> log 2>&1  \;
sudo find /isodevice/boot/iso/*_64*iso -exec bash ./AppImageAssistant.AppDir/testappimage {} /home/me/Downloads/Subsurface_4.5.1.109_x86_64.AppImage >> log 2>&1  \;

# Now have to close every Subsurface instance by hand
