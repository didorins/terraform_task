# Introduction

This repo contains code written in HCL for Terraform architecture deployment automation on Amazon Web Services <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/Amazon_Web_Services_Logo.svg/800px-Amazon_Web_Services_Logo.svg.png" width="40">. Down below are instructions to install & setup.  High level diagram of architecture 


![](/architecture-diagram.png)

## Pre-requisites
If you are not new to the tools used, skip all the way to Instructions
#### 1) Terraform by <img src="https://www.datocms-assets.com/2885/1508522484-share.jpg" width="85">
Instructions to get started with Terraform by Hashicorp can be found in the follwing link.

https://learn.hashicorp.com/tutorials/terraform/install-cli




#### 2) Source Code editor
This is personal preference. Most common options are Atom or Visual Studio Code (VSC). Both support HCL plugins for code validation. 

##### Get started with ATOM <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/Atom_editor_logo.svg/1200px-Atom_editor_logo.svg.png" width="50">

https://flight-manual.atom.io/getting-started/sections/installing-atom/

##### Get started with VSC <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Visual_Studio_Code_1.35_icon.svg/2048px-Visual_Studio_Code_1.35_icon.svg.png" width="50">
https://code.visualstudio.com/docs/setup/setup-overview


#### 3) Command Line Interface (CLI)

Depending on OS there are different options. For windows I recommend PowerShell, for macOS there is Terminal. 


## Download repository contents locally

You can either use Git CLI / GUI to clone on your local machine or simply use Github's web interface Code > DownloadZIP on top right of the repo

<img src="https://sites.northwestern.edu/researchcomputing/files/2021/05/github.png" width="400">
https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository


# Instructions

## User Input

#### Access Credentials
First set your unique access key and secret access keys. For this I created an IAM user and attached administrator rights policy to avoid root-level permission leverage. It's good practice to not hardcode them in terraform block, but instead use alternative like environmental variables.

For Linux / macOS
```sh 
$ export AWS_ACCESS_KEY_ID=<YOUR_ACCESS_KEY>
$ export AWS_SECRET_ACCESS_KEY=<YOUR_SECRET_ACCESS_KEY>
```
For Windows CMD
```sh
C:\> setx AWS_ACCESS_KEY_ID <YOUR_ACCESS_KEY>
C:\> setx AWS_SECRET_ACCESS_KEY <YOUR_SECRET_ACCESS_KEY>
```
For PowerShell
```sh
PS C:\> $Env:AWS_ACCESS_KEY_ID="<YOUR_ACCESS_KEY>"
PS C:\> $Env:AWS_SECRET_ACCESS_KEY="<YOUR_SECRET_ACCESS_KEY>"
```

#### Variables
Inside variables.tf you will find variable definitions. You can change the default values to whatever fits your environment needs and the configuration will be automatically referred in the code and reflected in the provisioned environment.

| Description | Variable name | Default value |
| :-----: | :---: | :---: |
| EC2 Instance type | instance_type | t2.micro |
| AWS Region | region | eu-central-1 | 
| Availability Zones  | azs | eu-central-1a, eu-central-1b | 
| Path of SSH key | path_to_key | mynew_key.pub | 
| VPC CIDR range | vpc_cidr | 10.0.0.0/16 | 
| List of ports for Web Layer | dynamicports | 22, 80 ,443, 2049 | 
| Database port | database_port | 3306 | 
| S3 prefix | prefix | logs | 
| Your IP (whitelist for ssh) | your-ip | 0.0.0.0/0 | 
| Database username | rds-username | dido | 
| Database instance class | db2_instance_class | db.t2.micro | 



Once you have the code on your system and adjusted the variables, navigate to code's directory and run:

```sh
terraform init
terraform plan
terraform apply
```
## Deployment

This will initialize working directory, automatically download source module based on referred resources, initialize backend, do a 'dry-run' of planned architecture and then translate the code to .json format inside State file, which is used to pass to provider's APIs for resource creation.
