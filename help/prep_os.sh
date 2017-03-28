#!/bin/bash
#

#
# prepare database
#
echo "host    all             all             0.0.0.0/0 trust" >> /etc/postgresql/9.3/main/pg_hba.conf
echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf

#
# get latest Libretime
#
echo "Clone libretime"
mkdir /libretime_src
cd /libretime_src
git clone https://github.com/LibreTime/libretime.git
#
#
# activate RabbitMQ management
#
echo "NODENAME=rabbitmq@localhost" > /etc/rabbitmq/rabbitmq-env.conf
rabbitmq-plugins enable rabbitmq_management
# start rabbitmq for airtime install
/etc/init.d/rabbitmq-server start
#
# install lastest libretime
#
echo "Install libretime"
cd /libretime_src/libretime
./install -fiap
# stop rabbitmq
/etc/init.d/rabbitmq-server stop

# cleaning
rm -rf /libretime_src
apt-get clean

#
# move created files off the original place for moving them back
# if we've mounted external volumes
#
echo "Saving /etc/airtime .."
tar czf /etc/airtime.tgz /etc/airtime
rm -rf /etc/airtime
echo "Saving postgres"
tar czf /var/lib/postgresql.tgz /var/lib/postgresql
rm -rf /var/lib/postgresql
echo "Create some configfiles .."
# define postgres password file
echo "localhost:5432:airtime:airtime:airtime" > /root/.pgpass
chmod 600 /root/.pgpass 
