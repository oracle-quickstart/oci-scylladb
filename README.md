# oci-quickstart-scylladb

This is a Terraform module that deploys [ScyllaDB](https://www.scylladb.com/) on [Oracle Cloud Infrastructure (OCI)](https://cloud.oracle.com/en_US/cloud-infrastructure).  It is developed jointly by Oracle and ScyllaDB.

This repo is under active development.  Building open source software is a community effort.  We're excited to engage with the community building this.

## Prerequisites
First off you'll need to do some pre deploy setup.  That's all detailed [here](https://github.com/oracle/oci-quickstart-prerequisites).

## Clone the Module
Now, you'll want a local copy of this repo by running:

    git clone https://github.com/oracle/oci-quickstart-scylladb.git

## Deploy
The TF templates here can be deployed by running the following commands:
```
cd oci-quickstart-scylladb/terraform
terraform init
terraform plan
terraform apply # will prompt to continue
```

The output of `terraform apply` should look like:
```
Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

Outputs:
```
