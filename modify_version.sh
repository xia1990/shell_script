#!/bin/bash


old_number=$(grep "\$(BUILD_ID_PREFIX)" build_id-bq-borneo.mk | awk -F'-' '{print $2}')
new_number=$((old_number+1))
echo $new_number
