#!/bin/bash
RG=rg-agrosync-devops
LOCATION=southafricanorth
VM=vm-agrosync

az group create --name $RG --location $LOCATION

az vm create --resource-group $RG --name $VM \
  --image Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest \
  --size Standard_B2ls_v2 --admin-username azureuser \
  --generate-ssh-keys --public-ip-sku Standard

az vm open-port --resource-group $RG --name $VM --port 8080 --priority 1010

az vm show -d -g $RG -n $VM --query publicIps -o tsv