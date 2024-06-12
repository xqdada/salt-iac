#!/bin/bash

# DB_HOST="122.9.36.202"
# DB_PASS="xxxxxx"
# DB_PORT="13530"
# DB_USER="root"
# DB_NAME="maincloudhost"
# DB_TABLE="t_httpserver"

# HTTP_SERVER_ID=$1
# REMOTE_HOST=$2

if [[ $# < 3 ]];then
    echo "Usage: sh $0 [http_server_id] [http_server_host] [remote_host]"
    exit 1
fi

# sql="select HttpLastTM from maincloudhost.t_httpserver where HttpServerID='${HTTP_SERVER_ID}'and time_to_sec(timediff(now(), HttpLastTM))<300"
# if mysql -u${DB_USER} -p${DB_PASS} -h ${DB_HOST} -P ${DB_PORT} ${DB_NAME} -e "$sql"|wc -l|grep -q 2;then
#     echo "服务器${REMOTE_HOST}：发布成功"
# else
#    echo 服务器${REMOTE_HOST}：发布失败
#    exit 1
# fi


HTTP_SERVER_ID="$1"
HTTP_SERVER_HOST="$2"
REMOTE_HOST="$3"

http_code=$(sudo salt ${REMOTE_HOST} cmd.run "curl -s -o /dev/null -X POST -w \"%{http_code}\" -H 'Content-type:application/x-www-form-urlencoded' -d 'version=2019032208&ok=1&data=<xml><re</ret><count>100</count><svrid>${HTTP_SERVER_ID}</svrid></xml>' https://${HTTP_SERVER_HOST}/check/update.php"|grep -o 200)
echo "http_code=${http_code}"

if [[ ${http_code} = 200 ]];then
   echo "服务器${REMOTE_HOST}：发布成功"
else
   echo 服务器${REMOTE_HOST}：发布失败
   exit 1
fi
