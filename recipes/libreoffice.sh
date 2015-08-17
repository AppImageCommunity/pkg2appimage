#!/bin/bash -x

set +e

sudo apt-get install xorriso # TODO: Replace with something that does not need sudo

VERSION=$(wget "http://www.libreoffice.org/download/libreoffice-fresh/" -O - | grep -o -e "/dl/src/.*/all/" | cut -d "/" -f 4 | head -n 1)
OOODOWNLOADLINK="http://download.documentfoundation.org/libreoffice/stable/"$VERSION"/deb/x86_64/LibreOffice_"$VERSION"_Linux_x86-64_deb.tar.gz"
mkdir -p ./ooo/ooo.AppDir
cd ./ooo

wget -c "$OOODOWNLOADLINK"

tar xfvz *.tar.gz
# rm *.tar.gz

cd ooo.AppDir/

find ../ -name *.deb -exec dpkg -x \{\} . \;

find . -name startcenter.desktop -exec cp \{\} . \;

find -name *startcenter.png -path *hicolor*48x48* -exec cp \{\} . \;

BINARY=$(cat *.desktop | grep "Exec=" | head -n 1 | cut -d "=" -f 2 | cut -d " " -f 1)

# sed -i -e 's|/opt|../opt|g' ./usr/bin/$BINARY
mkdir -p usr/bin/
cd usr/bin/
rm ./$BINARY
find ../../opt -name soffice -path *program* -exec ln -s \{\} ./$BINARY \;
cd ../../

# (64-bit)
wget -c "https://github.com/probonopd/AppImageKit/releases/download/1/AppRun"
chmod a+x ./AppRun

cd ..

# (64-bit)
wget -c "https://github.com/probonopd/AppImageKit/releases/download/1/AppImageAssistant"

xorriso -indev ./AppImageAssistant* -osirrox on -extract / ./AppImageAssistant.AppDir
./AppImageAssistant.AppDir/package ./ooo.AppDir/ ooo.AppImage
