#!/bin/bash

source components/common.sh


print "Setup YUM Repos"
curl -L https://raw.githubusercontent.com/roboshop-devops-project/redis/main/redis.repo -o /etc/yum.repos.d/redis.repo &>>{LOG_FILE}
StatCheck $?

print "Install Redis"
yum install redis-6.2.7 -y &>>{LOG_FILE}
StatCheck $?

print "Update Redis Config"
if [ -f /etc/redis.conf ]; then
  sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf
fi
if [ -f /etc/redis/redis.conf ]; then
  sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis/redis.conf
fi
StatCheck $?

print "Start Redis Service"
systemctl enable redis &>>{LOG_FILE} && systemctl start redis  &>>{LOG_FILE}
StatCheck $?

