#!/bin/bash

source ./common.sh
check_root

dnf list installed mysql-server &>>$LOG_FILE
# Install only if it is not installed earlier
if [ $? -ne 0 ]; then
   dnf install mysql-server -y &>>$LOG_FILE
   VALIDATE $? "mysql-server installation"
else
   echo -e "mysql-server is already installed .... $Y SKIPPING $N" | tee -a $LOG_FILE
fi

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabling mysqld"
systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "Start mysqld"
mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOG_FILE
VALIDATE $? "Setting up passwd"
print_total-time
