############################################################
# Dockerfile to build Scribus AppImages
# Based on CentOS 6
############################################################
FROM centos:6
ADD https://github.com/probonopd/AppImages/raw/master/recipes/scribus/Recipe /Recipe
RUN bash -ex scribus.centos6.sh && yum clean all && rm -rf /out && rm -rf Scribus*
