FROM scummos/centos6.8-qt5.7
ADD https://github.com/probonopd/AppImages/raw/master/recipes/kdevelop/Recipe /Recipe
RUN bash -ex Recipe ; yum clean all ; rm -rf /usr/src ; rm -rf /out ; rm -rf /KDevelop/
