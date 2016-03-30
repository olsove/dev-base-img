#OEL7-ORACLE-XE-ISO-8859-1#

This image is running Oracle Enterprise Linux 7.0 with the following services:

 1. SSHD on port 22 mapped to 49160
    * Login: oracle/oracle, root/oracle
 2. Oracle-XE 11.2.0 on port 1521 mapped to 49161.
    * Character set is WE8ISO8859P1 (Default:AL32UTF8)
    * Apex has been removed
    * SYSAUX tablespace and files has been shrinked to save space.
    * Created sandbox/sandbox user as dba and own tablespace.
    * Login: sys/oracle, system/oracle, sandbox/sandbox (dba)

### Build ###
1. Download  link to rpm oracle-xe-11.2.0-1.0.x86_64.rpm to setup folder.
2. Run command
```bash
docker build -t oel7-oracle-xe-iso8859-1:latest .
```
### Tag ###
To tag the image ready for hub.docker.com.
```bash
docker tag oel7-oracle-xe-iso8859-1:latest olsove/oel7-oracle-xe-iso8859-1:latest
```

### Push ###
To push the image to hub.docker.com:
```bash
docker push olsove/oel7-oracle-xe-iso8859-1:latest
```


#### /etc/sysctl.conf ####
To be able to run this build you have to ajust host config.
edit /etc/sysctl.conf on host system

```bash
fs.file-max = 6815744
kernel.sem = 250 32000 100 128
kernel.shmmni = 4096
kernel.shmall = 1073741824
kernel.shmmax = 4398046511104
kernel.panic_on_oops = 1
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
fs.aio-max-nr = 1048576
net.ipv4.ip_local_port_range = 9000 65500

run sysctl -p
```
#### Start oracle xe container command ####
```bash
docker run -d -p 49160:22 -p 49161:1521 oel7-oracle-xe-iso8859-1:latest
```
#### Connect with ssh ####
```bash
ssh oracle@localhost -p 49160
```
### Access web interface (DISABLED!) ###
Apex that comes default with Oracle express-edition has been removed by resize.sql

### Database characterset ###
The resize.sql script in setup will change the database character set from AL32UTF8 to WE8ISO8859P1.
If you want to change that, alter the folling line in resize.sql:
```sql
ALTER DATABASE CHARACTER SET INTERNAL_USE WE8ISO8859P1;
```
