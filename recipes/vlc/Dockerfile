FROM centos:6.7
ADD https://github.com/probonopd/AppImages/raw/master/recipes/vlc/Recipe /Recipe
RUN bash -ex Recipe ; yum clean all ; rm -rf /usr/src ; rm -rf /out ; rm -rf /AppImage* ; rm -rf /VLC/VLC.AppDir ; rm -rf /VLC/vlc-2.2.2.tar.xz
