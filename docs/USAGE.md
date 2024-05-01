# azure-actions » usage

Review this curated collection of dispatch workflows.

## Guides

### Quick

Take this path when you want to get up-and-running as quickly as possible with the least amount of fuss.

| Action | Link |
| :---   | :---: |
| _Create workflows_ | Choose `create` before clicking on the `Run workflow` button |
| Remote Backend Support | [:white_check_mark:](../../../actions/workflows/setup-azure-provided-remote-backend.yml) |
| Toolset image | [:white_check_mark:](../../../actions/workflows/azure-ubuntu-22_04.yml) |
| Record or remember the resource group name you specify in this action as you will need it in later steps. | |
| DNS Zone for base domain | [:white_check_mark:](../../../actions/workflows/azure-main-dns-dispatch.yml) |
| DNS Zone for sub domain | [:white_check_mark:](../../../actions/workflows/azure-child-dns-dispatch.yml) |
| Create workshop environment | [:white_check_mark:](../../../actions/workflows/azure-e2e.yml) |
| _Cleanup workflows_ | Choose `destroy` before clicking on the `Run workflow` button |
| Destroy workshop environment | [:white_check_mark:](../../../actions/workflows/azure-e2e-destroy.yml) |
|  This action should be run with th same inputs used to create an environment. If this is multi-tenant you will want to run this once for each tenant. Additionally there is an option to clean up core components this is defaulted to `no` only choose yes if you are destroying all tenant environments since this will destroy the main DNS resource group as well as the Shared Image Gallery. |  |
| DNS Zone for sub domain | [:white_check_mark:](../../../actions/workflows/azure-child-dns-dispatch.yml) |
| DNS Zone for base domain | [:white_check_mark:](../../../actions/workflows/azure-main-dns-dispatch.yml) |
| Clean Workflow Logs | [:white_check_mark:](../../../actions/workflows/clean-workflow-run-logs.yml) |


### Deliberate

Administer resources one at a time.

There are two types of actions defined, those that can be manually triggered (i.e., dispatched), and those that can only be called by another action.  All actions are located [here](../../../actions) and can be run by providing the required parameters.  Go [here](../../.github/workflows) to inspect the source for each action.

> Note that for most dispatch actions, you have the option to either create or destroy the resources.

#### Modules

| Module       | Github Action       | Terraform               |
| :---       | :---:               | :---:                   |
| Resource group |[:white_check_mark:](../../../actions/workflows/azure-resource-group-dispatch.yml) | [:white_check_mark:](https://github.com/clicktruck/azure-terraform/tree/main/modules/resource-group) |
| If your environment will be multi-tenant and you want to maintain separation of control between participants and their associated child DNS domains, create a resource group for the parent DNS zone separately from the rest of the resources.||
| Key Vault | [:white_check_mark:](../../../actions/workflows/azure-keyvault-dispatch.yml) | [:white_check_mark:](https://github.com/clicktruck/azure-terraform/tree/main/modules/keyvault) |
| Key Vault Secrets | [:white_check_mark:](../../../actions/workflows/azure-keyvault-secrets-dispatch.yml) | [:white_check_mark:](https://github.com/clicktruck/azure-terraform/tree/main/modules/keyvault-secrets) |
| DNS Zone for main domain | [:white_check_mark:](../../../actions/workflows/azure-main-dns-dispatch.yml) | [:white_check_mark:](https://github.com/clicktruck/azure-terraform/tree/main/modules/main-dns) |
| DNS Zone for sub domain | [:white_check_mark:](../../../actions/workflows/azure-child-dns-dispatch.yml) | [:white_check_mark:](https://github.com/clicktruck/azure-terraform/tree/main/modules/child-dns) |
| Virtual Network | [:white_check_mark:](../../../actions/workflows/azure-virtual-network-dispatch.yml) | [:white_check_mark:](https://github.com/clicktruck/azure-terraform/tree/main/modules/virtual-network) |
| AKS Cluster | [:white_check_mark:](../../../actions/workflows/azure-k8s-cluster-dispatch.yml) | [:white_check_mark:](https://github.com/clicktruck/azure-terraform/tree/main/modules/cluster) |
| Container registry | [:white_check_mark:](../../../actions/workflows/azure-container-registry-dispatch.yml) | [:white_check_mark:](https://github.com/clicktruck/azure-terraform/tree/main/modules/registry) |
| Bastion | [:white_check_mark:](../../../actions/workflows/azure-bastion-dispatch.yml) | [:white_check_mark:](https://github.com/clicktruck/azure-terraform/tree/main/modules/bastion) |


## Accessing credentials

All Credentials are stored in Azure Key Vault. There is a KV per resource group (participant) where the credentials are stored that are specific to resources created for that participant (see architecture diagram).

There is only one credential that needs to be pulled down to get started, all other credentials will be accessible from the bastion host. This credential is the private ssh key for the bastion host. If you are the workshop owner and working in a multi-tenant environment you will need to hand this credential out to each participant. From there each participant will be able to access everything they need from the bastion host.

First, log into Azure using the service principal you created earlier.

```bash
az login --service-principal -u <clientID> -p <clientSecret> --tenant <tenantId>
```

Then, run the script to pull down all private keys along with the IP address of the bastion that it is associated with. This will create a folder `workshop-sshkeys` and loop over each resource group that matches `participant-x` it will then get the bastion IP and the ssh key from vault and write a file out into the directory with SSH key in it and ip in the name (e.g, `participant-x-bastion.172.16.78.9.pem`).

```bash
cd /tmp
gh repo clone clicktruck/scripts
./scripts/azure/fetch-azure-ssh-key.sh
```

Once you SSH to the VM there will be credentials for the ACR registry in the home directory in files called `acr-user` and `acr-password` there will also be a kubeconfig in the home directory as well as it has been added under `~/.kube/config`.

