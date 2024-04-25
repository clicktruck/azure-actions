#!/usr/bin/env bash

# Entrypoint for tanzu-runsh-setup-action

# This script expects that the following environment variables have been set:
#
# * TANZU_CLI_ENABLED
# * AZURE_SUBSCRIPTION_ID
# * AZURE_AD_TENANT_ID
# * AZURE_AD_CLIENT_ID
# * AZURE_AD_CLIENT_SECRET
#


if [ x"${AZURE_SUBSCRIPTION_ID}" == "x" ] || [ x"${AZURE_AD_TENANT_ID}" == "x" ] || [ x"${AZURE_AD_CLIENT_ID}" == "x" ] || [ x"${AZURE_AD_CLIENT_SECRET}" == "x" ]; then
  echo "Expected AZURE_SUBSCRIPTION_ID, AZURE_AD_TENANT_ID, AZURE_AD_CLIENT_ID, and AZURE_AD_CLIENT_SECRET enviroment variables to have been set!"
  exit 1;
fi

if [ "${TANZU_CLI_ENABLED}" == "true" ]; then
  mkdir -p /etc/apt/keyrings
  curl -fsSL https://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub | gpg --dearmor -o /etc/apt/keyrings/tanzu-archive-keyring.gpg
  echo "deb [signed-by=/etc/apt/keyrings/tanzu-archive-keyring.gpg] https://storage.googleapis.com/tanzu-cli-os-packages/apt tanzu-cli-jessie main" | tee /etc/apt/sources.list.d/tanzu.list
  apt update
  apt install tanzu-cli -y
  tanzu config eula accept
  TANZU_CLI_CEIP_OPT_IN_PROMPT_ANSWER="no"
  tanzu plugin group search
  tanzu plugin install --group vmware-tanzucli/essentials
  tanzu plugin install --group vmware-tap/default
  tanzu plugin install --group vmware-tap_saas/app-developer
  tanzu plugin install --group vmware-tap_saas/platform-engineer
  tanzu plugin install --group vmware-tkg/default
  tanzu plugin install --group vmware-tmc/default
  tanzu plugin install --group vmware-vsphere/default
else
  echo "Not installing tanzu CLI nor configuring plugins"
fi

if [ -z "$3" ]; then
  echo "Base64 encoded KUBECONFIG contents not supplied"
else
  echo "Exporting KUBECONFIG environment variable."
  mkdir -p $HOME/.kube
  echo "$3" | base64 -d > $HOME/.kube/config
  chmod 600 $HOME/.kube/config
  export KUBECONFIG=$HOME/.kube/config
fi

echo "Executing script."
echo "$1" | base64 -d > run.sh
chmod +x run.sh
read -r -a args <<< "$2"
. ./run.sh ${args[@]}
