#!/bin/bash

source components/common.sh

print "Configure YUM Repos"
curl -f -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/roboshop-devops-project/mysql/main/mysql.repo &>>${LOG_FILE}
StatCheck $?

print "Install MySQL"
yum install mysql-community-server -y &>>${LOG_FILE}
StatCheck $?

print "Start MySQL Service"
systemctl enable mysqld &>>${LOG_FILE} && systemctl start mysqld &>>${LOG_FILE}
StatCheck $?

echo 'show databases' | mysql -uroot -pRoboshop@1 &>>${LOG_FILE}
if [ $? -ne 0 ]; then
  print "Change Default Root Password"
  echo "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('Roboshop@1');" >/tmp/rootpass.sql
  DEFAULT_ROOT_PASSWORD=$(grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')
  mysql --connect-expired-password -uroot -p"${DEFAULT_ROOT_PASSWORD}" </tmp/rootpass.sql &>>${LOG_FILE}
  StatCheck $?
fi

echo show plugins | mysql -uroot -pRoboshop@1 2>>${LOG_FILE} | grep validate_password &>>${LOG_FILE}
if [ $? -eq 0 ]; then
  print "Uninstall Password validate Plugin"
  echo 'uninstall plugin validate_password;' >/tmp/pass-validate.sql
  mysql --connect-expired-password -uroot -pRoboshop@1 </tmp/pass-validate.sql &>>${LOG_FILE}
   StatCheck $?
fi

print "Download Schema"
curl -s -L -o /tmp/mysql.zip "https://github.com/roboshop-devops-project/mysql/archive/main.zip" &>>${LOG_FILE}
StatCheck $?

print "Extract Schema"
cd /tmp && unzip -o mysql.zip &>>${LOG_FILE}
StatCheck $?

print "Load Schema"
cd mysql-main && mysql -uroot -pRoboshop@1 <shipping.sql &>>${LOG_FILE}
StatCheck $?