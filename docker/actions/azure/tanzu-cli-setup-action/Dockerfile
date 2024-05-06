FROM ubuntu:22.04

LABEL  "com.github.actions.name"="tanzu-runsh-setup-action" \
       "com.github.actions.icon"="server" \
       "com.github.actions.color"="blue" \
       "repository"="https://github.com/clicktruck/azure-actions/docker/actions/azure/tanzu-cli-setup-action" \
       "maintainer"="Chris Phillipson <chris@clicktruck.org>"

ENV HELM_VERSION=3.14.4 \
    IMGPKG_VERSION=0.42.1 \
    KAPP_VERSION=0.62.0 \
    KBLD_VERSION=0.43.0 \
    KCTRL_VERSION=0.51.0 \
    KUBECTL_VERSION=1.29.4 \
    LEFTOVERS_VERSION=0.62.0 \
    VENDIR_VERSION=0.40.1 \
    YQ_VERSION=4.43.1 \
    YTT_VERSION=0.49.0

RUN apt update && apt install apt-transport-https bash ca-certificates curl gnupg iptables jq lsb-release python3 python3-pip software-properties-common wget -y --no-install-recommends \
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    && echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt update \
    && apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y \
    && echo "ulimits: $(ulimit -Sn):$(ulimit -Hn)" \
    && sed -i 's/ulimit -Hn/# ulimit -Hn/g' /etc/init.d/docker \
    && service docker start \
    && curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null \
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/azure-cli.list \
    && apt update \
    && apt install -y azure-cli \
    && curl -s -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    && wget -O imgpkg https://github.com/vmware-tanzu/carvel-imgpkg/releases/download/v${IMGPKG_VERSION}/imgpkg-linux-amd64 \
    && chmod +x imgpkg \
    && mv imgpkg /usr/local/bin \
    && wget -O ytt https://github.com/vmware-tanzu/carvel-ytt/releases/download/v${YTT_VERSION}/ytt-linux-amd64 \
    && chmod +x ytt \
    && mv ytt /usr/local/bin \
    && wget -O vendir https://github.com/vmware-tanzu/carvel-vendir/releases/download/v${VENDIR_VERSION}/vendir-linux-amd64 \
    && chmod +x vendir \
    && mv vendir /usr/local/bin \
    && wget -O kapp https://github.com/vmware-tanzu/carvel-kapp/releases/download/v${KAPP_VERSION}/kapp-linux-amd64 \
    && chmod +x kapp \
    && mv kapp /usr/local/bin \
    && wget -O kbld https://github.com/vmware-tanzu/carvel-kbld/releases/download/v${KBLD_VERSION}/kbld-linux-amd64 \
    && chmod +x kbld \
    && mv kbld /usr/local/bin \
    && wget -O kctrl https://github.com/vmware-tanzu/carvel-kapp-controller/releases/download/v${KCTRL_VERSION}/kctrl-linux-amd64 \
    && chmod +x kctrl \
    && mv kctrl /usr/local/bin \
    && curl -LO "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" \
    && tar -xvf helm-v${HELM_VERSION}-linux-amd64.tar.gz \
    && mv linux-amd64/helm /usr/local/bin \
    && wget https://github.com/genevieve/leftovers/releases/download/v${LEFTOVERS_VERSION}/leftovers-v${LEFTOVERS_VERSION}-linux-amd64 \
    && mv leftovers-v${LEFTOVERS_VERSION}-linux-amd64 leftovers \
    && chmod +x leftovers \
    && mv leftovers /usr/local/bin \
    && curl -LO https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64 \
    && chmod +x yq_linux_amd64 \
    && mv yq_linux_amd64 /usr/local/bin/yq \
    && rm -rf /var/lib/apt/lists/

# Copies scripts from action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
