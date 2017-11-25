FROM centos:6
RUN yum -y install epel-release git make autoconf automake libtool \
        libzip-devel libxml2-devel libxslt-devel libsqlite3x-devel \
        libudev-devel libusbx-devel libcurl-devel libssh2-devel mesa-libGL-devel sqlite-devel \
        tar gzip which make autoconf automake gstreamer-devel mesa-libEGL coreutils grep wget
RUN wget http://people.centos.org/tru/devtools-2/devtools-2.repo -O /etc/yum.repos.d/devtools-2.repo
RUN yum -y install devtoolset-2-gcc devtoolset-2-gcc-c++ devtoolset-2-binutils \
	qt5-qtbase-devel qt5-qtlocation-devel qt5-qtscript-devel qt5-qtwebkit-devel qt5-qtsvg-devel qt5-linguist qt5-qtconnectivity-devel \
	binutils fuse glibc-devel glib2-devel fuse-devel gcc zlib-devel libpng12 patch

# everything up to here Docker should cache, so we don't need to reinstall
# all of these huge packages every time.

ADD https://github.com/AppImage/AppImages/raw/master/recipes/subsurface/Recipe /Recipe
RUN sed -i -e 's|sudo ||g' Recipe && bash -ex Recipe && yum clean all && rm -rf /Subsurface/Subsurface* && rm -rf /out
