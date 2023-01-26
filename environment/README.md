# Introduction

- This is a `3-tier infra` for running Wordpress application.
- It has a seperate VPC of 3 subnets, where 1 in Public subnet where the client connect to access wordpress and rest 2 are Private subnet which runs Workpress Application server and Wordpress MySQL Database.
- `AWS Autoscaling Group` feature was used so that in case of high load deployment can scale horizontally.

## Tools and Technology used 

1. **Packer**
    - It is an Image building tool.
    - I used it for creating an AMI in which workpress application is configured.

2. **Terraform**
    - It is an Infrastructure As a Code tool.
    - I used it to create multiple modules of diffeent services needed to setup the infrastructure.

3. **AWS Cloud**
    - It is a public cloud which allows us to rent resources.
    - I used multiple services in AWS cloud to get the deployment done like VPC, Subnets, Launch Configuration, ASG, ELB, etc.

4. **Shell Script**
    - I used to run packer and terraform command to deploy end to end
    - It would have been much better to use some CD tools like Jenkins or Github Actions, 
      but looking into the short timelines I choose to go via shell script.

## Reason for choosing this design

Frankly speaking, there are multiple other ways to complete this setup but looking at the number of services/workload running I thought it will be feasible to go with `Packer-Terraform-ASG-ELB` approach.

### Other possible design approach 
  - Deploying Wordpress on `AWS ECS` using `Copilot` tool **(Very interesting approach)**
  - Running the entire wordpress app as a container with the use of `Docker-Kubernetes-helm`
  - Configuring `Ansible Playbooks` to create the AWS infrastructure and then other playbooks to setup/deploy Wordpress application

## Main features of the project

- Minimum 3 Wordpress app servers will be running, one in each AZs. This make sure that app has `no single point of failure`. Even if, any of AWS Datacenter goes down still our app will be running untill and unless the entire region goes down.
- DR was not setup as part of this plan so there will be downtime if entire region goes down.
- Terraform codes are reusable/modular so we can run the same deployment code in other Environments as well like UAT ad Prod. That confirms that the deployment is repeatable.

## How directory structure looks like and some details around it

```bash
.
├── deploy.sh
├── environment
│   ├── README.md
│   ├── dev
│   │   ├── backend.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── provider.tf
│   │   └── variables.tf
│   ├── prod
│   └── uat
├── packer
│   ├── wordpress_template.json
│   └── wp_variable.json
└── terraform_modules
    ├── asg_with_elb
    │   ├── asg.tf
    │   ├── elb.tf
    │   ├── output.tf
    │   └── variables.tf
    ├── database
    │   ├── database.tf
    │   ├── output.tf
    │   └── variables.tf
    └── vpc
        ├── network.tf
        ├── output.tf
        └── variables.tf
```

1. **deploy.sh**
      - In this entire setup, you just need to care about this `deploy.sh` shell script.
      - This script will run the packer commands to build a new `Wordpress AMI`.
      - Next it will install terraform pre-requisites.
      - Finally, it will run the terraform commmands to create infra and deploy Wordpress app in Dev/UAT/Prod environment.

2. **environment**
      - There are 2 seperate environments create, Dev, UAT & Prod. Currently only Dev infra is ready.
      - Packer and terraform code is written in modular strucuture so same code can be deployed in all the environemnts.

3. **packer**
      - It contains packer template (to create Workpress AMI) and input variable JSON file.

4. **terraform_modules**
      - It has a very **generic reusable modular code** for below resources :
          ~ VPC and all network components
          ~ MySQL Database with Secretmanager to store DB secret
          ~ Launch Configuration with Autoscaling Group for HA
          ~ Application load balancer with Route53 Record