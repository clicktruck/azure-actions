# Tanzu Run Shell Script Github Action

## Prerequisites

* [Docker](https://docs.docker.com/desktop/)
  * A [subscription](https://www.docker.com/blog/updating-product-subscriptions/) is required for business use.
* An account on the [VMware Marketplace](https://marketplace.cloud.vmware.com/)


## Building

Consult the [Dockerfile](Dockerfile).

To build a portable container image, execute

```bash
docker build -t clicktruck/tanzu-runsh-setup-action .
```


## Launching

Execute

```bash
docker run --rm -it \
  -e TANZU_CLI_ENABLED=true \
  -e AZURE_SUBSCRIPTION_ID={azure-subscription-id} -e AZURE_AD_TENANT_ID={azure-tenant-id} -e AZURE_AD_CLIENT_ID={azure-ad-client-id} \
  -e AZURE_AD_CLIENT_SECRET={azure-ad-client-secret} \
  -v "/var/run/docker.sock:/var/run/docker.sock:rw" \
  clicktruck/tanzu-runsh-setup-action {base64-encoded-script-contents} '{space-separated-script-arguments}' {base64-encoded-kubeconfig-contents}
```
> Replace `{base64-encoded-script-contents}`, `{space-separated-script-arguments}`, and `{base64-encoded-kubeconfig-contents}` as well; should be self-evident what to supply.


## Example usage

Dispatch

```yaml
name: "test-dispatch-tanzu-runsh"

on:
  workflow_dispatch:
    inputs:
      script-contents:
        description: "The base64 encoded contents of a shell script"
        required: true
      script-arguments:
        description: "A space separated set of arguments that the script will consume"
        required: true
      kubeconfig-contents:
        description: "The base64 encoded contents of a .kube/config file that already has the current Kubernetes cluster context set"
        required: true

jobs:
  tanzu-cli:
    uses: ./.github/workflows/test-tanzu-runsh.yml
    secrets:
      KUBECONFIG_CONTENTS: ${{ github.event.inputs.kubeconfig-contents }}
      SCRIPT_CONTENTS: ${{ github.event.inputs.script-contents }}
      SCRIPT_ARGS: ${{ github.event.inputs.script-arguments }}
      AZURE_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      AZURE_AD_TENANT_ID: ${{ secrets.AZURE_AD_TENANT_ID }}
      AZURE_AD_CLIENT_ID: ${{ secrets.AZURE_AD_CLIENT_ID }}
      AZURE_AD_CLIENT_SECRET: ${{ secrets.AZURE_AD_CLIENT_SECRET }}
```

Call

```yaml
name: "test-administer-tanzu-runsh"

on:
  workflow_call:
    secrets:
      KUBECONFIG_CONTENTS:
        required: true
      SCRIPT_CONTENTS:
        required: true
      SCRIPT_ARGS:
        required: true
      AZURE_SUBSCRIPTION_ID:
        required: true
      AZURE_AD_TENANT_ID:
        required: true
      AZURE_AD_CLIENT_ID:
        required: true
      AZURE_AD_CLIENT_SECRET:
        required: true

jobs:
  run:
    runs-on: ubuntu-22.04

    steps:
    # Checkout the repository to the GitHub Actions runner
    - name: Checkout
      uses: actions/checkout@v4

    # Execute a script
    - name: Execute shell script that may invoke a series of kubectl or tanzu CLI commands
      uses: ./docker/actions/aws/tanzu-runsh-setup-action
      with:
        script-contents: ${{ secrets.SCRIPT_CONTENTS }}
        script-arguments: ${{ secrets.SCRIPT_ARGS}}
        kubeconfig-contents: ${{ secrets.KUBECONFIG_CONTENTS }}
        azure-subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
        azure-tenant-id: ${{ secrets.AZURE_AD_TENANT_ID }}
        azure-ad-client-id: ${{ secrets.AZURE_AD_CLIENT_ID }}
        azure-ad-client-secret: ${{ secrets.AZURE_AD_CLIENT_SECRET }}

```

## Credits

* [Creating a Docker container action](https://docs.github.com/en/actions/creating-actions/creating-a-docker-container-action)
* [Custom GitHub Actions with Docker](https://dev.to/sethetter/custom-github-actions-with-docker-3ik3)
* [How can I install Docker inside an Alpine container](https://stackoverflow.com/questions/54099218/how-can-i-install-docker-inside-an-alpine-container)
* [How to pass arguments to Shell Script through docker run](https://stackoverflow.com/questions/32727594/how-to-pass-arguments-to-shell-script-through-docker-run)
