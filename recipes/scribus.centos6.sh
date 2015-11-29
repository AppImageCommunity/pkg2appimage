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

#####################
exit 0
#####################

Boost Library Found OK
Building without GraphicksMagick (use -DWANT_GRAPHICSMAGICK=1 to enable)
-- checking for one of the modules 'libpoppler>=0.19.0;poppler>=0.19.0'
Poppler NOT found - Disabling support for native PDF import
-- checking for module 'librevenge-0.0'
--   package 'librevenge-0.0' not found
RPATH: lib/scribus/plugins/;
-- Qt5::CoreQt5::WidgetsQt5::GuiQt5::XmlQt5::WebKitQt5::WebKitWidgetsQt5::NetworkQt5::OpenGL/usr/lib64/libxml2.so/usr/lib64/libz.so
-- checking for module 'libwpg-0.2'
--   package 'libwpg-0.2' not found
-- checking for module 'libmspub-0.0=0.0'
--   package 'libmspub-0.0=0.0' not found
-- checking for module 'libwpg-0.2'
--   package 'libwpg-0.2' not found
-- Building with Scripter 1
-- No source header files will be installed
-- /scribus150/resources/translations
-- The following GUI languages will be installed: 
-- Configuring incomplete, errors occurred!
See also "/scribus150/CMakeFiles/CMakeOutput.log".
See also "/scribus150/CMakeFiles/CMakeError.log".
[root@host scribus150]# gedit /scribus150/CMakeFiles/CMakeError.log

(process:10244): Gtk-WARNING **: Locale not supported by C library.
	Using the fallback 'C' locale.

#####################

cat /scribus150/CMakeFiles/CMakeError.logrror.log
Determining if the system is big endian passed with the following output:
Change Dir: /scribus150/CMakeFiles/CMakeTmp

Run Build Command:/usr/bin/gmake "cmTryCompileExec62770080/fast"
/usr/bin/gmake -f CMakeFiles/cmTryCompileExec62770080.dir/build.make CMakeFiles/cmTryCompileExec62770080.dir/build
gmake[1]: Entering directory `/scribus150/CMakeFiles/CMakeTmp'
/usr/bin/cmake -E cmake_progress_report /scribus150/CMakeFiles/CMakeTmp/CMakeFiles 1
Building C object CMakeFiles/cmTryCompileExec62770080.dir/TestEndianess.c.o
/opt/rh/devtoolset-2/root/usr/bin/gcc    -o CMakeFiles/cmTryCompileExec62770080.dir/TestEndianess.c.o   -c /scribus150/CMakeFiles/CMakeTmp/TestEndianess.c
Linking C executable cmTryCompileExec62770080
/usr/bin/cmake -E cmake_link_script CMakeFiles/cmTryCompileExec62770080.dir/link.txt --verbose=1
/opt/rh/devtoolset-2/root/usr/bin/gcc       CMakeFiles/cmTryCompileExec62770080.dir/TestEndianess.c.o  -o cmTryCompileExec62770080 -rdynamic 
gmake[1]: Leaving directory `/scribus150/CMakeFiles/CMakeTmp'

TestEndianess.c:
/* A 16 bit integer is required. */
typedef unsigned short cmakeint16;

/* On a little endian machine, these 16bit ints will give "THIS IS LITTLE ENDIAN."
   On a big endian machine the characters will be exchanged pairwise. */
const cmakeint16 info_little[] =  {0x4854, 0x5349, 0x4920, 0x2053, 0x494c, 0x5454, 0x454c, 0x4520, 0x444e, 0x4149, 0x2e4e, 0x0000};

/* on a big endian machine, these 16bit ints will give "THIS IS BIG ENDIAN."
   On a little endian machine the characters will be exchanged pairwise. */
const cmakeint16 info_big[] =     {0x5448, 0x4953, 0x2049, 0x5320, 0x4249, 0x4720, 0x454e, 0x4449, 0x414e, 0x2e2e, 0x0000};

#ifdef __CLASSIC_C__
int main(argc, argv) int argc; char *argv[];
#else
int main(int argc, char *argv[])
#endif
{
  int require = 0;
  require += info_little[argc];
  require += info_big[argc];
  (void)argv;
  return require;
}

#####################

I cannot see any error...

#####################


# http://wiki.scribus.net/canvas/Librevenge
# For those who always build the latest 1.5.0svn from source for testing, 
# some new dependencies have been introduced to get the full functionality of 1.5.0.

wget http://sourceforge.net/projects/libwpd/files/librevenge/librevenge-0.0.1/librevenge-0.0.1.tar.bz2/download
tar xf librevenge-0.0.1.tar.bz2
cd librevenge*
./autogen.sh

# Autoconf version 2.65 or higher is required - we have 2.63. Yay!
