# Creates a docker image with Oracle Linux 7 and Oracle 11g XE (11.2.0-1.0) database and ssh daemon.
# Use run build.sh to build this image

FROM oraclelinux:latest
MAINTAINER Ove Olsen <olsove@gmail.com>

COPY setup /tmp

RUN chmod 777 /tmp/*
RUN /tmp/setup.sh

EXPOSE 22 1521

# Change the hostname in the listener.ora file, start Oracle XE and the ssh daemon
CMD sed -i -E "s/HOST = [^)]+/HOST = $HOSTNAME/g" /u01/app/oracle/product/11.2.0/xe/network/admin/listener.ora; \
/etc/init.d/oracle-xe start; \
/usr/sbin/sshd -D
