#!/bin/bash

# Test AppImage on many distributions
# using Live CD ISO files

sudo apt-get -y install git unionfs-fuse

git clone https://github.com/probonopd/AppImageKit.git

rm -r log

# Test 64-bit AppImage
sudo find /isodevice/boot/iso/*amd64*iso -exec bash ./AppImageKit/AppImageAssistant.AppDir/testappimage {} $HOME/Downloads/Subsurface_*_x86_64.AppImage >> log 2>&1  \;
sudo find /isodevice/boot/iso/*_64*iso -exec bash ./AppImageKit/AppImageAssistant.AppDir/testappimage {} $HOME/Downloads/Subsurface_*_x86_64.AppImage >> log 2>&1  \;

# Test 32-bit AppImage; works on a 64-bit host
sudo find /isodevice/boot/iso/*i386*iso -exec linux32 ./AppImageKit/AppImageAssistant.AppDir/testappimage {} $HOME/Downloads/Subsurface_*_i386.AppImage >> log 2>&1  \;
sudo find /isodevice/boot/iso/*i686*iso -exec linux32 ./AppImageKit/AppImageAssistant.AppDir/testappimage {} $HOME/Downloads/Subsurface_*_i386.AppImage >> log 2>&1  \;

# Now have to close every Subsurface instance by hand

# To get a summary
grep -r SUCCESS log | cut -d " " -f 3 | cut -d "/" -f 5 | sort | uniq
