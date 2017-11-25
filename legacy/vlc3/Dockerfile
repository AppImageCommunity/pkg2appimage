FROM ubuntu:12.04.5
ADD https://github.com/probonopd/AppImages/raw/master/recipes/vlc3/Recipe /Recipe
RUN bash -ex Recipe ; apt-get clean ; rm -rf /usr/src ; rm -rf /out ; rm -rf /VLC/VLC.AppDir ; rm -rf /VLC/vlc-*.tar.xz
