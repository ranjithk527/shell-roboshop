 #!/bin/bash

SG_ID="sg-084d8f62b70c60d18"   #replace with your security group ID
AMI_ID="ami-0220d79f3f480ecf5"  #replace with your ami ID
ZONE_ID="Z0656987TCB1MV47DYVB" #replace with your zone id
DOMAIN_NAME="awsdevops527.online" #replace with your domain name

for instance in $@
do
    INSTANCE_ID=$(
         aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type "t3.micro" \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text 
    )

    if [ $instance == "frontend" ]; then
         IP=$(
            aws ec2 describe-instances \
         --instance-ids $INSTANCE_ID \
         --query "Reservations[].Instances[].PublicIpAddress'" \
         --output text
         )
    RECORD_NAME="$DOMAIN_NAME" # ex: awsdevops527.online     
         
    else
         IP=$(
            aws ec2 describe-instances \
         --instance-ids $INSTANCE_ID \
         --query 'Reservations[].Instances[].PrivateIpAddress' \
         --output text
         )
    RECORD_NAME="$instance.$DOMAIN_NAME" # ex: mongodb.awsdevops527.online     
    fi     

    echo "IP address : $IP"

    aws route53 change-resource-record-sets \
     --hosted-zone-id $ZONE_ID \
     --change-batch '
     {
      "Comment": "Updating record",
      "Changes": [
     {
      "Action": "UPSERT",
      "ResourceRecordSet": {
        "Name": "'$RECORD_NAME'",
        "Type": "A",
        "TTL": 1,
        "ResourceRecords": [
          {
            "Value": "'$IP'"
          }
        ]
     }
     }
  ]
}
'
    echo "record updated for $instance"



done