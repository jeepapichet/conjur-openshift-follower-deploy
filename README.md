# conjur-openshift-follower-deploy

This repository contains scripts for deploying a Conjur followers to a
OpenShift environment. This script assume that Conjur Master is running 
outside openshift environment and accessible at conjur-master.cyberark.local

**Note:** These scripts are intended for use with Conjur v5

# Setup

The Conjur deployment scripts pick up configuration details from local
environment variables. The setup instructions below walk you through the
necessary steps for configuring your environment and show you which variables
need to be set before deploying.

All environment variables can be set/defined with the bootstrap.env file. Edit the values per instructions below, source the file and run 0_check_dependencies.sh to verify.

The Conjur appliance image can be loaded with _load_conjur_tarfile.sh. The script uses environment variables to locate the tarfile image and the value to use as a tag once it's loaded.

### Platform

If you are working with OpenShift, you will need to set:

```
export PLATFORM=openshift
export OSHIFT_CLUSTER_ADMIN_USERNAME=<name-of-cluster-admin> # system:admin in minishift
export OSHIFT_CONJUR_ADMIN_USERNAME=<name-of-conjur-namespace-admin> # developer in minishift
```

Otherwise, this variable will default to `kubernetes`.

#### OpenShift

OpenShift users should make sure the [integrated Docker registry](https://docs.okd.io/latest/install_config/registry/deploy_registry_existing_clusters.html)
in your OpenShift environment is available.
You must then specify the path to the OpenShift registry like so:

```
export DOCKER_REGISTRY_PATH=docker-registry-<registry-namespace>.<routing-domain>
```

Please make sure that you are logged in to the registry before deploying.

### Kubernetes / OpenShift Configuration

Before deploying Conjur, you must first make sure that you are connected to your
chosen platform with a user that has the `cluster-admin` role. The user must be
able to create namespaces and cluster roles.

#### Conjur Namespace

Provide the name of a namespace in which to deploy Conjur:

```
export CONJUR_NAMESPACE_NAME=<my-namespace>
```

### Conjur Configuration

#### Appliance Image

You need to obtain a Docker image of the Conjur v4 appliance and push it to an
accessible Docker registry. Provide the image and tag like so:

```
export CONJUR_APPLIANCE_IMAGE=<tagged-docker-appliance-image>
```

#### Appliance Configuration

When setting up a new Conjur installation, you must provide an account name and
a password for the admin account:

```
export CONJUR_ACCOUNT=<my_account_name>
export CONJUR_ADMIN_PASSWORD=<my_admin_password>
```

You will also need to provide an ID for the Conjur authenticator that will later
be used in [Conjur policy](https://developer.conjur.net/policy) to provide your
apps with access to secrets through Conjur:

```
export AUTHENTICATOR_ID=<authenticator-id>
```

This ID should describe the cluster in which Conjur resides. For example, if
you're hosting your dev environment on GKE you might use `gke/dev`.

# Usage

### Deploying Conjur

Run `./start` to deploy Conjur. This executes the numbered scripts in sequence
to create and configure a Conjur cluster comprised of one Master, two Standbys,
and two read-only Followers. The final step will print out the necessary info
for interacting with Conjur through the CLI or UI.

### Conjur CLI 

The deploy scripts include a manifest for creating a Conjur CLI container within
the OpenShift/Kubernetes environment that can then be used to interact with Conjur. Deploy
the CLI pod and SSH into it:

```
# Kubernetes
kubectl create -f ./manifests/conjur-cli.yaml
kubectl exec -it [cli-pod-name] bash

# OpenShift
oc create -f ./manifests/conjur-cli.yaml
oc exec -it <cli-pod-name> bash
```

Once inside the CLI container, use the admin credentials to connect to Conjur:

```
conjur init -h conjur-master
```

Follow our [CLI usage instructions](https://developer.conjur.net/cli#quickstart)
to get started with the Conjur CLI.

### Conjur UI

Visit the Conjur UI URL in your browser and login with the admin credentials to
access the Conjur UI.
