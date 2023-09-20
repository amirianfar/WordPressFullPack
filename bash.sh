#!/bin/bash

# One click Wordpress Complete installation on Kubernetes using Kubespray"
# Milad Amirianfar 
# amirianfar@gmail.com 


RED='\033[0;31m'
NC='\033[0m'

#nodePort=$1 
nodeIP=$1
hostSudoUser=$2
#IPAndPort="$nodeIP:$nodePort"
# echo $IPAndPort

echo -e "\n${RED} ** This scripte has provided by Milad Amiriafar (amirianfar@gmail.com) \n for one-click installation a word press on kubernetes\n"

sleep 1
echo -e "\n** Node IP: $nodeIP"
echo " ** Node Port: $nodePort"
echo -e "  ** Host Sudo USER: $hostSudoUser ${NC}\n" 


# login to remote host
# ssh -p $nodePort -o StrictHostKeyChecking=no  $hostSudoUser@$nodeIP

ssh-keygen -t rsa -b 2048 -f $HOME/.ssh/k8s_rsa -C "my k8s cluster key"
ssh-copy-id -i $HOME/.ssh/k8s_rsa.pub $hostSudoUser@$nodeIP

sleep 1
echo -e "\n${RED} ** Updating package indexes ${NC}\n"
sudo apt update

sleep 1
echo -e "\n${RED} ** Installing  Git ${NC}\n"
sudo apt install git

sleep 1
echo -e "\n${RED} ** Cloning Kubespray repository ${NC}\n"
git clone https://github.com/kubernetes-sigs/kubespray.git

sleep 1 
echo -e "\n${RED} ** Installing Python and Ansible Requirements ${NC}\n"
cd kubespray 
sudo apt-get install python3-venv
sudo python3 -m venv venv

echo -e "\n${RED} ** Activating the environment ${NC}\n"
source venv/bin/activate
sudo pip install -r requirements.txt

sudo modprobe nf_conntrack
lsmod | grep nf_conntrack
# #Ignore it for this version
#sudo declare -r CLUSTER_FOLDER='my-cluster' 
# # sudo cp -rfp inventory/sample inventory/$CLUSTER_FOLDER

sudo cp -rfp inventory/sample inventory/milad-cluster

#sudo declare -a IPS=("$nodeIP")
sudo CONFIG_FILE=inventory/milad-cluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${nodeIP[@]}

echo -e "\n${RED} ** Installing Kubespray... It can take a few minutes ...wait please... ${NC}\n"
sleep 1
ansible-playbook -vvv -i inventory/milad-cluster/hosts.yaml -u $hostSudoUser -b -v --private-key=$HOME/.ssh/k8s_rsa.pub cluster.yml -kK
