#!/bin/bash

source components/common.sh

print "Configure YUM Repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | sudo bash &>>${LOG_FILE}
StatCheck $?

print "Install ErLang & RabbitMQ"
yum install https://github.com/rabbitmq/erlang-rpm/releases/download/v23.2.6/-23.2.6-1.el7.x86_64.rpm rabbitmq-server -y &>>${LOG_FILE}
StatCheck $?

print "Start RabbitMQ Service"
systemctl enable rabbitmq-server &>>${LOG_FILE} && systemctl start rabbitmq-server &>>${LOG_FILE}
StatCheck $?

rabbitmqctl list_users | grep roboshop &>>${LOG_FILE}
if [ $? -ne 0 ]; then
  print "Create Application User"
  rabbitmqctl add_user roboshop roboshop123 &>>${LOG_FILE}
  StatCheck $?
fi

print "Configure Application User"

rabbitmqctl set_user_tags roboshop administrator && rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
StatCheck $?