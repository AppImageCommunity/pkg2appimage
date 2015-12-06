FROM centos:6
ADD https://github.com/probonopd/AppImages/raw/master/recipes/scribus/Recipe /Recipe
RUN bash -ex Recipe && yum clean all && rm -rf /out && rm -rf Scribus*
