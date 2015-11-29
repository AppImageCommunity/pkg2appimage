# Enter a CentOS 6 chroot (you could use other methods)
sudo ./AppImageKit/AppImageAssistant.AppDir/testappimage /isodevice/boot/iso/CentOS-6.5-x86_64-LiveCD.iso bash

yum -y install epel-release 
yum -y install subversion cmake qt5-qtbase-gui qt5-qtbase qt5-qtbase-devel qt5-qtdeclarative qt5-qtdeclarative-devel qt5-qttools qt5-qttools-devel qt5-qtwebkit qt5-qtwebkit-devel qt5-qtbase-static glibc-headers libstdc++-devel gcc-c++ freetype-devel cairo-devel lcms2-devel libpng-devel libjpeg-devel libtiff-devel python-devel aspell-devel boost-devel cups-devel libxml2-devel libstdc++-devel boost-devel-static

# Newer compiler than what comes with CentOS 6
wget http://people.centos.org/tru/devtools-2/devtools-2.repo -O /etc/yum.repos.d/devtools-2.repo
yum -y install devtoolset-2-gcc devtoolset-2-gcc-c++ devtoolset-2-binutils
bash /opt/rh/devtoolset-2/enable

# http://wiki.scribus.net/canvas/Librevenge
# For those who always build the latest 1.5.0svn from source for testing, 
# some new dependencies have been introduced to get the full functionality of 1.5.0.
# These are coming from http://www.documentliberation.org
# irc #documentliberation-dev

yum install automake libtool cppunit-devel # for librevenge-0.0.1

# Upgrade auttoconf to 2.65 for librevenge-0.0.1
wget http://ftp.gnu.org/gnu/autoconf/autoconf-2.65.tar.bz2
tar xf autoconf-2.65.tar.bz2 
cd autoconf-*   
./configure
make
make install
cd -

# Workaround for: On CentOS 6, .pc files in /usr/lib/pkgconfig are not recognized
# However, this is where .pc files get installed when bulding libraries... (FIXME)
# I found this by comparing the output of librevenge's "make install" command
# between Ubuntu and CentOS 6
ln -sf /usr/share/pkgconfig /usr/lib/pkgconfig

git clone git://git.code.sf.net/p/libwpd/librevenge librevenge
cd librevenge*
./autogen.sh
./configure --prefix=/usr
make
make install
cd -

ldconfig

yum install libicu-devel
git clone http://anongit.freedesktop.org/git/libreoffice/libmspub.git
cd libmspub/
./autogen.sh
./configure --prefix=/usr
make
make install
cd -

yum install gperf
git clone http://anongit.freedesktop.org/git/libreoffice/libvisio.git
cd libvisio/
./autogen.sh
./configure --prefix=/usr
make
make install
cd -

# Fails
# VSDXMLTokenMap.h:14:20: error: tokens.h: No such file or directory ########################################

git clone http://anongit.freedesktop.org/git/libreoffice/libcdr.git
cd libcdr/
./autogen.sh
./configure --prefix=/usr
make
make install
cd -

# yaml is needed for libpagemaker
wget http://pyyaml.org/download/libyaml/yaml-0.1.4.tar.gz
tar -xvzf yaml-0.1.4.tar.gz
cd yaml-0.1.4
./configure --prefix=/usr
make
make install
cd -

git clone https://github.com/umanwizard/libpagemaker.git
cd libpagemaker/
./autogen.sh
./configure --prefix=/usr
make
make install
cd -

svn co svn://scribus.net/trunk/Scribus scribus15
# svn co -r 20099 svn://scribus.net/trunk/Scribus scribus150

cd scribus1*

# Workaround for missing "/usr/lib64/lib64/libboost_date_time.a"
ls /usr/lib64/lib64 2>/dev/null || ln -sf /usr/lib64/ /usr/lib64/lib64

# Workaround for missing "/usr/lib64/lib64/libboost_date_time-d.a"
# http://comments.gmane.org/gmane.comp.mobile.osmocom.sdr/1097
rpm -ql boost-devel | grep 'cmake$' | xargs rm

# Pass in -DCMAKE_C_COMPILER and -DCMAKE_CXX_COMPILER to prevent CMakeError.log CMAKE_CXX_COMPILER-NOTFOUND 
cmake . -DCMAKE_C_COMPILER=/opt/rh/devtoolset-2/root/usr/bin/gcc -DCMAKE_CXX_COMPILER=/opt/rh/devtoolset-2/root/usr/bin/g++

# Does not find the libraries we compiled above; is this because the .so and -a files got installed into /usr/lib rather than /usr/lib64?
