# Deploy an S3 Bucket using Terraform

Before you start creating, you'll need the following:

-   an AWS account;
-   identity and access management (IAM) credentials and programmatic access (terraform-studentx);
-   AWS credentials that are set up locally with aws configure;
-   a code or text editor, like VS Code.

Once you have the prerequisites, it is time to start writing the code to create an EKS cluster. The following steps show how to set up the main.tf file to create an EKS cluster and the variable files to ensure the cluster is repeatable across any environment.

## Pull down the S3 Manifests files down to your Jumphost

In this section, we'll pull down the EKS manifest files that we're going to use to deploy our EKS cluster in AWS. 

**Step 1.** Log into the AWS instance that's been assigned to your pod and do the following:

-   Git pull <repo>
-   cd S3
-   ls 
-   verify the following files are in the directory
    -   main.tf, provider.tf, terraform.tf, terraform.tfvars, variables.tf
    -   A templates directory
  
**Step 2.** Modify backend.tf

Now we'll modify the .tfvars files with the specifics of your pod. Modify 'podx' with your pod number:
 
```terraform  
podname = "pod1"
env = "SRE-LAB"
```
    

This will ensure that our state file is unique among the other students attending this course. Please ensure you saved your changes. 

**Step 3.** Review the main.tf manifests


```terraform
# Resource Block

resource "aws_s3_bucket" "mys3bucket" {
  bucket = "${var.podname}-bucket"
  tags = {
    env = var.env
    bucketname  = "${var.podname}-bucket"
    owner   = var.podname
  }
}

resource "aws_s3_bucket_ownership_controls" "bucketowner" {
  bucket = aws_s3_bucket.mys3bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucketacl" {
  depends_on = [aws_s3_bucket_ownership_controls.bucketowner]

  bucket = aws_s3_bucket.mys3bucket.id
  acl    = "private"
}

resource "local_file" "ansible_vars" {
  filename = "/home/ubuntu/ansible/vars.yaml"
  file_permission = "0600"
  content = templatefile("./templates/vars.tpl",
    {
      podname = var.podname
      bucket = aws_s3_bucket.mys3bucket.id
    }
)
}
```
  
This manifest file does the following:
  1. Creates and S3 Bucket
  2. Asigns Bucket permissions to your account
  3. Creates a bucket ACL
  4. Creates the Ansible Variable file using the template found in the templates directory
  
**Step 4.** Run Terraform init

Now lets run terraform init to download the provider and get terraform ready.
 
```cli
  terraform init
```
**Step 5.** Run Terraform plan
  
Let's run Terraform plan to review and confirm what resources will be created!

```cli
terraform plan
```
  
Example output:
  
```output
 Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.mys3bucket will be created
  + resource "aws_s3_bucket" "mys3bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = "pod1-bucket"
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + object_lock_enabled         = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + tags                        = {
          + "bucketname" = "pod1-bucket"
          + "env"        = "SRE-LAB"
          + "owner"      = "pod1"
        }
      + tags_all                    = {
          + "bucketname" = "pod1-bucket"
          + "env"        = "SRE-LAB"
          + "owner"      = "pod1"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)
    }

  # aws_s3_bucket_acl.bucketacl will be created
  + resource "aws_s3_bucket_acl" "bucketacl" {
      + acl    = "private"
      + bucket = (known after apply)
      + id     = (known after apply)
    }

  # aws_s3_bucket_ownership_controls.bucketowner will be created
  + resource "aws_s3_bucket_ownership_controls" "bucketowner" {
      + bucket = (known after apply)
      + id     = (known after apply)

      + rule {
          + object_ownership = "BucketOwnerPreferred"
        }
    }

  # local_file.ansible_vars will be created
  + resource "local_file" "ansible_vars" {
      + content              = (known after apply)
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0600"
      + filename             = "/home/ubuntu/ansible/vars.yaml"
      + id                   = (known after apply)
    }

Plan: 4 to add, 0 to change, 0 to destroy.
```
 Verify that 4 resources will be created as a result of running terraform. 
    
**Step 6.** Run Terraform apply
    
```cli
  terraform apply --auto-approve
```
Example output:
    
```output
Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.mys3bucket will be created
  + resource "aws_s3_bucket" "mys3bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = "pod1-bucket"
      + bucket_domain_name          = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + object_lock_enabled         = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + tags                        = {
          + "bucketname" = "pod1-bucket"
          + "env"        = "SRE-LAB"
          + "owner"      = "pod1"
        }
      + tags_all                    = {
          + "bucketname" = "pod1-bucket"
          + "env"        = "SRE-LAB"
          + "owner"      = "pod1"
        }
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)
    }

  # aws_s3_bucket_acl.bucketacl will be created
  + resource "aws_s3_bucket_acl" "bucketacl" {
      + acl    = "private"
      + bucket = (known after apply)
      + id     = (known after apply)
    }

  # aws_s3_bucket_ownership_controls.bucketowner will be created
  + resource "aws_s3_bucket_ownership_controls" "bucketowner" {
      + bucket = (known after apply)
      + id     = (known after apply)

      + rule {
          + object_ownership = "BucketOwnerPreferred"
        }
    }

  # local_file.ansible_vars will be created
  + resource "local_file" "ansible_vars" {
      + content              = (known after apply)
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0600"
      + filename             = "/home/ubuntu/ansible/vars.yaml"
      + id                   = (known after apply)
    }

Plan: 4 to add, 0 to change, 0 to destroy.
aws_s3_bucket.mys3bucket: Creating...
aws_s3_bucket.mys3bucket: Creation complete after 0s [id=pod1-bucket]
aws_s3_bucket_ownership_controls.bucketowner: Creating...
local_file.ansible_vars: Creating...
local_file.ansible_vars: Creation complete after 0s [id=adb20fe7f9b7fe1b0e6f996d7dad1428e778c5b5]
aws_s3_bucket_ownership_controls.bucketowner: Creation complete after 1s [id=pod1-bucket]
aws_s3_bucket_acl.bucketacl: Creating...
aws_s3_bucket_acl.bucketacl: Creation complete after 0s [id=pod1-bucket,private]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
```

**Step 6.** Run Terraform show
Verify that terraform created the resources:

```cli
terraform show
```

Example Output:
```output
# aws_s3_bucket.mys3bucket:
resource "aws_s3_bucket" "mys3bucket" {
    acl                         = "private"
    arn                         = "arn:aws:s3:::pod1-bucket"
    bucket                      = "pod1-bucket"
    bucket_domain_name          = "pod1-bucket.s3.amazonaws.com"
    bucket_regional_domain_name = "pod1-bucket.s3.amazonaws.com"
    force_destroy               = false
    hosted_zone_id              = "Z3AQBSTGFYJSTF"
    id                          = "pod1-bucket"
    object_lock_enabled         = false
    region                      = "us-east-1"
    request_payer               = "BucketOwner"
    tags                        = {
        "bucketname" = "pod1-bucket"
        "env"        = "SRE-LAB"
        "owner"      = "pod1"
    }
    tags_all                    = {
        "bucketname" = "pod1-bucket"
        "env"        = "SRE-LAB"
        "owner"      = "pod1"
    }

    server_side_encryption_configuration {
        rule {
            bucket_key_enabled = false

            apply_server_side_encryption_by_default {
                sse_algorithm = "AES256"
            }
        }
    }

    versioning {
        enabled    = false
        mfa_delete = false
    }
}

# aws_s3_bucket_acl.bucketacl:
resource "aws_s3_bucket_acl" "bucketacl" {
    acl    = "private"
    bucket = "pod1-bucket"
    id     = "pod1-bucket,private"

    access_control_policy {
        grant {
            permission = "FULL_CONTROL"

            grantee {
                display_name = "cecspod2"
                id           = "50e8213c0d66687c3ce23b0f46a839763ba77047e5e541108c5c2da0e8ee38d6"
                type         = "CanonicalUser"
            }
        }
        owner {
            display_name = "cecspod2"
            id           = "50e8213c0d66687c3ce23b0f46a839763ba77047e5e541108c5c2da0e8ee38d6"
        }
    }
}

# aws_s3_bucket_ownership_controls.bucketowner:
resource "aws_s3_bucket_ownership_controls" "bucketowner" {
    bucket = "pod1-bucket"
    id     = "pod1-bucket"

    rule {
        object_ownership = "BucketOwnerPreferred"
    }
}

# local_file.ansible_vars:
resource "local_file" "ansible_vars" {
    content              = <<-EOT
        hostname: pod1-sre-instance
        bucket: pod1-bucket
        dbuser: pod1user
        dbpass: cisco123
        dbname: pod1db
    EOT
    content_base64sha256 = "XhbhzC+dp1Aim2K0LHGbi5sQyqVXzjt1jooUgkj3IfM="
    content_base64sha512 = "LbWRVWI99jNFDMDHMpdhXPOCGmRZ5E4RfFOJQrCPJDISilXDKVd41SDnvCKxU+QK4uHkgX+U6F+7LY7bbs5VfQ=="
    content_md5          = "56c6d053f804a18031f83207cd802348"
    content_sha1         = "adb20fe7f9b7fe1b0e6f996d7dad1428e778c5b5"
    content_sha256       = "5e16e1cc2f9da750229b62b42c719b8b9b10caa557ce3b758e8a148248f721f3"
    content_sha512       = "2db59155623df633450cc0c73297615cf3821a6459e44e117c538942b08f2432128a55c3295778d520e7bc22b153e40ae2e1e4817f94e85fbb2d8edb6ece557d"
    directory_permission = "0777"
    file_permission      = "0600"
    filename             = "/home/ubuntu/ansible/vars.yaml"
    id                   = "adb20fe7f9b7fe1b0e6f996d7dad1428e778c5b5"
}
```
Congrats! This bucket will be used for our EC2 instance in the next lab. We'll create an EC2 instance and then mount this S3 bucket. 
