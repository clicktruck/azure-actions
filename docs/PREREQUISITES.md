# azure-actions » prerequisites

* [Increase Azure Quotas](#increase-azure-quotas)
* [Setup an Azure service principal](#setup-an-azure-service-principal)
* [(Optional) Setup a Github SSH key-pair](#optional-setup-a-github-ssh-key-pair)
* [Setup a Personal Access Token in Github](#setup-a-personal-access-token-in-github)
* [Configure Github Secrets](#configure-github-secrets)

## Increase Azure Quotas

There are a few Azure subscription default quotas that will need to be adjusted.

1. Regional vCPU quota - In the Azure portal, navigate to the Subscription and on the left pane select `Usage + Quotas` > `Total Regional vCPUs` and set to 25.
2. Family vCPU quota - You will also need to increase the quota for the family of vCPUs you'll be using for cluster nodes.  Example: if you plan to use the `Standard_D4_v3` vCPU type, you'll need to increase the  `Standard Dv3 Family vCPUs` quota.  Whichever family of vCPU you choose, also set the quota to 25.
3. IP Addresses - You may also need to increase:  `Public IP Addresses - Standard`, `Public IP Addresses - Basic`, and `Static Public IP Addresses`.  These will require opening a service ticket that is usually resolved within an hour.  Set these quotas to 30.

> Note:  The above quotas will be enough to deploy the infrastructure needed for installing TAP.  Individual mileage may vary depending on existing resources.

## Setup an Azure service principal

First, log into Azure.

```bash
az login --service-principal -u {client-id} -p {secret-id} --tenant {tenant-id}
```

Then set the needed environment variables.

```bash
# Your Azure subscription identifier
export AZURE_SUBSCRIPTION_ID=
# The name of the service principal that will be created [ e.g., tap-sp ]
export AZURE_SP_NAME=
# The role assigned to the service principal [ e.g., Contributor, Owner ]
export AZURE_SP_ROLE=
```

Then run the following script found [here](https://github.com/clicktruck/scripts/blob/main/azure/create-azure-service-principal.sh).

```bash
cd /tmp
gh repo clone clicktruck/scripts
./scripts/azure/create-azure-service-principal.sh
```
> In this case we use the `Owner` role. This is needed to manage RBAC. Also note that for the SP to work with the Github Actions using the Azure CLI, the `--sdk-auth` flag which is deprecated is still needed.  This is due to how the Github Action functions.

The output of this script will be a JSON block of credentials to be used in the following steps.
> Note: Store the output of the service principal creation securely. It contains credentials with elevated permissions within your subscription.

## (Optional) Setup a Github SSH key-pair

You will need to create a new public/private SSH key-pair in order to work with (i.e., pull from/push to) private git repositories (e.g., Github, Gitlab, Azure Devops).

Here's how to set up such a key-pair for named repo providers:

* [Github](https://docs.github.com/en/developers/overview/managing-deploy-keys)

Also see [Git Authentication](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.9/tap/scc-git-auth.html).


## Setup a Personal Access Token in Github

A PAT is required so that workflows can add secrets to the repository in order to be used in downstream jobs.  Documentation can be found [here](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token).

> We are using this personal access token to create secrets for the `azurerm` backend for Terraform


## Configure Github Secrets

Setup some Github secrets with the SP credentials.  Documentation can be found [here](https://docs.github.com/en/actions/security-guides/encrypted-secrets).  You might also consider using [gh secret set](https://cli.github.com/manual/gh_secret_set) command to set these individually.  Or, after exporting all environment variables below, execute [gh-secrets-setup.sh](https://github.com/clicktruck/scripts/blob/main/gh-set-secrets.sh) at the command-line passing `azure` as an execution argument.

```bash
# Will be the service principal ID from above `appId`
export AZURE_AD_CLIENT_ID=
# The secret that was created as part of the Azure Service Principal `password`
export AZURE_AD_CLIENT_SECRET=
# The Azure AD tenant ID where the service principal was created
export AZURE_AD_TENANT_ID=
# The Azure Subscription ID where you want to host this environment
export AZURE_SUBSCRIPTION_ID=
# Paste the entire contents of the SP json that was output from the script above here. This is needed for the `azurelogin` Github Action.
export AZURE_CREDENTIALS=
# Required for setting up the storage accounts for managing Terraform state (e.g., `eastus2`)
export AZURE_REGION=
```

You'll also want to [create another secret](https://github.com/clicktruck/scripts/blob/main/set-personal-access-token.sh) whose value is the fine-grained personal token you created in the prior step.

```bash
export PA_TOKEN=
```
