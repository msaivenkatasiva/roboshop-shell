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

dnf update -y &>>$LOGFILE
VALIDATE $? "updated successfully"

dnf install redis -y &>>$LOGFILE
VALIDATE $? "redis installed successfully"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf  &>>$LOGFILE
VALIDATE $? "remote connections allowed"

systemctl enable redis  &>>$LOGFILE
VALIDATE $? "enabled redis"

systemctl start redis  &>>$LOGFILE
VALIDATE $? "started redis"

netstat -lntp