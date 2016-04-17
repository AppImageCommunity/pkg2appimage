FROM centos:7
ADD https://github.com/probonopd/AppImages/raw/master/recipes/inkscape/Recipe /Recipe
RUN bash -ex Recipe && yum clean all && rm -rf /out && rm -rf /AppImage*
