#!/bin/bash
# Script Name: generate_ansible_aws_inventory.sh
# Purpose: Create an ansible host yaml file for AWS hosts for Tag Server-type
# Prerequisites: AWS cli commands should be working prior to executing this script

mkdir -p inventory
value1=$1
value2=$2
value3=$3
aws_region=$4

_AddAll()
{
echo [elasticsearch-ec2] > inventory/cluster.tmp
APP_TYPE=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:cluster_name,Values=${value1}" "Name=tag:Environment,Values=${value2}" "Name=tag:Owner,Values=${value3}" --query "Reservations[*].Instances[*][Tags[?Key=='Name'].Value]"  --output text`
for inst in ${APP_TYPE}
do
echo " [${inst}]" > inventory/${inst}.tmp
SERVERSLIST=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query "Reservations[*].Instances[*][Tags[?Key=='Name'].Value]"  --output text`
for ipaddress in ${SERVERSLIST}
do
PUBLICIP=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query 'Reservations[].Instances[].[PublicIpAddress]'  --output text`
PRIVATEIP=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query 'Reservations[].Instances[].[PrivateIpAddress]'  --output text`
NODETAG=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query "Reservations[].Instances[].[Tags[?Key=='node_type'].Value]"  --output text`
INSTANCEFQDN=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query "Reservations[].Instances[].[Tags[?Key=='instance_fqdn'].Value]"  --output text`
echo "  "${ipaddress} ansible_ssh_host="${PUBLICIP}" provision_inventory_private_ip="${PRIVATEIP}" provision_inventory_public_ip="${PUBLICIP}" provision_inventory_role="${NODETAG}" cluster_name="${value1}" provision_inventory_fqdn="${INSTANCEFQDN}" provision_inventory_hostname="${inst}" >> inventory/cluster.tmp
done

done
}
#
# _AddAll

# mv inventory/cluster.tmp inventory/${value1}

_AddMaster()
{
echo [elasticsearch-ec2-master] > inventory/master.tmp
APP_TYPE=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:cluster_name,Values=${value1}" "Name=tag:Environment,Values=${value2}" "Name=tag:Owner,Values=${value3}" "Name=tag:node_type,Values=master" --query "Reservations[*].Instances[*][Tags[?Key=='Name'].Value]"  --output text`
for inst in ${APP_TYPE}
do
echo " [${inst}]" > inventory/${inst}.tmp
SERVERSLIST=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query "Reservations[*].Instances[*][Tags[?Key=='Name'].Value]"  --output text`
for ipaddress in ${SERVERSLIST}
do
PUBLICIP=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query 'Reservations[].Instances[].[PublicIpAddress]'  --output text`
PRIVATEIP=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query 'Reservations[].Instances[].[PrivateIpAddress]'  --output text`
NODETAG=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query "Reservations[].Instances[].[Tags[?Key=='node_type'].Value]"  --output text`
INSTANCEFQDN=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query "Reservations[].Instances[].[Tags[?Key=='instance_fqdn'].Value]"  --output text`
echo "  "${ipaddress} ansible_ssh_host="${PUBLICIP}" provision_inventory_private_ip="${PRIVATEIP}" provision_inventory_public_ip="${PUBLICIP}" provision_inventory_role="${NODETAG}" cluster_name="${value1}" provision_inventory_fqdn="${INSTANCEFQDN}" provision_inventory_hostname="${inst}" >> inventory/master.tmp
done

done
}

_AddWorker()
{
echo [elasticsearch-ec2-data] > inventory/worker.tmp
APP_TYPE=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:cluster_name,Values=${value1}" "Name=tag:Environment,Values=${value2}" "Name=tag:Owner,Values=${value3}" "Name=tag:node_type,Values=data" --query "Reservations[*].Instances[*][Tags[?Key=='Name'].Value]"  --output text`
for inst in ${APP_TYPE}
do
echo " [${inst}]" > inventory/${inst}.tmp
SERVERSLIST=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query "Reservations[*].Instances[*][Tags[?Key=='Name'].Value]"  --output text`
for ipaddress in ${SERVERSLIST}
do
PUBLICIP=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query 'Reservations[].Instances[].[PublicIpAddress]'  --output text`
PRIVATEIP=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query 'Reservations[].Instances[].[PrivateIpAddress]'  --output text`
NODETAG=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query "Reservations[].Instances[].[Tags[?Key=='node_type'].Value]"  --output text`
INSTANCEFQDN=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query "Reservations[].Instances[].[Tags[?Key=='instance_fqdn'].Value]"  --output text`
echo "  "${ipaddress} ansible_ssh_host="${PUBLICIP}" provision_inventory_private_ip="${PRIVATEIP}" provision_inventory_public_ip="${PUBLICIP}" provision_inventory_role="${NODETAG}" cluster_name="${value1}" provision_inventory_fqdn="${INSTANCEFQDN}" provision_inventory_hostname="${inst}" >> inventory/worker.tmp
done

done
}

_AddAll
_AddMaster
_AddWorker
mv inventory/cluster.tmp inventory/${value1}
cat inventory/master.tmp >> inventory/${value1}
cat inventory/worker.tmp >> inventory/${value1}
rm inventory/*.tmp
