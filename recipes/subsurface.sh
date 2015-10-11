#!/bin/bash

# The purpose of this script is to build the current version of Subsurface (at Qt app) from git, and bundle it
# together with all required runtime dependencies that cannot reasonably expected to be part of the operating
# system into an AppImage. An AppImage is an ISO file that contains an app and everything that is needed
# to run the app plus a small executable header that mounts the image and runs the app on the target system.

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

APP=Subsurface
mkdir -p ./$APP/$APP.AppDir
cd ./$APP

git clone git://subsurface-divelog.org/subsurface
bash -x ./subsurface/scripts/build.sh
find .

# Move build products into the AppDir
rm -rf install-root/include
mv install-root $APP.AppDir/usr
cp ./subsurface/subsurface.desktop $APP.AppDir/

# Bundle dependency libraries into the AppDir
cd $APP.AppDir/
lddtree usr/bin/subsurface | grep "=>" | awk '{print $3}' | grep -ve "^/usr\|^/lib" | xargs -I '{}' cp -v '{}' ./usr/lib
cd -

# TODO: Bundle other Qt runtime dependencies into the AppDir

find $APP.AppDir/

# Figure out $VERSION
GITVERSION=$(cd subsurface ; git describe | sed -e 's/-g.*$// ; s/^v//')
GITREVISION=$(echo $GITVERSION | sed -e 's/.*-// ; s/.*\..*//')
VERSION=$(echo $GITVERSION | sed -e 's/-/./')
echo $VERSION

# (64-bit)
wget -c "https://github.com/probonopd/AppImageKit/releases/download/1/AppImageAssistant"

xorriso -indev ./AppImageAssistant* -osirrox on -extract / ./AppImageAssistant.AppDir
./AppImageAssistant.AppDir/package ./$APP.AppDir/ "$APP_$VERSION.AppImage"

ls -lh ./$APP.AppImage

# Upload
cd ..
wget https://raw.githubusercontent.com/probonopd/travis2github/master/travis2github.py
wget https://raw.githubusercontent.com/probonopd/travis2github/master/magic.py
python travis2github.py "$APP_$VERSION.AppImage"
