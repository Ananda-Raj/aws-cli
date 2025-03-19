#!/bin/bash
# Script to find instance without StatusCheckFailed cloudwatch alarm
# Authors: Ananda Raj
# Date: 26 May 2021

username=$(whoami)
aws_config_file="/home/$username/.aws/config"
temp_dir=/var/tmp/

for iprofile in $(cat $aws_config_file | grep "\[profile " | awk '{print $2}' | cut -d "]" -f1)
do
    echo -e "\n$iprofile"
    aws --profile $iprofile ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,Tags[?Key==`Name`].Value[]]' --output text |  sed '$!N;s/\n/ /' | sort -h > $temp_dir/cw_st_all_instance
    aws --profile $iprofile cloudwatch describe-alarms --query 'MetricAlarms[?MetricName==`StatusCheckFailed`].[Dimensions[?Name==`InstanceId`].Value[]]' --output text | sort -h > $temp_dir/cw_st_all_instance_st
    for i in `cat $temp_dir/cw_st_all_instance_st`; do grep $i $temp_dir/cw_st_all_instance ; done | sort -h > $temp_dir/cw_st_all_instance_st_desc
    grep -Fxv -f $temp_dir/cw_st_all_instance_st_desc $temp_dir/cw_st_all_instance > $temp_dir/cw_st_fin_list
    cat  $temp_dir/cw_st_fin_list | awk '{print $1","$2}'
done

rm -rf $temp_dir/cw_st_*