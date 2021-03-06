#!/bin/bash

sleep 30

sudo yum update -y


sudo yum install -y gcc-c++ make
curl -sL https://rpm.nodesource.com/setup_14.x | sudo -E bash -
sudo yum install -y nodejs

sudo yum install tar -y
cd ~/ && tar -xf social_something.tgz
cd ~/ && npm i --only=prod

sudo yum install awslogs -y

sudo mv /tmp/awslogs.conf /etc/awslogs/awslogs.conf
sudo mv /tmp/awscli.conf /etc/awslogs/awscli.conf

sudo systemctl start awslogsd
sudo systemctl enable awslogsd.service

sudo mv /tmp/socialSomething.service /etc/systemd/system/socialSomething.service && echo Moved service file
sudo systemctl enable socialSomething.service && echo Enabled socialSomething service
sudo systemctl start socialSomething.service && echo Started SocialSomething service