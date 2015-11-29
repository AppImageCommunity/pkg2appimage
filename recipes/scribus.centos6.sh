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

cmake .

# "Configuring incomplete, errors occurred!"
## cat /scribus15/CMakeFiles/CMakeError.log | grep CXX
# Compiling the CXX compiler identification source file "CMakeCXXCompilerId.cpp" failed.
# Compiler: CMAKE_CXX_COMPILER-NOTFOUND 
