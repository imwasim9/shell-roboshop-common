#!/bin/bash
source ./common.sh
app_name=payment
check_root
app_setup
python_setup
systemd_setup

systemctl start payment &>>$LOG_FILE
VALIDATE $? "start payment service"
print_total_time

