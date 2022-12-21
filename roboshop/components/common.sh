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

APP_USER=roboshop

NODEJS() {
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
  curl -f -s -L -o /tmp/${COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>>${LOG_FILE}
  StatCheck $?

  print "CleanUp OLd Content"
  rm -rf /home/${APP_USER}/${COMPONENT} &>>${LOG_FILE}
  StatCheck $?

  print "Extract App Content"
  cd /home/${APP_USER} &>>${LOG_FILE} && unzip -o /tmp/${COMPONENT}.zip &>>${LOG_FILE} && mv ${COMPONENT}-main ${COMPONENT} &>>${LOG_FILE}
  StatCheck $?

  print "Install App Dependencies"
  cd /home/${APP_USER}/${COMPONENT} &>>${LOG_FILE} && npm install &>>${LOG_FILE}
  StatCheck $?

  print "Fix App User Permission"
  chown -R ${APP_USER}:${APP_USER} /home/${APP_USER}
  StatCheck $?

  print "Setup SystemD File"
  sed -i -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/' /home/roboshop/${COMPONENT}/systemd.service &>>${LOG_FILE} && mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service &>>${LOG_FILE}
  StatCheck $?

  print "Start Catalogue Service"
  systemctl daemon-reload &>>${LOG_FILE} && systemctl restart ${COMPONENT} &>>${LOG_FILE} && systemctl enable ${COMPONENT} &>>${LOG_FILE}
  StatCheck $?
}