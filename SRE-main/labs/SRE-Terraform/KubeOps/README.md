# Deploy an EKS cluster with Terraform

Before you start creating, you'll need the following:

-   an AWS account;
-   identity and access management (IAM) credentials and programmatic access (terraform-studentx);
-   AWS credentials that are set up locally with aws configure;
-   a code or text editor, like VS Code.

Once you have the prerequisites, it is time to start writing the code to create an EKS cluster. The following steps show how to set up the main.tf file to create an EKS cluster and the variable files to ensure the cluster is repeatable across any environment.

## Pull down the EKS deployment manifests from the Git Repository and update files

In this section, we'll pull down the EKS manifest files that we're going to use to deploy our EKS cluster in AWS. 

**Step 1.** Log into the AWS instance that's been assigned to your pod and do the following:

-   Git pull <repo>
-   cd kubeops\OneCloud-EKS-Deploy
-   ls 
-   verify the following files are in the directory
    -   backend.tf, data-sources.tf, eks-cluster.tf, node-groups.tf, outputs.tf, providers.tf, variables.tf, vpc.tf

**Step 2.** Modify backend.tf

Now we'll modify the backend configuration so that our state file is stored in an S3 bucked. The S3 bucket we'll be using for this lab is a shared bucket for this class. Let's modify the key value with our pod number. For example: 


terraform {
  backend "s3" {
    bucket         = "onecloud-kube"
    key            = "pod1-kube.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}

    

This will ensure that our state file is unique among the other students attending this course. Please ensure you saved your changes. 

**Step 3.** Modify / verify providers.tf

Verify the providers.tf file references the appropriate AWS CLI profile. This will ensure terraform uses the appropriate AWS CLI profile when creating our EKS cluster.
```terraform
terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
  profile = "srelab"
```
**Step 4.** Modify terraform.tfvars

Let's modify our .tfvars file and set the variables we'll use to create our EKS Cluster. 

Please set the following:
- project = "eks-pod<pod#>"
- vpc-cidr = "10.<pod#>.0.0/16"

For example:
```terraform
region                   = "us-east-1"
availability_zones_count = 2

project = "eks-pod1"

vpc_cidr         = "10.1.0.0/16"
subnet_cidr_bits = 8
```

**Step 5.** Review Terraform Manifest files

Let's take a look at the Terrform manifest files we're about to execute. We have the following .tf files that will be used to deploy our EKS cluster:

- backend.tf - Containers the terraform block which is used to provide our settings for terraform itself. 
- providers.tf - AWS Provider settings
- terraform.tfvars - Used to set our variables for our Terraform manifests.
- data-sources.tf - Used to pull data from AWS which will be used in our terraform manifests. In this case, we're getting the availability zones that are available in our region.
- outputs.tf - Provides outputs once the manifests finish running. Outputs include the cluster name, endpoint and certificate information
- variables.tf - Where variables are defined for our manifest files
- vpc.tf - This manifest creates our VPC, subnets, route tables, NAT and Internet Gateway. This VPC will be used for our EKS cluster. 
- node-group.tf - creates our EKS Cluster Node Group including appropriate IAM roles
- eks-cluster.tf - creates the EKS Cluster. This also creates Security Groups, IAM roles, etc


## Create The EKS Cluster Using Our Terraform Manifests

Let's run the following commands to create our EKS Cluster

-   terraform init. Initialize the environment and pull down the AWS provider.
-   terraform plan. Plan the environment and ensure no bugs are found.
-   terraform apply --auto-approve. Create the environment with the apply command, combined with auto-approve, to avoid prompts.

**Step 1.** run terraform init

terraform init
Initializing the backend...

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Using previously-installed hashicorp/aws v4.59.0

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

**Step 2.** run terraform plan

OneCloud-EKS-Deploy> **terraform plan**
data.aws_availability_zones.available: Reading...
data.aws_availability_zones.available: Read complete after 1s [id=us-east-1]

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

   aws_eip.main will be created
  + resource "aws_eip" "main" {
      + allocation_id        = (known after apply)
      + association_id       = (known after apply)
      + carrier_ip           = (known after apply)
      + customer_owned_ip    = (known after apply)
      + domain               = (known after apply)
      + id                   = (known after apply)
      + instance             = (known after apply)
      + network_border_group = (known after apply)
      + network_interface    = (known after apply)
      + private_dns          = (known after apply)
      + private_ip           = (known after apply)
      + public_dns           = (known after apply)
      + public_ip            = (known after apply)
      + public_ipv4_pool     = (known after apply)
      + tags                 = {
          + "Name" = "eks-pod1-ngw-ip"
        }
      + tags_all             = {
          + "Name" = "eks-pod1-ngw-ip"
        }
      + vpc                  = true
    }

***output concatenated***........

Plan: 37 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + cluster_ca_certificate = (known after apply)
  + cluster_endpoint       = (known after apply)
  + cluster_name           = "eks-pod1-cluster"

───────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to
take exactly these actions if you run "terraform apply" now.

**Step 3.** run terraform plan --auto-approve

Note: This will take roughly 10 minutes to finish creating your EKS Cluster!

OneCloud-EKS-Deploy> ***terraform apply --auto-approve***
data.aws_availability_zones.available: Reading...
data.aws_availability_zones.available: Read complete after 1s [id=us-east-1]

Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

   aws_eip.main will be created
  + resource "aws_eip" "main" {
      + allocation_id        = (known after apply)
      + association_id       = (known after apply)
      + carrier_ip           = (known after apply)
      + customer_owned_ip    = (known after apply)
      + domain               = (known after apply)
      + id                   = (known after apply)

**output concatenated**........
aws_eks_node_group.this: Creation complete after 2m20s [id=eks-pod1-cluster:eks-pod1]

Apply complete! Resources: 37 added, 0 changed, 0 destroyed.

Outputs:

cluster_ca_certificate = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUMvakNDQWVhZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJek1ETXlPVEUzTlRJeE9Gb1hEVE16TURNeU5qRTNOVEl4T0Zvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTUliCkxzMUxPb0ZrUk5rdTN3MStnTzlkc3dSVy9YTEJJZ2prWWt1ckxjWmM0aHZPMDVNV2VrOHdPc0xRYm4xekppeXoKL3ZRLzB0VnJUVEdBYnBxbmhWQUtDcy8rREpPbkVtRjVXN3BiYWFBL21hV2VJU1FtTnVNeHdZSUw3Q2JISktuUwpRU1I3ZnNMQjV2QXluUm1jR0tnS0NJTlNlZVV6bjdJOWkvZTRWSjkyYndYT0lnU0dLT0Y0THBpL0RXL3drUFIxCkcyZ1lnTnFQSi9NekhDdkIrK1pZeHp2bEdjYUt3TU1mTXpvenRGZzBJNXZGUUNBQkF2ZSt5U3A2RXVXSmZGN2sKNTZWRWlnc2lxbzhZTXBkL3FWeXUxNDhPeHZyUUdkWE1tWXlQY08xTW5SNXJBYUwwT0hBaVZtV2tOSFBzT2grZwpuUjFHWnFjYjJrOXkvVnpFMkVNQ0F3RUFBYU5aTUZjd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZIWUJORlM0SEF6MFExWTU2aGRDSUdFVlFjTkdNQlVHQTFVZEVRUU8KTUF5Q0NtdDFZbVZ5Ym1WMFpYTXdEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBRldQSmd6NVU5VEJXdE5VVDg0aApmNndKdGJvbHRJdTFlbWFCVUhHcEF3TzNHS3BLOXlJOHM5WEgxblo4Rk40Rjd2QVJCam9uZWZFendUNXZ1VS9ZCmljbjlXVjlpL0lwMFhNWDBMYUx6c1N5SEtUTHlsWkxsZHBubnRTSkxBYlMwSFdvTmZTV1o4L1ZidnRjM3Z1TlMKUTVTTGJmZzVYRDhtaHQ3aUNrTVVVMHhSSzFiQzI1cTRrbVE4NlFVWURIMkVHRHJRSnNsMUdGUW14TWlnbW5MZQpydmN6akFPeVdnYzhEOWpWMno2a3RTN2YxT0lCSFZadC9Gc0NFdU45SFBLNW5YOWlybDg2N3A0OVBBbUJNU3dsCjZwZnlaZHdNNHJkWXE5NHA1ajNQbjlKSXFIenRGWGhvaGp3cnhMTkR3djNXeklkUldJR1pnVkZnZHBmaWQwQTQKLy9ZPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=="
cluster_endpoint = "https://4742B002AFD2D20B97AFC9A28A52A5A9.gr7.us-east-1.eks.amazonaws.com"
cluster_name = "eks-pod1-cluster"

## Update kubeconfig file for EKS Cluster

Let's run the following commands to update our kubeconfig file for our EKS cluster

**Step 1.**

Run the following AWS CLI command:

aws eks --region us-east-1 update-kubeconfig --name eks-pod1-cluster --profile srelab
Updated context arn:aws:eks:us-east-1:759703352034:cluster/eks-pod1-cluster in C:\Users\mgrif\.kube\config

Please modify the value --name eks-pod<pod#>-cluster with your assigned pod number

**Step 2.**
Now verify kubectl can talk to your EKS Cluster

kubectl get pod -A
NAMESPACE     NAME                       READY   STATUS    RESTARTS   AGE
kube-system   aws-node-9gl8h             1/1     Running   0          5h8m
kube-system   aws-node-rhgzf             1/1     Running   0          5h8m
kube-system   coredns-7975d6fb9b-9xspp   1/1     Running   0          5h13m
kube-system   coredns-7975d6fb9b-z4z28   1/1     Running   0          5h13m
kube-system   kube-proxy-7dznj           1/1     Running   0          5h8m
kube-system   kube-proxy-c2gbk           1/1     Running   0          5h8m

**Step 3.** 
Now let's deploy a simple pod in our EKS Cluster

kubectl run nginx-pod --image=nginx:latest
pod/nginx-pod created

**Step 4.**
Verify the pod is up and running:

kubectl get pod -o wide
NAME        READY   STATUS    RESTARTS   AGE   IP           NODE                        NOMINATED NODE   READINESS GATES
nginx-pod   1/1     Running   0          70s   10.1.2.179   ip-10-1-2-31.ec2.internal   <none>           <none>

## Destroy EKS Cluster

Now let's tear down our EKS cluster. Run the following commands:

terraform destroy --auto-approve

Please allow 10 minutes for your EKS cluster to be removed from AWS> 
