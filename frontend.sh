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
    echo -e "$2 is ..... $R FAILURE $N"
    else
    echo -e "$2 is ..... $G SUCCESS $N"
    fi
}

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R Need sudo access for installing packages $N"
        exit 1
    fi
}
mkdir -p $LOGS_FOLDER
echo -e "$G Execution of the script started $N at : $TIMESTAMP" &>>LOG_FILE_NAME

CHECK_ROOT

dnf install nginx -y &>>LOG_FILE_NAME
VALIDATE $? "Installing NGINX"

systemctl enable nginx &>>LOG_FILE_NAME
VALIDATE $? "Enabling nginx"

systemctl start nginx 
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/* &>>LOG_FILE_NAME
VALIDATE $? "Removing default html"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>LOG_FILE_NAME
VALIDATE $? "Downloading the frontend code"

cd /usr/share/nginx/html &>>LOG_FILE_NAME
VALIDATE $? "Changing to the html path"

unzip /tmp/frontend.zip &>>LOG_FILE_NAME
VALIDATE $? "Unzipping the dowloaded code"

cp /home/ec2-user/expense-script/expense.conf /etc/nginx/default.d/expense.conf 
VALIDATE $? "For redirecting to backent we have to add code"

systemctl restart nginx 
VALIDATE $? "Restart Service"

