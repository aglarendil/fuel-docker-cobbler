# fuel-cobbler
#
# Version     0.1

FROM centos
MAINTAINER Matthew Mosesohn mmosesohn@mirantis.com

ENV MIRROR_CENTOS @@MIRROR_CENTOS@@

WORKDIR /root

RUN rm -rf /etc/yum.repos.d/*
RUN echo -e "[nailgun]\nname=Nailgun Local Repo\nbaseurl=${MIRROR_CENTOS}\ngpgcheck=0" > /etc/yum.repos.d/nailgun.repo
RUN yum clean all
RUN yum --quiet install -y ruby21-puppet
RUN yum --quiet install -y httpd cobbler dnsmasq xinetd tftp-server

ADD etc /etc
RUN cp /etc/puppet/modules/nailgun/examples/cobbler-only.pp /root/init.pp
#Workaround so cobbler sync works
RUN ln -s /proc/mounts /etc/mtab
#Workaround for dnsmasq startup
RUN echo -e "NETWORKING=yes\nHOSTNAME=$HOSTNAME" > /etc/sysconfig/network
#FIXME workaround for ssh key
RUN mkdir -p /root/.ssh; chmod 700 /root/.ssh; touch /root/.ssh/id_rsa.pub


RUN /etc/init.d/httpd start && puppet apply -v /root/init.pp

RUN mkdir -p /usr/local/bin
ADD start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

EXPOSE 67
EXPOSE 69
EXPOSE 80
EXPOSE 443
CMD /usr/local/bin/start.sh
