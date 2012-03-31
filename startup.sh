#!/bin/bash -e

#source ./imroot

export X7WORKDIR=`pwd`
CONFDIR=$X7WORKDIR/conf

# download dependency for git, rabbitmq, etc
sudo apt-get update
sudo apt-get install -y --assume-yes approx

# approx setup
cp -f $CONFDIR/etc/approx/approx.conf.template $CONFDIR/etc/approx/approx.conf
cp -f $CONFDIR/etc/apt/sources.list.template $CONFDIR/etc/apt/sources.list
sed -i "s|%HOSTADDR%|127.0.0.1|g" $CONFDIR/etc/apt/sources.list
sudo mv -f /etc/apt/sources.list /etc/apt/sources.list.backup
sudo cp -f $CONFDIR/etc/apt/sources.list /etc/apt/sources.list 
sudo cp -f $CONFDIR/etc/approx/approx.conf /etc/approx/approx.conf

sudo inetd
sudo apt-get update

sudo apt-get install -y ntp
sudo sed -i 's/server ntp.ubuntu.com/serverntp.ubuntu.com\nserver 127.127.1.0\nfudge 127.127.1.0 stratum 10/g' /etc/ntp.conf
sudo service ntp restart

# installn dependent package
sudo apt-get install -y --assume-yes git rabbitmq-server  python-kombu python-django

# clone start service from github
git clone git://github.com/zz7a5pe4/x7_start.git || true

# clone x7 stack from github
git clone git://github.com/zz7a5pe4/x7.git || true 

# clone x7 fai from github
git clone git://github.com/zz7a5pe4/x7_fai.git || true

# create id_rsa for current user
ssh-keygen -P "" -f ~/.ssh/id_rsa || true
eval `ssh-agent` 
ssh-add   ~/.ssh/id_rsa
# setup rabbitmq
sudo rabbitmqctl  -q change_password guest guest

echo "start listen server:"
x7_start/server/mq_receiver.py &

echo "open browser with url http://127.0.0.1:8000/init"
cd x7_start
#firefox 127.0.0.1:8000/init
python manage.py runserver 0.0.0.0:8000 2>/dev/null 1>/dev/null
