#!/bin/bash

# Get the environment details
ENV=$1

###### Run packer script to build image ######
cd packer
packer init .
packer validate .
packer build -machine-readable . | tee build.log
ami_id=$(grep 'artifact,0,id' build.log | cut -d, -f6 | cut -d: -f2)
cd ../

###### Creating terraform pre-requisites for AWS using AWS CLI commands ######

# S3 bucket with encryption to store terraform statefiles
aws s3api create-bucket --bucket us-west-2-wordpress-01-terraform-state --region us-west-2
aws s3api put-bucket-encryption --bucket us-west-2-wordpress-01-terraform-state --server-side-encryption-configuration "{\"Rules\": [{\"ApplyServerSideEncryptionByDefault\":{\"SSEAlgorithm\": \"AES256\"}}]}"

# Creating DynamoDB Table to utilize terraform lock mechanism
aws dynamodb create-table --table-name us-west-2-wordpress-01-terraform-lock-table --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5


###### Get the environment details ######
ENV=$1

if [ $ENV == 'dev' ]
then
   cd ./environment/dev
   echo "You are in Dev Environment"
elif [ $ENV == 'uat' ]
then
   cd ./environment/uat
   echo "You are in UAT Environment"
elif [ $ENV == 'prod' ]
then
   cd ./environment/prod
   echo "You are in Prod Environment"
else
    echo "Please pass correct Environment name. Options are dev, uat or prod"
fi

###### Deploy the terraform code to setup the environment ######
terraform init
terraform plan -out out.terraform
terraform apply out.terraform
rm out.terraform