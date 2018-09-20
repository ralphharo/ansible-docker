#!/bin/bash

if [ -z "$spark_deploy" ]
then
    echo "spark_deploy is not set" && exit 1;
fi
ansible-galaxy install -r $spark_deploy/ansible-pb-spark-tls/roles/requirements.yml -p $spark_deploy/ansible-pb-spark-tls/roles

ansible-galaxy install -r $spark_deploy/roles/requirements.yml -p $spark_deploy/ansible-pb-spark-tls/roles
