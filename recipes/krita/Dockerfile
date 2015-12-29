FROM centos:6
ADD https://github.com/probonopd/AppImages/raw/master/recipes/krita/Recipe /Recipe
RUN bash -ex Recipe && yum clean all && rm -rf /out && rm -rf krita*
