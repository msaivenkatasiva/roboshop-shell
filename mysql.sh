#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

MONGO_HOST=mongodb.devopswithmsvs.uno

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

VALIDATE(){
    if [ $? -ne 0 ]
    then
        echo -e "$2.....$R FAILED $N"
    else
        echo -e "$2.....$G success $N"
    fi
}

if [ $ID -ne 0 ]
then    
    echo -e "$R error::please enter with root user $N"
else
    echo -e "$G you are a root user $N"
fi

dnf module disable mysql -y &>>$LOGFILE
VALIDATE $? "Disabling mysql"

cp mysql.repo /etc/yum.repos.d/mysql.repo &>>$LOGFILE
VALIDATE $? "copying mysql repo"

dnf install mysql-community-server -y &>>$LOGFILE
VALIDATE $? "installing mysql server"

systemctl enable mysql &>>$LOGFILE
VALIDATE $? "enabling mysql"

systemctl start mysql &>>$LOGFILE
VALIDATE $? "starting msql"

mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOGFILE
VALIDATE $? "settig mysql root passwd"