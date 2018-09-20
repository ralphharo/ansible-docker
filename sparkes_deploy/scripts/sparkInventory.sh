#!/bin/bash
# Script Name: generate_ansible_aws_inventory.sh
# Purpose: Create an ansible host yaml file for AWS hosts for Tag Server-type
# Prerequisites: AWS cli commands should be working prior to executing this script
cluster_name=$1
environment=$2
owner=$3
aws_region=$4

mkdir -p inventory

_AddAll()
{
echo [spark-ec2] > inventory/cluster.tmp

APP_TYPE=`aws ec2 describe-instances --filters "Name=tag:cluster_name,Values=${cluster_name}" "Name=tag:Environment,Values=${environment}" "Name=tag:Owner,Values=${owner}" --query "Reservations[*].Instances[*][Tags[?Key=='Name'].Value]"  --output text`
for inst in ${APP_TYPE}
do
echo " [${inst}]" > inventory/${inst}.tmp
SERVERSLIST=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query "Reservations[*].Instances[*][Tags[?Key=='Name'].Value]"  --output text`
for ipaddress in ${SERVERSLIST}
do
PUBLICIP=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query 'Reservations[].Instances[].[PublicIpAddress]'  --output text`
PRIVATEIP=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query 'Reservations[].Instances[].[PrivateIpAddress]'  --output text`
NODETAG=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query "Reservations[].Instances[].[Tags[?Key=='node_type'].Value]"  --output text`
INSTANCEID=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query 'Reservations[].Instances[].[InstanceId]'  --output text`
INSTANCEFQDN=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query "Reservations[].Instances[].[Tags[?Key=='Name'].Value]"  --output text`
echo "  "${ipaddress} ansible_ssh_host="${PUBLICIP}" instanceId="${INSTANCEID}" provision_inventory_private_ip="${PRIVATEIP}" provision_inventory_public_ip="${PUBLICIP}" provision_inventory_role="${NODETAG}" cluster_name="${cluster_name}" provision_inventory_fqdn="${INSTANCEFQDN}" provision_inventory_hostname="${inst}" >> inventory/cluster.tmp
done

done
}

_AddMaster()
{
echo [spark-ec2-master] > inventory/master.tmp
APP_TYPE=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:cluster_name,Values=${cluster_name}" "Name=tag:Environment,Values=${environment}" "Name=tag:Owner,Values=${owner}" "Name=tag:node_type,Values=master" --query "Reservations[*].Instances[*][Tags[?Key=='Name'].Value]"  --output text`
for inst in ${APP_TYPE}
do
echo " [${inst}]" > inventory/${inst}.tmp
SERVERSLIST=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query "Reservations[*].Instances[*][Tags[?Key=='Name'].Value]"  --output text`
for ipaddress in ${SERVERSLIST}
do
PUBLICIP=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query 'Reservations[].Instances[].[PublicIpAddress]'  --output text`
PRIVATEIP=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query 'Reservations[].Instances[].[PrivateIpAddress]'  --output text`
NODETAG=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query "Reservations[].Instances[].[Tags[?Key=='node_type'].Value]"  --output text`
INSTANCEID=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query 'Reservations[].Instances[].[InstanceId]'  --output text`
INSTANCEFQDN=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query "Reservations[].Instances[].[Tags[?Key=='Name'].Value]"  --output text`
echo "  "${ipaddress} ansible_ssh_host="${PUBLICIP}" instanceId="${INSTANCEID}" provision_inventory_private_ip="${PRIVATEIP}" provision_inventory_public_ip="${PUBLICIP}" provision_inventory_role="${NODETAG}" cluster_name="${cluster_name}" provision_inventory_fqdn="${INSTANCEFQDN}" provision_inventory_hostname="${inst}" >> inventory/master.tmp
done

done
}

_AddWorker()
{
echo [spark-ec2-worker] > inventory/worker.tmp
APP_TYPE=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:cluster_name,Values=${cluster_name}" "Name=tag:Environment,Values=${environment}" "Name=tag:Owner,Values=${owner}" "Name=tag:node_type,Values=worker" --query "Reservations[*].Instances[*][Tags[?Key=='Name'].Value]"  --output text`
for inst in ${APP_TYPE}
do
echo " [${inst}]" > inventory/${inst}.tmp
SERVERSLIST=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query "Reservations[*].Instances[*][Tags[?Key=='Name'].Value]"  --output text`
for ipaddress in ${SERVERSLIST}
do
PUBLICIP=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query 'Reservations[].Instances[].[PublicIpAddress]'  --output text`
PRIVATEIP=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query 'Reservations[].Instances[].[PrivateIpAddress]'  --output text`
# PUBLICDNS=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query 'Reservations[].Instances[].[PublicDnsName]'  --output text`
NODETAG=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query "Reservations[].Instances[].[Tags[?Key=='node_type'].Value]"  --output text`
INSTANCEID=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query 'Reservations[].Instances[].[InstanceId]'  --output text`
INSTANCEFQDN=`aws ec2 describe-instances --region ${aws_region} --filters "Name=tag:Name,Values=${inst}" --query "Reservations[].Instances[].[Tags[?Key=='Name'].Value]"  --output text`
echo "  "${ipaddress} ansible_ssh_host="${PUBLICIP}" instanceId="${INSTANCEID}" provision_inventory_private_ip="${PRIVATEIP}" provision_inventory_public_ip="${PUBLICIP}" provision_inventory_role="${NODETAG}" cluster_name="${cluster_name}" provision_inventory_fqdn="${INSTANCEFQDN}" provision_inventory_hostname="${inst}" >> inventory/worker.tmp
done

done
}
# _AddVars
_AddAll
_AddMaster
_AddWorker
# mv inventory/vars.tmp inventory/${cluster_name}
mv inventory/cluster.tmp inventory/${cluster_name}
cat inventory/master.tmp >> inventory/${cluster_name}
cat inventory/worker.tmp >> inventory/${cluster_name}
rm inventory/*.tmp
