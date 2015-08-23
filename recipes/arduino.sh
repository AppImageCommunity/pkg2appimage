#!/bin/bash -x

set +e

# Install dependencies
sudo apt-get update
sudo apt-get -y install python-requests xorriso # TODO: Replace with something that does not need sudo

URL="http://downloads.arduino.cc/arduino-nightly-linux64.tar.xz"
APP=Arduino
mkdir -p ./$APP/$APP.AppDir
cd ./$APP

wget -c "$URL"

tar xfv *.tar.xz
mv ardu*/* $APP.AppDir

cd $APP.AppDir/

mv arduino AppRun
cp lib/arduino_small.png arduino.png
sed -i -e 's|FULL_PATH/||g' arduino.desktop

cd ..

# (64-bit)
wget -c "https://github.com/probonopd/AppImageKit/releases/download/1/AppImageAssistant"

xorriso -indev ./AppImageAssistant* -osirrox on -extract / ./AppImageAssistant.AppDir
./AppImageAssistant.AppDir/package ./$APP.AppDir/ $APP.AppImage

ls -lh ./$APP.AppImage

# Upload
cd ..
wget https://raw.githubusercontent.com/probonopd/travis2github/master/travis2github.py
wget https://raw.githubusercontent.com/probonopd/travis2github/master/magic.py
python travis2github.py ./$APP.AppImage
