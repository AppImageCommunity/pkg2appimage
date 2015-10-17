#!/bin/bash

# Subsurface AppImage build script by Simon Peter
# The purpose of this script is to build the current version of Subsurface (at Qt app) from git, and bundle it
# together with all required runtime dependencies that cannot reasonably be expected to be part of the operating
# system into an AppImage. An AppImage is an ISO file that contains an app and everything that is needed
# to run the app plus a small executable header that mounts the image and runs the app on the target system.
# See http://portablelinuxapps.org/docs/1.0/AppImageKit.pdf for more information.

# Resulting AppImage is known to work on:
# CentOS Linux 7 (Core) - CentOS-7.0-1406-x86_64-GnomeLive.iso
# CentOS Linux release 7.1.1503 (Core) - CentOS-7-x86_64-LiveGNOME-1503.iso
# Ubuntu 15.04 (Vivid Vervet) - ubuntu-15.04-desktop-amd64.iso
# Ubuntu 14.04.1 LTS (Trusty Tahr) - ubuntu-14.04.1-desktop-amd64.iso
# Fedora 22 (Twenty Two) - Fedora-Live-Workstation-x86_64-22-3.iso
# openSUSE Tumbleweed (20151012) - openSUSE-Tumbleweed-GNOME-Live-x86_64-Current.iso
# Antergos - antergos-2014.08.07-x86_64.iso
# elementary OS 0.3 Freya - elementary_OS_0.3_freya_amd64.iso

# Install dependencies

sudo apt-get update -qq
sudo apt-get -y install python-requests xorriso p7zip-full pax-utils # TODO: Replace with something that does not need sudo
sudo apt-get -y install cmake git g++ make autoconf libtool pkg-config \
libxml2-dev libxslt1-dev libzip-dev libsqlite3-dev libusb-1.0-0-dev libssh2-1-dev libcurl4-openssl-dev 

# Install newer gcc since qtserialbluetooth.cpp cannot be compiled with the stock gcc 4.6.3
sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
sudo apt-get -qq update
sudo apt-get -qq install g++-4.8
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.8 50
g++ --version
which g++

# Install CMake 3.2.2 and Qt 5.4.1 # https://github.com/vlc-qt/examples/blob/master/tools/ci/linux/install.sh
wget http://www.cmake.org/files/v3.2/cmake-3.2.2-Linux-x86_64.tar.gz
tar xf cmake-3.2.2-Linux-x86_64.tar.gz
wget http://download.qt.io/online/qtsdkrepository/linux_x64/desktop/qt5_55/qt.55.gcc_64/5.5.0-2qt5_essentials.7z
wget http://download.qt.io/online/qtsdkrepository/linux_x64/desktop/qt5_55/qt.55.gcc_64/5.5.0-2icu-linux-g++-Rhel6.6-x64.7z
wget http://download.qt.io/online/qtsdkrepository/linux_x64/desktop/qt5_55/qt.55.gcc_64/5.5.0-2qt5_addons.7z
wget http://download.qt.io/online/qtsdkrepository/linux_x64/desktop/qt5_55/qt.55.qtscript.gcc_64/5.5.0-0qt5_qtscript.7z
wget http://download.qt.io/online/qtsdkrepository/linux_x64/desktop/qt5_55/qt.55.qtlocation.gcc_64/5.5.0-0qt5_qtlocation.7z
7z x *_essentials.7z > /dev/null
7z x *icu-linux-*.7z > /dev/null
7z x *_addons.7z > /dev/null
7z x *_qtscript.7z > /dev/null
7z x *_qtlocation.7z > /dev/null
export PATH=$PWD/cmake-3.2.2-Linux-x86_64/bin/:$PWD/5.5/gcc_64/bin/:$PATH # Needed at compile time to find Qt and cmake
export LD_LIBRARY_PATH=$PWD/5.5/gcc_64/lib/:$LD_LIBRARY_PATH # Needed for bundling the libraries into AppDir below
find $PWD/5.5/gcc_64/lib/

APP=Subsurface
mkdir -p ./$APP/$APP.AppDir
cd ./$APP

git clone git://subsurface-divelog.org/subsurface
bash -x ./subsurface/scripts/build.sh

# Move build products into the AppDir
rm -rf install-root/include
mv install-root $APP.AppDir/usr
cp ./subsurface/build/subsurface $APP.AppDir/usr/bin
cp ./subsurface/subsurface.desktop $APP.AppDir/
cp ./subsurface/icons/subsurface-icon.png $APP.AppDir/

# Populate usr/share; app seems to pick up things from there
mkdir -p $APP.AppDir/usr/share/subsurface/data/
cp -Lr ./subsurface/build/Documentation $APP.AppDir/usr/share/subsurface/
cp -Lr ./subsurface/marbledata/maps $APP.AppDir/usr/share/subsurface/data/
cp -Lr ./subsurface/marbledata/bitmaps $APP.AppDir/usr/share/subsurface/data/
echo "############ Copy from here"
find .
echo "############ Copy from here"

# Bundle dependency libraries into the AppDir
cd $APP.AppDir/
wget -c "https://github.com/probonopd/AppImageKit/releases/download/1/AppRun" # (64-bit)
chmod a+x AppRun
# FIXME: How to find out which subset of plugins is really needed? I used strace when running the binary
cp -r ../../5.5/gcc_64/plugins/bearer usr/bin
cp -r ../../5.5/gcc_64/plugins/iconengines usr/bin
cp -r ../../5.5/gcc_64/plugins/imageformats usr/bin
cp -r ../../5.5/gcc_64/plugins/platforminputcontexts usr/bin
cp -r ../../5.5/gcc_64/plugins/platforms usr/bin
cp -r ../../5.5/gcc_64/plugins/platformthemes usr/bin
cp -r ../../5.5/gcc_64/plugins/sensors usr/bin
cp -r ../../5.5/gcc_64/plugins/xcbglintegrations usr/bin
lddtree usr/bin/subsurface
lddtree usr/bin/subsurface | grep "=>" | awk '{print $3}' | grep -ve "^/lib" | xargs -I '{}' cp -v '{}' ./usr/lib
# FIXME: For whatever strange reason these are not caught by the above; are they coming from the plugins?
cp /lib/x86_64-linux-gnu/libssl.so.1.0.0 usr/lib
cp /lib/x86_64-linux-gnu/libcrypto.so.1.0.0 usr/lib
cp -a ../../5.5/gcc_64/lib/libicu* usr/lib
find /usr/lib -name libssh2.so.1 -exec cp {} usr/lib \;
find /lib -name libgcrypt.so.11 -exec cp {} usr/lib \;
find /lib -name libselinux.so.1 -exec cp {} usr/lib \;
find /usr/lib -name libcurl.so.4 -exec cp {} usr/lib \;
find /lib -name libselinux.so.1 -exec cp {} usr/lib \; # Needed e.g., for Arch/Antergos (better would be to compile w/o it)
find /usr/lib -name librtmp.so.0 -exec cp {} usr/lib \; # Needed e.g., for Arch/Antergos
find /usr/lib -name libtasn1.so.3 -exec cp {} usr/lib \; # Needed e.g., for Fedora 22
find /usr/lib -name libgnutls.so.26 -exec cp {} usr/lib \; # Needed by librtmp.so.0
cp ../../5.5/gcc_64/lib/libQt5*.so.5 usr/lib # Bundle Qt libraries; delete the extraneous ones below
rm -r usr/lib/cmake
rm -r usr/lib/grantlee
rm usr/lib/libdivecomputer.a
rm usr/lib/libdivecomputer.la
rm usr/lib/libGrantlee_Templates.so
rm usr/lib/libGrantlee_TextDocument.so
rm usr/lib/libGrantlee_TextDocument.so.5
rm usr/lib/libGrantlee_TextDocument.so.5.0.0
rm usr/lib/libQt5CLucene.so.5
rm usr/lib/libQt5DesignerComponents.so.5
rm usr/lib/libQt5Designer.so.5
rm usr/lib/libQt5Help.so.5
rm usr/lib/libQt5Location.so.5
rm usr/lib/libQt5MultimediaQuick_p.so.5
rm usr/lib/libQt5Multimedia.so.5
rm usr/lib/libQt5MultimediaWidgets.so.5
rm usr/lib/libQt5Nfc.so.5
rm usr/lib/libQt5QuickParticles.so.5
rm usr/lib/libQt5QuickTest.so.5
rm usr/lib/libQt5QuickWidgets.so.5
rm usr/lib/libQt5ScriptTools.so.5
rm usr/lib/libQt5SerialPort.so.5
rm usr/lib/libQt5Test.so.5
rm usr/lib/libQt5WebSockets.so.5
rm usr/lib/libQt5X11Extras.so.5
rm usr/lib/libQt5XmlPatterns.so.5
rm usr/lib/libssrfmarblewidget.so

rm usr/lib/libstdc* usr/lib/libgobject* usr/lib/libX*
cd -
find $APP.AppDir/

# Figure out $VERSION
GITVERSION=$(cd subsurface ; git describe | sed -e 's/-g.*$// ; s/^v//')
GITREVISION=$(echo $GITVERSION | sed -e 's/.*-// ; s/.*\..*//')
VERSION=$(echo $GITVERSION | sed -e 's/-/./')
echo $VERSION

wget -c "https://github.com/probonopd/AppImageKit/releases/download/1/AppImageAssistant" # (64-bit)

xorriso -indev ./AppImageAssistant* -osirrox on -extract / ./AppImageAssistant.AppDir
./AppImageAssistant.AppDir/package ./$APP.AppDir/ ./$APP"_"$VERSION"_x86_64.AppImage"

ls -lh ./$APP"_"$VERSION"_x86_64.AppImage"

# Upload
cd ..
wget https://raw.githubusercontent.com/probonopd/travis2github/master/travis2github.py
wget https://raw.githubusercontent.com/probonopd/travis2github/master/magic.py
python travis2github.py ./$APP/$APP"_"$VERSION"_x86_64.AppImage"
