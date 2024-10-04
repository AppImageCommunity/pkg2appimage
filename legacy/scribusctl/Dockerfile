FROM centos:6.7
ADD https://github.com/AppImageCommunity/pkg2appimage/raw/master/recipes/scribusctl/Recipe /Recipe
RUN bash -ex Recipe && yum clean all && rm -rf /out && rm -rf Scribus*
