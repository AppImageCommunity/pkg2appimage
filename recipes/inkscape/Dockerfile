FROM centos:6.7
ADD https://github.com/probonopd/AppImages/raw/master/recipes/inkscape/Recipe /Recipe
RUN bash -ex Recipe && yum clean all && rm -rf /dependencies && rm -rf /out && rm -rf /AppImage* && rm -rf /AppDir
