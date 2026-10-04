#!/bin/bash
source ./common.sh
app_name=nginx

dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "disabling nginx"
dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "enabling nginx:1.24"
dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "installing nginx:1.24"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "delete default html content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip  &>>$LOG_FILE
VALIDATE $? "download frontend code"
cd /usr/share/nginx/html &>>$LOG_FILE
VALIDATE $? "change dir to nginx"
unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "unzip frontend code"
cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "loaded nginx.conf"
app_restart
print_total_time