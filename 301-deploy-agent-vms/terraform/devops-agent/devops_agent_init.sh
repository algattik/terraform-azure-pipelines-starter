#!/bin/sh

#strict mode, fail on error
set -euo pipefail


echo MSG1
echo MSG2 >&2

test -n "$1" || "The argument az_devops_url must be provided"
az_devops_url="$1"
test -n "$2" || "The argument az_devops_pat must be provided"
az_devops_pat="$2"
test -n "$3" || "The argument az_devops_agent_pool must be provided"
az_devops_agent_pool="$3"
test -n "$4" || "The argument az_devops_agents_per_vm must be provided"
az_devops_agents_per_vm="$4"


echo "start"

echo "install Ubuntu packages"

# To make it easier for build and release pipelines to run apt-get,
# configure apt to not require confirmation (assume the -y argument by default)
export DEBIAN_FRONTEND=noninteractive
echo "APT::Get::Assume-Yes \"true\";" > /etc/apt/apt.conf.d/90assumeyes

apt-get update
apt-get install -y --no-install-recommends \
        ca-certificates \
        jq \
        apt-transport-https \
        docker.io


echo "Creating agent pool if needed, and validating PAT token"

if ! curl -fu ":$az_devops_pat" "$az_devops_url/_apis/distributedtask/pools?poolName=mypool3&api-version=5.1 | jq -e '.count>=0'; then
    curl -fu ":$az_devops_pat" "$az_devops_url/_apis/distributedtask/pools?api-version=5.1 -H "Content-Type:application/json" -d '{"name":"'"$az_devops_agent_pool"'"}'
fi


echo "Allowing agent to run docker"

usermod -aG docker azuredevopsuser

echo "Installing Azure CLI"

curl -sL https://aka.ms/InstallAzureCLIDeb | bash

echo "install VSTS Agent"

cd /home/azuredevopsuser
mkdir -p agent
cd agent

AGENTRELEASE="$(curl -s https://api.github.com/repos/Microsoft/azure-pipelines-agent/releases/latest | grep -oP '"tag_name": "v\K(.*)(?=")')"
AGENTURL="https://vstsagentpackage.azureedge.net/agent/${AGENTRELEASE}/vsts-agent-linux-x64-${AGENTRELEASE}.tar.gz"
echo "Release "${AGENTRELEASE}" appears to be latest" 
echo "Downloading..."
wget -q -O agent_package.tar.gz ${AGENTURL} 

# Generate random prefix for agent names
if ! test -e "host_uuid.txt"; then
  uuidgen > host_uuid.txt.tmp
  mv host_uuid.txt.tmp host_uuid.txt
fi
host_id=$(cat host_uuid.txt)

for agent_num in $(seq 1 $az_devops_agents_per_vm); do
  agent_dir="agent-$agent_num"
  mkdir -p "$agent_dir"
  pushd "$agent_dir"
    agent_id="${agent_num}_${host_id}"
    echo "installing agent $agent_id"
    tar zxvf ../agent_package.tar.gz
    chmod -R 777 .
    echo "extracted"
    ./bin/installdependencies.sh
    echo "dependencies installed"
    sudo -u azuredevopsuser ./config.sh --unattended --url "$az_devops_url" --auth pat --token "$az_devops_pat" --pool "$az_devops_agent_pool" --agent "$agent_id" --acceptTeeEula --work ./_work --runAsService
    echo "configuration done"
    ./svc.sh install
    echo "service installed"
    ./svc.sh start
    echo "service started"
    echo "config done"
  popd
done
