#!/bin/bash -x

set +e

# Install dependencies

# Backport cmake
# This will create a local backport and install it. Substitute almost any other package that has a newer DSC available.
sudo apt-get update -qq
sudo apt-get -y install devscripts
dget -x -u http://archive.ubuntu.com/ubuntu/pool/main/c/cmake/cmake_2.8.12.2-0ubuntu3.dsc
sudo apt-get build-dep cmake
cd cmake* && fakeroot dpkg-buildpackage -d
sudo dpkg -i ../cmake*deb

sudo add-apt-repository --yes ppa:ubuntu-sdk-team/ppa # for newer Qt
sudo apt-get update -qq
sudo apt-get -y install python-requests xorriso # TODO: Replace with something that does not need sudo
sudo apt-get -y install git g++ make autoconf libtool cmake pkg-config \
libxml2-dev libxslt1-dev libzip-dev libsqlite3-dev \
libusb-1.0-0-dev \
qt5-default qt5-qmake qtchooser qttools5-dev-tools libqt5svg5-dev \
libqt5webkit5-dev libqt5qml5 libqt5quick5 libqt5declarative5 \
qtscript5-dev libssh2-1-dev libcurl4-openssl-dev qttools5-dev \
qtconnectivity5-dev
 
APP=Subsurface
mkdir -p ./$APP/$APP.AppDir
cd ./$APP

git clone git://subsurface-divelog.org/subsurface
./subsurface/scripts/build.sh

rm -rf install-root/include
find install-root/
mv install-root $APP.AppDir/usr

cd $APP.AppDir/

cd ..

# Figure out $VERSION
#...
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
