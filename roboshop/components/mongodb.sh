#!/bin/bash

source components/common.sh

print "Setup YUM Repos"
curl -s -o /etc/yum.repos.d/mongodb.repo https://raw.githubusercontent.com/roboshop-devops-project/mongodb/main/mongo.repo &>>$LOG_FILE
StatCheck $?

print "Install MongoDb"
yum install -y mongodb-org &>>$LOG_FILE
StatCheck $?

print "Update Mongodb Listen address"
sed -i -e "s/127.0.0.1/0.0.0.0/" /etc/mongod.conf
StatCheck $?

print "Start MonogoDB"
systemctl enable mongod &>>$LOG_FILE && systemctl restart mongod &>>$LOG_FILE
StatCheck $?

#Update Listen IP address from 127.0.0.1 to 0.0.0.0 in config file
#Config file: /etc/mongod.conf
#then restart the service
# systemctl restart mongod

