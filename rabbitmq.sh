#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
mongo_host=mongodb.devopswithmsvs.uno

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

ID=$(id -u)

VALIDATE(){
    if [ $? -ne 0 ]
    then   
        echo -e "$2.....$R FAILED $N"
        exit 1
    else
        echo -e "$2.....$G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then 
    echo -e "$R error::Please try with root user $N"
    exit 1
else    
    echo -e "$G you are root user $N"
fi

curl -s -p https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>>$LOGFILE
VALIDATE $? "downloaded erlang script"


curl -s -p https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>>$LOGFILE
VALIDATE $? "downloaded rabbitmq server"

dnf install rabbitmq-server -y &>>$LOGFILE
VALIDATE $? "installing rabbitmq server"

systemctl enable rabbitmq-server &>>$LOGFILE
VALIDATE $? "enabling rabbitmq"

systemctl start rabbitmq-server &>>$LOGFILE
VALIDATE $?"starting server"

rabbitmqctl add_user roboshop roboshop123 &>>$LOGFILE
VALIDATE $? "user added"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOGFILE
VALIDATE $? "permissions set"