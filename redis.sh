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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>$LOGFILE
VALIDATE $? "installing remi release"

dnf module enable redis:remi-6.2 -y &>>$LOGFILE
VALIDATE $? "enabling redis"

dnf install redis -y &>>$LOGFILE
VALIDATE $? "installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>>$LOGFILE
VALIDATE $? "allowing remote connections"

systemctl start redis &>>$LOGFILE
VALIDATE $? "starting redis"