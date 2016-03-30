#!/bin/bash

# 1) Install dependencies, oracle linux 7 doesnt use netstat any more, but the rpm need it
# 2) Install the rpm oracle-xe-11.2.0-1.0.x86_64.rpm
# 4) Export oracle environment variables
# 5) Configure oracle xe
# 6) Use sqlplus and login as sysdba and shrink datafiles, create sandbox dba user
# 7) Cleanup tempfiles and installation logs
chmod 777 /tmp/* && \
yum -y install libaio bc net-tools && \
yum -y clean all && \
yum localinstall -y /tmp/oracle-xe-11.2.0-1.0.x86_64.rpm && \
yum -y clean all && \
echo 'export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe' >> /etc/profile.d/oracle_profile.sh && \
echo 'export PATH=$ORACLE_HOME/bin:$PATH' >> /etc/profile.d/oracle_profile.sh && \
echo 'export ORACLE_SID=XE' >> /etc/profile.d/oracle_profile.sh && \
mv /tmp/*.ora /u01/app/oracle/product/11.2.0/xe/config/scripts && \
/etc/init.d/oracle-xe configure responseFile=/tmp/xe.rsp >> /tmp/XEsilentinstall.log && \
tail -n 500 /tmp/XEsilentinstall.log && \
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe && \
export PATH=$ORACLE_HOME/bin:$PATH && \
export ORACLE_SID=XE && \
sqlplus sys/oracle AS SYSDBA @/tmp/resize.sql && \
rm -f /tmp/*.*

# Generate ssh keys and configure ssh settings
ssh-keygen -q -N "" -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key && \
ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_dsa_key && \
ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key && \
sed -i "s/#UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config && \
sed -i "s/UsePAM.*/UsePAM yes/g" /etc/ssh/sshd_config

# Change the root and oracle password to oracle
echo root:oracle | chpasswd && echo oracle:oracle | chpasswd
