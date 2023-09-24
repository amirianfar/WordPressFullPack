#!/bin/bash

# One click Wordpress Complete installation on Kubernetes using Kubespray"
# Milad Amirianfar 
# amirianfar@gmail.com 

 # # login to remote host
        # # ssh -p $nodePort -o StrictHostKeyChecking=no  $hostSudoUser@$WorkerNodeIPAddress
        # ssh-keygen -t rsa -b 2048 -f $HOME/.ssh/k8s_rsa -C "my k8s cluster key"
        # ssh-copy-id -i $HOME/.ssh/k8s_rsa.pub $WorkerNodeSudoer@$WorkerNodeIPAddress


echo -e "\n${RED} ** This scripte has been written by Milad Amiriafar (amirianfar@gmail.com) \n for one-click installation a word press on a cluster kubernetes\n"

# Declare variables
IPS=()
Sudoers=()
RED='\033[0;31m'
NC='\033[0m'
i=1

# Initialize basic cluster peices of data 
# read -p "How many Worker Node do you have (Max: 5)? " WorkerNodeNo
# echo "Your cluster will have $WorkerNodeNo worker node(s)"

read -p "Enter a name for your cluster: " CLUSTER_NAME
echo -e "\n${RED} ** Your cluster name is: $CLUSTER_NAME ${NC}\n" 

read -p "Eneter the Sudoer username of all worker nodes: "  WorkerNodeSudoer
echo -e "\n${RED} ** Your sudoer username for all hosts would be: $WorkerNodeSudoer  ${NC}\n" 

# if ! [[ "$WorkerNodeNo" =~ ^[0-5]$ ]]; then
#   echo "Invalid input. Please enter an integer number between 0 and 5."
#   exit 1
# fi

# Run a for loop according to the parameter
# for (( i=0; i<$WorkerNodeNo; i++ )); do
while true; do
        read -p "Enter the IP address of worker node number $i (Enter Finish or Done for next step!): "  WorkerNodeIPAddress
        WorkerNodeIPAddress=$(tr '[:upper:]' '[:lower:]' <<< "$WorkerNodeIPAddress")
        if [[ "$WorkerNodeIPAddress" == "finish" ]] || [[ "$WorkerNodeIPAddress" == "done" ]]; then
            break
        fi
        # read -p "Enter the Sudoer user name of worker node number $i: "  WorkerNodeSudoer
        # if [[ "$WorkerNodeSudoer" == "exit" ]] || [[ "$WorkerNodeSudoer" == "done" ]]; then
        #      break
        # fi
        echo -e "\n${RED} ** IP address of worker node number $i would be $WorkerNodeIPAddress and the Sudoer user name would be $WorkerNodeSudoer ${NC}\n"     
        # If the user enters a specific value, such as `exit` or `done`, exit the while loop.
  
        IPS+=("${WorkerNodeIPAddress}")
        # Sudoers+=("${WorkerNodeSudoer}")
        let i=i+1
done

echo -e "\n${RED} ** Your cluster IPs list: ${IPS[@]} ${NC}\n"
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

sudo declare -r CLUSTER_FOLDER=$CLUSTER_NAME
sudo cp -rfp inventory/sample inventory/$CLUSTER_FOLDER
# sudo declare -a IPS=("$WorkerNodeIPAddress")
sudo CONFIG_FILE=inventory/$CLUSTER_FOLDER/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}

echo -e "\n${RED} ** Installing Kubespray... It can take a few minutes ...wait please... ${NC}\n"
sleep 1
ansible-playbook -vvv -i inventory/$CLUSTER_FOLDER/hosts.yaml -u $WorkerNodeSudoer -b -v --private-key=$HOME/.ssh/k8s_rsa.pub cluster.yml -kK
 