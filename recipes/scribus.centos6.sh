# Enter a CentOS 6 chroot (you could use other methods)
sudo ./AppImageKit/AppImageAssistant.AppDir/testappimage /isodevice/boot/iso/CentOS-6.5-x86_64-LiveCD.iso bash

yum -y install epel-release 
yum -y install subversion cmake qt5-qtbase-gui qt5-qtbase qt5-qtbase-devel qt5-qtdeclarative qt5-qtdeclarative-devel qt5-qttools qt5-qttools-devel qt5-qtwebkit qt5-qtwebkit-devel qt5-qtbase-static glibc-headers libstdc++-devel gcc-c++ freetype-devel cairo-devel lcms2-devel libpng-devel libjpeg-devel libtiff-devel python-devel aspell-devel boost-devel cups-devel libxml2-devel libstdc++-devel boost-devel-static

# Newer compiler than what comes with CentOS 6
wget http://people.centos.org/tru/devtools-2/devtools-2.repo -O /etc/yum.repos.d/devtools-2.repo
yum -y install devtoolset-2-gcc devtoolset-2-gcc-c++ devtoolset-2-binutils
bash /opt/rh/devtoolset-2/enable

# svn co svn://scribus.net/trunk/Scribus scribus15
svn co -r 20099 svn://scribus.net/trunk/Scribus scribus150

cd scribus1*

# Workaround for missing "/usr/lib64/lib64/libboost_date_time.a"
ln -sf /usr/lib64/ /usr/lib64/lib64

# Workaround for missing "/usr/lib64/lib64/libboost_date_time-d.a"
# http://comments.gmane.org/gmane.comp.mobile.osmocom.sdr/1097
rpm -ql boost-devel | grep 'cmake$' | xargs rm

## which gcc
# /opt/rh/devtoolset-2/root/usr/bin/gcc
# "Configuring incomplete, errors occurred!"
## cat /scribus15/CMakeFiles/CMakeError.log | grep CXX
# Compiling the CXX compiler identification source file "CMakeCXXCompilerId.cpp" failed.
# Compiler: CMAKE_CXX_COMPILER-NOTFOUND 

cmake . -DCMAKE_C_COMPILER=/opt/rh/devtoolset-2/root/usr/bin/gcc -DCMAKE_CXX_COMPILER=/opt/rh/devtoolset-2/root/usr/bin/g++

# http://wiki.scribus.net/canvas/Librevenge
# For those who always build the latest 1.5.0svn from source for testing, 
# some new dependencies have been introduced to get the full functionality of 1.5.0.

wget http://sourceforge.net/projects/libwpd/files/librevenge/librevenge-0.0.1/librevenge-0.0.1.tar.bz2/download --trust-server-names
tar xf librevenge-0.0.1.tar.bz2
./autogen.sh

# Autoconf version 2.65 or higher is required - we have 2.63. Yay!
