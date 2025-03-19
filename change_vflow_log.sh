#!/bin/bash
# Script to Change VPC Flow logs retension period and traffic filter of AWS accounts
# Author: Ananda Raj
# Date: 23 Dec 2020

# Read and initialize parameters.
temp_dir=/var/tmp/
username=$(whoami)
aws_config_file="/home/$username/.aws/config"

# Get VPC IDs
for iprofile in $(cat $aws_config_file | grep "\[profile " | awk '{print $2}' |cut -d "]" -f1) 
do 
    echo -e "\n$iprofile"
    vpc_details=`aws ec2 --profile $iprofile describe-vpcs --output table | grep VpcId | awk '{print $4}'`
    echo $vpc_details > $temp_dir/vpc_id_list
    if [ -z "$vpc_details" ];
    # If no VPC found 
    then
        vpc_name="Nil"
    else 
        # If VPC found
        for vpc_id in $(cat $temp_dir/vpc_id_list)
        do 
            aws ec2 --profile $iprofile describe-flow-logs --filter Name=resource-id,Values="$vpc_id" --output table | grep "FlowLogStatus\|LogDestinationType\|TrafficType\|LogGroupName\|ResourceId" > $temp_dir/vpc_flow_details
            flow_log_details=`cat $temp_dir/vpc_flow_details`
            # IF flow log not enabled 
            if [ -z "$flow_log_details" ]; 
            then 
                echo -e "Flow log not enabled for $vpc_id"
            else 
            # If flow log enabled
#                echo -e "`cat $temp_dir/vpc_flow_details | awk '{print ","$2","$4}'`"
                # Check flow log destination
                lgdest=`echo $flow_log_details | grep LogDestinationType | awk '{print $9}'`
                # If flow log detination is CW
                if [[ $lgdest == "cloud-watch-logs" ]];
                then
                    lgname=`echo $flow_log_details | grep LogGroupName | awk '{print $14}'`
                    retension_details=`aws logs --profile $iprofile describe-log-groups --log-group-name-prefix "$lgname" --output table | grep retentionInDays | awk '{print $4}'`
                    if [ -z "$retension_details" ];
                    then  
                    #################################################################################################################
                        # Comment lines marked --2 for changing retention and comment lines marked --1 to print current retention
#                        echo -e ",retentionInDays,NeverExpire for $lgname\n"   # --2
                        aws logs --profile $iprofile put-retention-policy --log-group-name $lgname --retention-in-days 7   # --1
                        echo -e "Changed retentionInDays from NeverExpire to 7 days"   # --1
                    else
#                        echo -e ",retentionInDays,$retension_details for $lgname\n"   # --2
                        aws logs --profile $iprofile put-retention-policy --log-group-name $lgname --retention-in-days 7   # --1
                        echo -e "Changed retentionInDays from $retension_details to 7 days"   # --1
                    #################################################################################################################
                    fi 
                fi
            fi
        done
    fi
done
rm -rf $temp_dir/vpc_id_list
rm -rf $temp_dir/vpc_flow_details