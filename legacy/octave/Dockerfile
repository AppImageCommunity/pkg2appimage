FROM centos:6.7
ADD https://github.com/probonopd/AppImages/raw/master/recipes/octave/Recipe /Recipe
RUN sed -i -e 's|sudo ||g' Recipe && bash -ex Recipe && yum clean all && rm -rf /dependencies && rm -rf /out && rm -rf /AppImage* && rm -rf /AppDir
