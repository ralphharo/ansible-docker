#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# enable interruption signal handling
trap - INT TERM

docker run -it --rm --entrypoint ansible-playbook \
-v $shared_volume:/tmp/playbook:Z $docker_image \
-e "aws_access_key=${aws_access_key}" \
-e "aws_secret_key=${aws_secret_key}" \
"$@"
