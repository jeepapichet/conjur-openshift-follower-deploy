#Run this once to initialize OpenShift Authenticator
#!/bin/bash
set -euo pipefail

. utils.sh

#!/bin/bash
set -euo pipefail

. utils.sh

announce "Load Conjur Kubernetes Authenticator Policy"

pushd policy
  mkdir -p ./generated
  sed -e "s#{{ AUTHENTICATOR_ID }}#$AUTHENTICATOR_ID#g" ./template/cluster-authn-svc.template.yml > ./generated/cluster-authn-svc.yml
popd

# Create the random database password

announce "Loading Conjur policy."

docker run --rm -v $PWD/policy:/policy -v $HOME:/root -it cyberark/conjur-cli:5 policy load root policy/cluster-authn-svc.yml

announce "Initializing Conjur certificate authority."

docker exec conjur-master chpst -u conjur conjur-plugin-service possum rake authn_k8s:ca_init["conjur/authn-k8s/$AUTHENTICATOR_ID"]

