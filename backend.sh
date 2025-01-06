#!/bin/bash
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/expense-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H:%M:%S)
LOG_FILE_NAME="$LOG_FOLDER/$LOG_FILE-$TIMESTAMP"

VALIDATE(){
    if [ $? -ne 0 ]
    then
    echo -e "$R $2 is .....FAILURE $N"
    else
    echo -e "$G $2 is .....SUCCESS $N"
    fi
}

CHECH_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R Need sudo access for installing packages $N"
        exit 1
    fi
}

echo -e "$G Execution of the script started $N at : $TIMESTAMP" &>>LOG_FILE_NAME

CHECH_ROOT
 
dnf module disable nodejs -y &>>LOG_FILE_NAME
VALIDATE $? "Disabling NODEJS"

dnf module enable nodejs:20 -y &>>LOG_FILE_NAME
VALIDATE $? "Enabling NODEJS 20"

dnf install nodejs -y &>>LOG_FILE_NAME
VALIDATE $? "INSATLLING NODEJS"

USEREXPENSE=$(id expense)
if [ $USEREXPENSE -ne 0 ]
then 
    useradd expense &>>LOG_FILE_NAME
    VALIDATE $? "ADDING USER"
else 
    echo "User expense is already added"
fi

mkdir -p /app &>>LOG_FILE_NAME
VALIDATE $? "CREATING FOLDER APP"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>LOG_FILE_NAME
VALIDATE $? "DOWLOADING BACKEND"

cd /app
rm -rf /app/*
VALIDATE $? "CHANING to APP DIRECTORY"

unzip /tmp/backend.zip &>>LOG_FILE_NAME
VALIDATE $? "UNZIPING THE CODE"

cd /app &>>LOG_FILE_NAME
VALIDATE $? "CD APP"

npm install &>>LOG_FILE_NAME
VALIDATE $? "Install packages" 

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service

dnf install mysql -y &>>LOG_FILE_NAME
VALIDATE $? "Installing mysql client"

mysql -h 172.31.93.213 -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>LOG_FILE_NAME
VALIDATE $? "CREATING SCHEMAS"

systemctl daemon-reload &>>LOG_FILE_NAME
VALIDATE $? "Daemon Reload"

systemctl enable backend &>>LOG_FILE_NAME
VALIDATE $? "Enabling Backend"

systemctl restart backend &>>LOG_FILE_NAME
VALIDATE $? "STARTING Backend"


