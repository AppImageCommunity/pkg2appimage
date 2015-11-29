# Enter a CentOS 6 chroot (you could use other methods)
sudo ./AppImageKit/AppImageAssistant.AppDir/testappimage /isodevice/boot/iso/CentOS-6.5-x86_64-LiveCD.iso bash

sudo yum -y install epel-release 

yum -y install subversion cmake qt5-qtbase-gui qt5-qtbase qt5-qtbase-devel qt5-qtdeclarative qt5-qtdeclarative-devel qt5-qttools qt5-qttools-devel qt5-qtwebkit qt5-qtwebkit-devel qt5-qtbase-static glibc-headers libstdc++-devel gcc-c++ freetype-devel cairo-devel lcms2-devel libpng-devel libjpeg-devel libtiff-devel python-devel aspell-devel boost-devel cups-devel libxml2-devel libstdc++-devel boost-devel-static

svn co svn://scribus.net/trunk/Scribus scribus15

cd scribus15/

# Workaround for missing "/usr/lib64/lib64/libboost_date_time.a"
ln -sf /usr/lib64/ /usr/lib64/lib64

# Workaround for missing "/usr/lib64/lib64/libboost_date_time-d.a"
# http://comments.gmane.org/gmane.comp.mobile.osmocom.sdr/1097
rpm -ql boost-devel | grep 'cmake$' | xargs rm

bash /opt/rh/devtoolset-2/enable

## which gcc
# /opt/rh/devtoolset-2/root/usr/bin/gcc
# "Configuring incomplete, errors occurred!"
## cat /scribus15/CMakeFiles/CMakeError.log | grep CXX
# Compiling the CXX compiler identification source file "CMakeCXXCompilerId.cpp" failed.
# Compiler: CMAKE_CXX_COMPILER-NOTFOUND 

cmake . -DCMAKE_C_COMPILER=/opt/rh/devtoolset-2/root/usr/bin/gcc -DCMAKE_CXX_COMPILER=/opt/rh/devtoolset-2/root/usr/bin/g++

exit 0 #################### Teh follwoing is the output I get

Boost Library Found OK
Building without GraphicksMagick (use -DWANT_GRAPHICSMAGICK=1 to enable)
-- checking for one of the modules 'libpoppler>=0.19.0;poppler>=0.19.0'
Poppler NOT found - Disabling support for native PDF import
-- checking for module 'librevenge-0.0'
--   package 'librevenge-0.0' not found
RPATH: lib/scribus/plugins/;
-- Qt5::CoreQt5::WidgetsQt5::GuiQt5::XmlQt5::NetworkQt5::OpenGL/usr/lib64/libxml2.so/usr/lib64/libz.so
-- checking for module 'libwpg-0.2'
--   package 'libwpg-0.2' not found
-- checking for module 'libmspub-0.0<=0.1'
--   package 'libmspub-0.0<=0.1' not found
-- checking for module 'libwpg-0.2'
--   package 'libwpg-0.2' not found
-- Building with Scripter 1
-- No source header files will be installed
-- /scribus15/resources/translations
-- The following GUI languages will be installed: 
-- Configuring incomplete, errors occurred!
