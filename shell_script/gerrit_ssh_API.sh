#!/bin/bash
#branch:PDU3_DEV after:"2018-06-29 00:00:00" status:merged
#ssh -p 29418 10.0.30.9 gerrit query branch:PDU3_DEV after:"2018-04-09" project:^MSM89XX_O_CODE_SW3/.*  status:merged --format JSON | grep -aoe "subject[^,]*" | awk -F ':' '{print $2}'
ssh -p 29418 10.0.30.9 gerrit query branch:PDU3_DEV project:^MSM89XX_O_CODE_SW3/.*  status:merged --format JSON | grep -aoe "subject[^,]*" | awk -F ':' '{print $2}'
