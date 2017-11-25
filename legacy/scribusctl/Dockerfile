FROM centos:6.7
ADD https://github.com/AppImage/AppImages/raw/master/recipes/scribusctl/Recipe /Recipe
RUN bash -ex Recipe && yum clean all && rm -rf /out && rm -rf Scribus*
