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
# Fedora 22 (Twenty Two) - Fedora-Live-Workstation-x86_64-22-3.iso
# Ubuntu 15.04 (Vivid Vervet) - ubuntu-15.04-desktop-amd64.iso
# Ubuntu 14.04.1 LTS (Trusty Tahr) - ubuntu-14.04.1-desktop-amd64.iso
# Xubuntu 15.10 (Wily Werewolf) - xubuntu-15.10-desktop-amd64.iso
# openSUSE Tumbleweed (20151012) - openSUSE-Tumbleweed-GNOME-Live-x86_64-Current.iso
# Antergos - antergos-2014.08.07-x86_64.iso
# elementary OS 0.3 Freya - elementary_OS_0.3_freya_amd64.iso

# Install dependencies

sudo apt-get update -qq # Make sure universe is enabled
sudo apt-get -y install python-requests xorriso p7zip-full pax-utils imagemagick # TODO: Replace with something that does not need sudo
sudo apt-get -y install cmake git g++ make autoconf libtool pkg-config \
libxml2-dev libxslt1-dev libzip-dev libsqlite3-dev libusb-1.0-0-dev libssh2-1-dev libcurl4-openssl-dev \
mesa-common-dev libgl1-mesa-dev libgstreamer-plugins-base0.10-0 libxcomposite1

# Install newer gcc since qtserialbluetooth.cpp cannot be compiled with the stock gcc 4.6.3
sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
sudo apt-get -qq update
sudo apt-get -qq install g++-4.8
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.8 50
g++ --version
which g++

# Install CMake 3.2.2 and Qt 5.4.1 # https://github.com/vlc-qt/examples/blob/master/tools/ci/linux/install.sh
wget --no-check-certificate -c http://www.cmake.org/files/v3.2/cmake-3.2.2-Linux-x86_64.tar.gz
tar xf cmake-3.2.2-Linux-x86_64.tar.gz

# Quick and dirty way to download the latest Qt - is there an official one?
QT_URL=http://download.qt.io/online/qtsdkrepository/linux_x64/desktop/qt5_55
wget "$QT_URL/Updates.xml"
QTPACKAGES="qt5_essentials.7z qt5_addons.7z icu-linux-g.*?.7z qt5_qtscript.7z qt5_qtlocation.7z qt5_qtpositioning.7z"
for QTPACKAGE in $QTPACKAGES; do
  unset NAME V1 V2
  NAME=$(grep -Pzo "(?s)$QTPACKAGE" Updates.xml | head -n 1)
  V1=$(grep -Pzo "(?s)<PackageUpdate>.*?<Version>.*?<DownloadableArchives>.*?$QTPACKAGE.*?</PackageUpdate>" Updates.xml | grep "<Name>" | tail -n 1 | cut -d ">" -f 2 | cut -d "<" -f 1)
  V2=$(grep -Pzo "(?s)<PackageUpdate>.*?<Version>.*?<DownloadableArchives>.*?$QTPACKAGE.*?</PackageUpdate>" Updates.xml | grep "<Version>" | head -n 1 | cut -d ">" -f 2 | cut -d "<" -f 1)
  wget "$QT_URL/"$V1"/"$V2$NAME
done

# wget http://download.qt.io/online/qtsdkrepository/linux_x64/desktop/qt5_55/qt.55.gcc_64/5.5.0-2qt5_essentials.7z
# wget http://download.qt.io/online/qtsdkrepository/linux_x64/desktop/qt5_55/qt.55.gcc_64/5.5.0-2icu-linux-g++-Rhel6.6-x64.7z
# wget http://download.qt.io/online/qtsdkrepository/linux_x64/desktop/qt5_55/qt.55.gcc_64/5.5.0-2qt5_addons.7z
# wget http://download.qt.io/online/qtsdkrepository/linux_x64/desktop/qt5_55/qt.55.qtscript.gcc_64/5.5.0-0qt5_qtscript.7z
# wget http://download.qt.io/online/qtsdkrepository/linux_x64/desktop/qt5_55/qt.55.qtlocation.gcc_64/5.5.0-0qt5_qtlocation.7z

find *.7z -exec 7z x {} \;

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
mogrify -resize 64x64 $APP.AppDir/subsurface-icon.png

# Populate usr/share; app seems to pick up things from there
mkdir -p $APP.AppDir/usr/share/subsurface/data/
cp -Lr ./subsurface/build/Documentation $APP.AppDir/usr/share/subsurface/
cp -Lr ./subsurface/marbledata/maps $APP.AppDir/usr/share/subsurface/data/
cp -Lr ./subsurface/marbledata/bitmaps $APP.AppDir/usr/share/subsurface/data/
cp -Lr ./subsurface/printing_templates  $APP.AppDir/usr/share/subsurface/
mkdir -p $APP.AppDir/usr/share/subsurface/translations
cp -Lr ./subsurface/build/translations/*.qm $APP.AppDir/usr/share/subsurface/translations/

echo "############ Copy from here"
find .
echo "############ Copy from here"

# Bundle dependency libraries into the AppDir
cd $APP.AppDir/
wget -c "https://github.com/probonopd/AppImageKit/releases/download/3/AppRun" # (64-bit)
chmod a+x AppRun
# FIXME: How to find out which subset of plugins is really needed? I used strace when running the binary
mkdir -p ./usr/lib/qt5/plugins/
cp -r ../../5.5/gcc_64/plugins/bearer ./usr/lib/qt5/plugins/
cp -r ../../5.5/gcc_64/plugins/iconengines ./usr/lib/qt5/plugins/
cp -r ../../5.5/gcc_64/plugins/imageformats ./usr/lib/qt5/plugins/
cp -r ../../5.5/gcc_64/plugins/platforminputcontexts ./usr/lib/qt5/plugins/
cp -r ../../5.5/gcc_64/plugins/platforms ./usr/lib/qt5/plugins/
cp -r ../../5.5/gcc_64/plugins/platformthemes ./usr/lib/qt5/plugins/
cp -r ../../5.5/gcc_64/plugins/sensors ./usr/lib/qt5/plugins/
cp -r ../../5.5/gcc_64/plugins/xcbglintegrations ./usr/lib/qt5/plugins/
export LD_LIBRARY_PATH=./usr/lib/:../../5.5/gcc_64/lib/:$LD_LIBRARY_PATH
ldd usr/bin/subsurface | grep "=>" | awk '{print $3}'  |  xargs -I '{}' cp -v '{}' ./usr/lib || true
ldd usr/lib/qt5/plugins/platforms/libqxcb.so | grep "=>" | awk '{print $3}'  |  xargs -I '{}' cp -v '{}' ./usr/lib || true
rm -r usr/lib/cmake
rm usr/lib/libdivecomputer.a
rm usr/lib/libdivecomputer.la
rm usr/lib/libGrantlee_TextDocument.so
rm usr/lib/libGrantlee_TextDocument.so.5.0.0
rm usr/lib/libssrfmarblewidget.so
rm usr/lib/subsurface
rm usr/lib/libstdc* usr/lib/libgobject* usr/lib/libX* usr/lib/libc.so.*
strip usr/bin/* usr/lib/*
# According to http://www.grantlee.org/apidox/using_and_deploying.html
# Grantlee looks for plugins in $QT_PLUGIN_DIR/grantlee/$grantleeversion/
mv ./usr/lib/grantlee/ ./usr/lib/qt5/plugins/
# Fix GDK_IS_PIXBUF errors on older distributions
find /lib -name libpng*.so.* -exec cp {} ./usr/lib/libpng16.so.16 \;
ln -sf ./libpng16.so.16 ./usr/lib/libpng15.so.15 # For Fedora 20
ln -sf ./libpng16.so.16 ./usr/lib/libpng14.so.14 # Just to be sure
ln -sf ./libpng16.so.16 ./usr/lib/libpng13.so.13 # Just to be sure
ln -sf ./libpng16.so.16 ./usr/lib/libpng12.so.12 # Just to be sure
find /usr/lib -name libfreetype.so.6 -exec cp {} usr/lib \; # For Fedora 20
ln -sf ./libpng16.so.16 ./usr/lib/libpng12.so.0 # For the bundled libfreetype.so.6
cd -
find $APP.AppDir/

# Figure out $VERSION
GITVERSION=$(cd subsurface ; git describe | sed -e 's/-g.*$// ; s/^v//')
GITREVISION=$(echo $GITVERSION | sed -e 's/.*-// ; s/.*\..*//')
VERSION=$(echo $GITVERSION | sed -e 's/-/./')
echo $VERSION

# Convert the AppDir into an AppImage
wget -c "https://github.com/probonopd/AppImageKit/releases/download/3/AppImageAssistant" # (64-bit)
xorriso -indev ./AppImageAssistant* -osirrox on -extract / ./AppImageAssistant.AppDir
./AppImageAssistant.AppDir/package ./$APP.AppDir/ ./$APP"_"$VERSION"_x86_64.AppImage"

ls -lh ./$APP"_"$VERSION"_x86_64.AppImage"

# Upload from travis-ci to GitHub Releases
cd ..
wget https://raw.githubusercontent.com/probonopd/travis2github/master/travis2github.py
wget https://raw.githubusercontent.com/probonopd/travis2github/master/magic.py
python travis2github.py ./$APP/$APP"_"$VERSION"_x86_64.AppImage"
