FROM centos:6
ADD Recipe /Recipe
RUN bash -ex Recipe && yum clean all && rm -rf /out && rm -rf Scribus*
