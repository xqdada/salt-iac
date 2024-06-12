#!/bin/bash

REMOTE_HOST="$1"
EXTERNAL_IP="$2"

sudo salt ${REMOTE_HOST} cmd.run "grep -q ${EXTERNAL_IP} /etc/hosts" &>/dev/null||
if sudo salt ${REMOTE_HOST} cmd.run "sed -i '\$a ${EXTERNAL_IP} app.seetong.com' /etc/hosts";then
    sudo  salt ${REMOTE_HOST} cmd.run "systemctl restart TAServerd"
    sleep 2
fi