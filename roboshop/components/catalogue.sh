#!/bin/bash

source components/common.sh

print "Configure YUM Repos"
curl -fsSL https://rpm.nodesource.com/setup_16.x | sudo bash - &>>${LOG_FILE}
StatCheck $?

print "Install NodeJS"
yum install nodejs gcc-c++ -y &>>${LOG_FILE}
StatCheck $?

print "Add Application User"
id ${APP_USER} &>>${LOG_FILE}
if [ $? -ne 0 ]; then
  useradd ${APP_USER} &>>${LOG_FILE}
fi
StatCheck $?

print "Download App Component"
curl -f -s -L -o /tmp/catalogue.zip "https://github.com/roboshop-devops-project/catalogue/archive/main.zip" &>>${LOG_FILE}
StatCheck $?

print "CleanUp OLd Content"
rm -rf /home/${APP_USER}/catalogue &>>${LOG_FILE}
StatCheck $?

print "Extract App Content"
cd /home/${APP_USER} &>>${LOG_FILE} && unzip /tmp/catalogue.zip &>>${LOG_FILE} && mv catalogue-main catalogue &>>${LOG_FILE}
StatCheck $?

print "Install App Dependencies"
cd /home/${APP_USER}/catalogue &>>${LOG_FILE} && npm install &>>${LOG_FILE}
StatCheck $?

primt "Fix App User Permission"
chown -R ${APP_USER}:${APP_USER} /home/${APP_USER}
StatCheck $?