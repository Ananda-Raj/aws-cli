# enable-cw-cpu-status

Copy script and run the script providing instance name and profile. Choose and confirm parameters like Instance ID, SNS, Alarm Name.

The script will enable CPU utilization alarm for greater than 90% and Status check alarm (with reboot) with action as specified existing SNS topic.


# ami_checker_delete.sh

Script to Check AMI and delete unused

Conditions that are checked by the Script: Check if the AMI has a tag - DeletionProtection value Yes Check if the AMI is used by any current instance. Check if the AMI is in any AutoScaling Group. Check if the AMI is in any Launch Template (last 2 versions). Check if the AMI is in any Launch Configuration. Check if the AMI is in Elastic Beanstalk environments. Check if the AMI is in Spot Instance requests

Working: From one account, it will take the list if all AMI and check for any one of the 7 condition above. If any is found, it will be ignored. If not, then we will be asked for a prompt if we need to delete that AMI. Choosing Y/y will delete that AMI and associated snapshots. Manual exclusion of AMI for different clients in the environments: This requires the AMI to have a tag - DeletionProtection value Yes . All AMI with this tag is ignored and won’t be deleted.

Execution: This script can be executed with AWS CLI RW privilege for any users on our bastion. They will need to have a .aws/config file with all the required clients. A sample of execution for Phobs-Dev account is attached. We can add this as cron for clients to run every month or can manually run during an audit to clean up the AMIs.

It will give an output like below incase the AMI is detected in Spot request:
```
Taking AMI ami-06ae23b3c92c1db60
This AMI is currently in use for Instance.
This AMI is currently in use for Spot Instance requests sfr-03ea09e3-1111-3332-8c5d-4565245467.
IN USE - This AMI ami-06ae23b3c92c1db60 is currently in use, so not deleting.
Below is an output incase we select N/n instead of Y and it will check for the next AMI.
Taking AMI ami-0ef501c8v50e96eaa
NOT IN USE - This AMI ami-0ef501c8v50e96eaa is not in use, so deleting.
Do you want to proceed with deletion? (Y/N)
n
Deletion canceled. Exiting...

Taking AMI ami-0321b89f2340582b9
NOT IN USE - This AMI ami-0321b89f2340582b9 is not in use, so deleting.
Do you want to proceed with deletion? (Y/N)
y
===================================
ami-0321b89f2340582b9
snap-05bae34549f88f98d
===================================
```


# enable-cw-cpu-status.sh

Copy script, run it providing instance name and profile.
Choose and confirm parameters like Instance ID, SNS, Alarm Name.
The script will enable CPU utilization alarm for greater than 90% and Status check alarm (with reboot) with action as specified existing SNS topic.

# check_cw_StatusCheckFailed, check_cw_CPUUtilization, check_cw_disk_used_percent, check_cw_mem_used_percent

Copy and run the script to list profiles and instances without respective alarms.
Copy the output and save as CSV file to open in Excel or Sheets.

Eg output for check_cw_StatusCheckFailed:

```
client-a
i-07243XXXXXXXXXd61,web-production-asd
i-07aXXXXXXXXXXXX3f,prod.asd.com
i-08aXXXXXXXXXXXXd0,client.asd-production.com
i-0a1XXXXXXXXXXXXf0,client.asd-stage.com
```

# change_vflow_log

The script will change the VPC flow log retention to 7 days for all AWS profiles in .aws/config file. This only applies to logs stored in CloudWatch. Logs destination as S3 won't be affected. Copy the output to a CSV file and open the file for valuation.

You can also use it to display current retention period by commenting out the required lines.
