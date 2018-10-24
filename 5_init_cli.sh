#!/bin/bash 
set -euo pipefail

. utils.sh

set_namespace $CONJUR_NAMESPACE_NAME

announce "Initializing Conjur CLI"

cli_pod_name=$(oc get pods -l app=conjur-cli --no-headers  | awk '{ print $1 }')

$cli exec -it $cli_pod_name -- conjur init -u https://conjur-master -a cyberark
