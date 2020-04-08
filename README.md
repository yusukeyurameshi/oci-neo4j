# oci-neo4j
This is a Terraform module that deploys [Neo4j](https://neo4j.com/product/) on [Oracle Cloud Infrastructure (OCI)](https://cloud.oracle.com/en_US/cloud-infrastructure).  It is developed jointly by Oracle and Neo4j.

## Prerequisites
First off you'll need to do some pre deploy setup.  That's all detailed [here](https://github.com/yusukeyurameshi/oci-prerequisites).

## Clone the Module
Now, you'll want a local copy of this repo by running:

    git clone https://github.com/yusukeyurameshi/oci-neo4j.git

## Deploy
The TF templates here can be deployed by running an apply job on Oracle OCI Resource Manager

The output of `terraform apply` should look like:
```
Apply complete! Resources: 31 added, 0 changed, 0 destroyed.
Outputs:
Core Priv server private IPs = 10.0.1.6,10.0.1.5,10.0.1.3
Read Priv server private IPs = 10.0.1.4,10.0.1.7,10.0.1.2 
```

You can access the Neo4j browser at `http://<core_private_ip>:7474` with the default login `neo4j/neo4j`. You will be prompted to change the password at first login.
