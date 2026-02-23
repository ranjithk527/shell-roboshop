#!/bin/bash
USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
N="\e[0m"

if [ $USERID -ne 0 ] ; then 
  echo -e "$R Please run this script with root user access $N" | tee -a $LOGS_FILE
  exit 1
fi

mkdir -p $LOGS_FOLDER

VALIDATE()
{
 if [ $1 -ne 0 ]; then 
    echo -e "$2 $R ......failure $N" | tee -a $LOGS_FILE
    exit 1
 else 
    echo -e "$2 $G......success $N" | tee -a $LOGS_FILE 
 fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo | tee -a $LOGS_FILE
VALIDATE $? "copying mongo repo"

dnf install mongodb-org -y 
VALIDATE $? "installing mongoDB server"

systemctl enable mongod
VALIDATE $? "enable mongoDB"

systemctl start mongod 
VALIDATE $? "start mongoDB"

sed '127.0.0.1 to 0.0.0.0' /etc/mongod.conf
VALIDATE $? "Allowing remote connections"

systemctl restart mongod
VALIDATE $? "Restarted mongoDB"