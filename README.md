Adapter file from: https://github.com/timflutre/trimmomatic/blob/master/adapters/TruSeq3-PE.fa


## Setting AWS environment variables
Before entering the devcontainer, make sure to copy the .env.template to .env
```
cp .env.template .env
```
Then set your AWS access key and AWS secret access key.


## Enter the devcontainer
All commands should be run from within the docker devcontainer. If using VS code, 
press Cmd + Shift + P (for mac) or Ctrl + Shift + P (for everything else) to bring up the 
window to build the devcontainer. Build and enter the devcontainer. This may take a few minutes 
if you are building or rebuilding the container.

## Spin up AWS resources
Enter the `terraform` directory and run the following:
```
terraform init
terraform plan
terraform apply
```
You will be promted to enter `yes` to confirm the changes to the infrastructure. This will 
set up the required resources to run the nextflow pipelines in the cloud.

## Start nextflow pipeline
Go back to the parent directoy (tep_preprocessing) and execute
```
nextflow run tep_map.nf -profile amazon
```
to begin the pipeline on AWS batch. Each job will be executed in its own compute 
environment in AWS ECS, which is managed by AWS Batch. Results are written to 
`s3://s3://test-data-renovaro/results`. 

## Destroy infrastructure
In order to avoid unnecessary costs, remember to destroy the AWS resources when the pipeline 
is finished running. Enter the `terraform/` directory and run:
```
terraform destroy
``` 
When promted enter `yes`. This will destroy all AWS resources that were provisioned earlier.