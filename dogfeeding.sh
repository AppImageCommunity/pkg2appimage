#!/bin/bash

# Eating our own dogfood. Preparing an AppImage of pkg2appimage

HERE="$(dirname "$(readlink -f "${0}")")"

. ./functions.sh

mkdir -p build/

cd build/
# apt download -y apt libapt-pkg5.0 libbz2-1.0 liblzma5 multiarch-support zlib1g dpkg
apt download -y dpkg # We are still using dpkg-deb to extract debs, so we need to bundle it

wget -c "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-$SYSTEM_ARCH.AppImage" # FIXME: Make arch independent
wget -c "https://github.com/ImageMagick/ImageMagick/releases/download/7.0.8-17/ImageMagick-0b0ce48-gcc-$SYSTEM_ARCH.AppImage" # FIXME: Make arch independent
chmod +x ./*.AppImage

./appimagetool-*.AppImage --appimage-extract && mv ./squashfs-root ./pkg2appimage.AppDir
cd ./pkg2appimage.AppDir

find ../*.deb -exec dpkg-deb -x {} . \; || true

rm *.desktop || true
mv ./usr/share/applications/appimagetool.desktop ./usr/share/applications/pkg2appimage.desktop 
sed -i -e 's|Name=appimagetool|Name=pkg2appimage|g' ./usr/share/applications/pkg2appimage.desktop
sed -i -e 's|Exec=appimagetool|Exec=pkg2appimage|g' ./usr/share/applications/pkg2appimage.desktop
sed -i -e 's|Comment=.*|Comment=Create AppImages from Debian/Ubuntu repositories|g' ./usr/share/applications/pkg2appimage.desktop
cp ./usr/share/applications/pkg2appimage.desktop .

cp ../ImageMagick-*.AppImage usr/bin/convert

# We don't suffer from NIH
# mkdir -p usr/src/
# wget -q "https://raw.githubusercontent.com/mikix/deb2snap/master/src/preload.c" -O - | \
# sed -e 's|SNAPPY|UNION|g' | sed -e 's|SNAPP|UNION|g' | sed  -e 's|SNAP|UNION|g' | \
# sed -e 's|snappy|union|g' > usr/src/libunionpreload.c
# gcc -shared -fPIC usr/src/libunionpreload.c -o libunionpreload.so -ldl -DUNION_LIBNAME=\"libunionpreload.so\"
# strip libunionpreload.so

cp ../../pkg2appimage AppRun ; chmod + AppRun

mkdir -p ./usr/share/pkg2appimage/
cp ../../{functions.sh,excludelist,excludedeblist,appdir-lint.sh} ./usr/share/pkg2appimage/
rm -rf ./usr/share/metainfo/* || true
mkdir -p ./usr/share/metainfo
cp ../../pkg2appimage.appdata.xml ./usr/share/metainfo/

copy_deps
move_lib
delete_blacklisted

cd ..
NO_GLIBC_VERSION=true APP=pkg2appimage VERSION=$TRAVIS_BUILD_NUMBER generate_type2_appimage # FIXME: This embeds bintray-zsync
