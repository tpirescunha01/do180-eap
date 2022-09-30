FROM ubi8/ubi:8.3

#section openshift
RUN yum -y update && \
yum -y install sudo openssh-clients telnet unzip java-1.8.0-openjdk-devel && \
yum clean all

# enabling sudo group
# enabling sudo over ssh
RUN echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers && \
sed -i 's/.*requiretty$/Defaults !requiretty/' /etc/sudoers

# add a user for the application, with sudo permissions
RUN useradd -m jboss ; echo jboss: | chpasswd ; usermod -a -G wheel jboss

# create workdir
RUN mkdir -p /opt/rh

WORKDIR /opt/rh


#section JBOSS Install

MAINTAINER Thamires Cunha <tpires@br.ibm.com>

ENV JBOSS_HOME /opt/rh/jboss-eap-7.3

ADD /jboss-eap-7.3.0.zip /tmp/jboss-eap-7.3.0.zip
RUN unzip /tmp/jboss-eap-7.3.0.zip

# create Jboss  user
RUN $JBOSS_HOME/bin/add-user.sh admin admin@2016 --silent

RUN echo "JAVA_OPTS=\"\$JAVA_OPTS -Djboss.bind.address=0.0.0.0 -Djboss.bin.address.management=0.0.0.0\"" >> $JBOSS_HOME/bin/standalone.conf

# set permission folder
RUN chown -R jboss:jboss /opt/rh

# Jboss ports
EXPOSE 8080 9990 9999

#start Jboss
ENTRYPOINT $JBOSS_HOME/bin/standalone.sh -c standalone-full-ha.xml

USER jboss
CMD /bin/bash
