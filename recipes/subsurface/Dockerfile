FROM centos:6
ADD https://github.com/probonopd/AppImages/raw/master/recipes/subsurface/Recipe /Recipe
RUN bash -ex scribus.centos6.sh && yum clean all && rm -rf /out && rm -rf Scribus*
RUN sed -i -e 's|sudo ||g' Recipe && bash -ex Recipe && yum clean all && rm -rf /Subsurface/Subsurface*
