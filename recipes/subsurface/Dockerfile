FROM centos:6
ADD https://github.com/probonopd/AppImages/raw/master/recipes/subsurface/Recipe /Recipe
RUN sed -i -e 's|sudo ||g' Recipe && bash -ex Recipe && yum clean all && rm -rf /Subsurface/Subsurface* && rm -rf /out
