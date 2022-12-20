#!/bin/bash

StatCheck() {
if [ $1 -eq 0 ] ; then
  echo -e "\e[32mSUCCESS\e[0m"
else
  echo "\e[31mFAILURE\e[0m"
  exit 2
fi
}

print() {
  echo -e "\n.................$1................" &>>$LOG_FILE
  echo -e "\e[36m $1 \e[0m"
}
USER_ID=$(id -u)
if [ "$USER_ID" -ne 0 ]; then
  echo You should run your script as sudo or root user
  exit 1
fi
LOG_FILE=/tmp/roboshop.log
rm -rf $LOG_FILE

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

