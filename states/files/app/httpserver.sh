#!/bin/bash

DB_HOST="122.9.36.202"
DB_PASS="xxxxxx"
DB_PORT="13530"
DB_USER="root"
DB_NAME="maincloudhost"
DB_TABLE="t_httpserver"

HTTP_SERVER_ID="$1"
HTTP_SERVER_HOST="$2"
HTTP_AREA_ID="$3"
REMOTE_HOST="$4"
EXTERNAL_IP="$(sudo salt "${REMOTE_HOST}" cmd.run "curl -s ip.sb"|awk 'NR==2{gsub(" ","");print}')"
HTTP_SERVER_NAME="$(sudo salt "${REMOTE_HOST}" grains.get fqdn|awk 'NR==2{gsub(" ","");print}'|sed 's#-##g')"


to_mysql() {
    result=$(mysql -u${DB_USER} -p${DB_PASS} -h ${DB_HOST} -P ${DB_PORT} ${DB_NAME} -e "select HttpServerID from maincloudhost.t_httpserver where HttpServerID='${HTTP_SERVER_ID}';")
    if [[ -z $result ]];then
sql="""INSERT INTO ${DB_NAME}.${DB_TABLE}
(HttpServerID,
HttpEntID,
HttpLastTM,
HttpIsBlaServer,
HttpServerHost,
HttpDevCount,
HttpDevOnCount,
HttpIsEnabled,
HttpCPU,
HttpLoad,
HttpMem,
HttpLastOnStatus,
HttpBindIP,
HttpServerName,
HttpAreaID,
HttpMaxLoad)
VALUES
('${HTTP_SERVER_ID}',
'0',
'0000-00-00 00:00:00',
'0',
'${HTTP_SERVER_HOST}',
'100',
'0',
'1',
'',
'',
'',
'0',
'${EXTERNAL_IP}',
'${HTTP_SERVER_NAME}',
'${HTTP_AREA_ID}',
'300');
"""
        mysql -u${DB_USER} -p${DB_PASS} -h ${DB_HOST} -P ${DB_PORT} ${DB_NAME} -e "$sql"
    #else
    #    echo "HttpServerID already exists"
    #    exit 1
    fi
}

if [[ $# < 4 ]];then
    echo "Usage: sh $0 [http_server_id] [http_server_host] [http_area_id] [remote_host]"
    exit 1
fi

to_mysql

exec sh -x /home/seetong-ops/salt-iac/states/files/app/add_appdomain.sh ${REMOTE_HOST} ${EXTERNAL_IP}