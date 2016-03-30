#!/bin/bash
file=setup/oracle-xe-11.2.0-1.0.x86_64.rpm

echo "Testing if $file exists"
[ -f $file ] && echo "Ok, starting build." || echo "File setup/oracle-xe-11.2.0-1.0.x86_64.rpm not found, please download from http://www.oracle.com/technetwork/database/database-technologies/express-edition/downloads/index.html."

docker build -t oel7-oracle-xe-iso8859-1:latest .
