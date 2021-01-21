**OVERVIEW**

This project makes it easy to setup HPE Ezmeral Data Fabric edge demo on AWS

```diff
- The concepts demonstrated in this project are not suitable for production environments.
- This project is for frequently creating and tearing down demo/trial environments.
- This project is not for creating and managing long-living demo/trial environments.
- Please read the project license before using this project.
```

### Pre-requisites

The following installed locally:

 - Terraform - [installation instructions](https://learn.hashicorp.com/terraform/getting-started/install.html)|[downloads](https://www.terraform.io/downloads.html)
 - AWS CLI - [installation instructions](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)

This project has been tested on **Linux** and **OSX** client machines - Windows is unlikely to work.

### Quick start

#### Setup environment

```
# If you haven't already configured the aws CLI with your credentials, run the following:
aws configure

# clone this project
git clone https://github.com/hpe-container-platform-community/df-edge-demo-terraform
cd df-edge-demo-terraform

# create a copy 
cp ./etc/bluedata_infra.tfvars_example ./etc/bluedata_infra.tfvars

# edit to reflect your requirements
vi ./etc/bluedata_infra.tfvars 

# initialise terraform
terraform init
```

For many more configuration options, see `etc/bluedata_infra.tfvars_template`.

![project init](./docs/README/project_init.gif)

---

We are now ready to automate the AWS infrastructure setup ...

```
./bin/terraform_apply.sh
```


