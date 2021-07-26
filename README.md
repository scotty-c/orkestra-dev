# Cluster API Azure control plane.

## Introduction
The idea behind this repo was to make it super easy to spin up a [Azure Orkestra](https://github.com/Azure/orkestra).  
This will work both locally or on Azure as it based on [cloud-init](https://cloudinit.readthedocs.io/en/latest/)  

## Running locally 
When running the server locally you will need to install [multipass](https://multipass.run/).  
This is an open source project from canonical which will work on Windows, MacOS and Linux. So what ever you OS you choose to develop on multipass will have you covered. This is the only dependency of the project. 
Once multipass is installed just run the following 
```
curl -L -o cloud-init.yaml 'https://raw.githubusercontent.com/scotty-c/orkestra-dev/main/cloud-init.yaml'
multipass launch --name orkestra --cpus 2 --mem 4G --disk 20G --cloud-init cloud-init.yaml
```
Under the hood we are spinning up a new [Ubuntu server](https://ubuntu.com/download/server) for the control plane we are going to use [microk8s](https://microk8s.io/). This will give us a super light control plane to use to deploy Orkestra. 

There is a known issue that you might get the following error when deploying this locally  
```
launch failed: The following errors occurred:                                   
timed out waiting for initialization to complete
```
This is ok, the installation will continue inside the server. We can check this by tailing the logs but first we need to access the servers shell.  
To do this we just issue the command `multipass shell orkestra`  
You will be greeted with the following MOTD  
To follow the logs `tail -f output.txt`  

Once everything is installed you can check your pods with 


```
kubectl get pods --all-namespaces
```
## Running on Azure
To run this on Azure we will use exactly the same code. We will make the assumption that you have the [Azure cli](https://docs.microsoft.com/cli/azure/install-azure-cli?WT.mc_id=opensource-0000-sccoulto) that is signed into to your subscription. 

Then just run the script `./deploy-azure.sh`  
The script will ask you a couple of questions 
```
Enter the subscription to use: 
Enter the resource group for the vm: 
Enter the name for the vm:
```
Then print out the instructions to access the server.  
Once you have access to the servers shell just `tail -f output.txt`  
The MOTD will give you the rest of the instructions. 

## Thank you 
A big thanks goes to [Aaron Wislang](https://github.com/asw101) for some the original code and ideas that I implemented in this repo :)