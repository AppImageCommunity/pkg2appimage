#!/bin/bash -x

set +e

# Install dependencies

sudo apt-get update -qq
sudo apt-get -y install python-requests xorriso p7zip-full # TODO: Replace with something that does not need sudo
sudo apt-get -y install cmake git g++ make autoconf libtool pkg-config \
libxml2-dev libxslt1-dev libzip-dev libsqlite3-dev libusb-1.0-0-dev libssh2-1-dev libcurl4-openssl-dev 

# Install CMake 3.2.2 and Qt 5.4.1 # https://github.com/vlc-qt/examples/blob/master/tools/ci/linux/install.sh
wget http://www.cmake.org/files/v3.2/cmake-3.2.2-Linux-x86_64.tar.gz
tar xf cmake-3.2.2-Linux-x86_64.tar.gz
wget http://download.qt.io/online/qtsdkrepository/linux_x64/desktop/qt5_55/qt.55.gcc_64/5.5.0-2qt5_essentials.7z
# wget http://download.qt.io/online/qtsdkrepository/linux_x64/desktop/qt5_54/qt.54.gcc_64/5.4.1-0qt5_essentials.7z.sha1
#wget http://download.qt.io/online/qtsdkrepository/linux_x64/desktop/qt5_54/qt.54.gcc_64/5.4.1-0icu_53_1_ubuntu_11_10_64.7z
#wget http://download.qt.io/online/qtsdkrepository/linux_x64/desktop/qt5_54/qt.54.gcc_64/5.4.1-0icu_53_1_ubuntu_11_10_64.7z.sha1
wget http://download.qt.io/online/qtsdkrepository/linux_x64/desktop/qt5_55/qt.55.gcc_64/5.5.0-2qt5_addons.7z
#wget http://download.qt.io/online/qtsdkrepository/linux_x64/desktop/qt5_54/qt.54.gcc_64/5.4.1-0qt5_addons.7z.sha1
7z x 5.4.1-0qt5_essentials.7z > /dev/null
7z x 5.4.1-0icu_53_1_ubuntu_11_10_64.7z > /dev/null
7z x 5.4.1-0qt5_addons.7z > /dev/null
export PATH=$PWD/cmake-3.2.2-Linux-x86_64/bin/:$PWD/5.4/gcc_64/bin/:$PATH

APP=Subsurface
mkdir -p ./$APP/$APP.AppDir
cd ./$APP

git clone git://subsurface-divelog.org/subsurface
bash -x ./subsurface/scripts/build.sh
cd ./subsurface/build/
make VERBOSE=1
cd -

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
