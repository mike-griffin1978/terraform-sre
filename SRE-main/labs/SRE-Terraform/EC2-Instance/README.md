# Deploy Your EC2 Instance into AWS

Before you start creating, you'll need the following:

-   An AWS account;
-   Identity and access management (IAM) credentials and programmatic access (terraform-studentx);
-   AWS credentials that are set up locally with aws configure;
-   A code or text editor, like VS Code.
-   Have previously finished the lab to create an S3 Bucket 

This lab requires that you have completed the previous lab that creates an S3 bucket using Terraform. In this lab we will create an EC2 instance that we'll use to install all of our software and agents. This EC2 instance will eventually have the S3 bucket you previously created mounted. 

## Pull down the EC2-Instance Manifest files 

In this section, we'll pull down the EC2-Instance manifest files that we're going to use to deploy our EC2 Instance in AWS. 

**Step 1.** Log into the AWS instance that's been assigned to your pod and do the following:

-   Git pull <repo>
-   cd Studentx/EC2-Instance/
-   ls 
-   verify the following files are in the directory
    -   Terraform.tf, variables.tf, outputs.tf, main.tf, terraform.tfvars, provider.tf and a folder called template

**Step 2.** Modify backend.tf

Now we'll modify the backend configuration so that our state file is stored in an S3 bucked. The S3 bucket we'll be using for this lab is a shared bucket for this class. Let's modify the key value with our pod number. For example: 

```terraform
terraform {
  backend "s3" {
    bucket         = "podx-bucket"
    key            = "pod1-ec2.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
```
    

This will ensure that we use our S3 bucket to store our state file.  

**Step 3.** Modify / verify providers.tf

Verify the providers.tf file references the appropriate versions for both the AWS Provider and Terraform version. 

```terraform
terraform {
  required_version = ">= 1.4.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  ```
  **Step 4.** Update our terraform.tfvars file
  
  The terraform.tfvars file is where we set our variables for our terraform manifests. Please update the tfvars file with the appropriate information about your pod number. For example:

  ```terraform
  name = "pod1-vm"
  owner = "pod1-student"
  env = "SRE-LAB"
  key_pair_name = "sre_pod1_key"
```
  Please ensure you update this file prior to running terraform to create your EC2 instance. This will ensure your EC2 instance is unique amongst other students instances. 

  **Step 5.** Review main.tf file

  Lets review the main.tf file that will be used to create our resources. This file does the following:

  - Uses the data block to discover the Ubuntu 20.04 AMI in the region. 
  - Create a Key Pair used to connect to the AWS Instance
  - Create the EC2 Instance using the Ubuntu AMI ID and use the Key Pair previously created
  - Creates the Ansible inventory file in the Ansible Directory. This inventory file will be used by Ansible to install our software
  - Creates a README file. This will provide information about our EC2 instance and how to connect to it
  - Copies the key pair (.pem) file both in the local directory and Ansible directory. This will allow us to connect to our EC2 Instance

  ```terraform
  data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "tls_private_key" "keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "sre_key" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.keypair.public_key_openssh
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  key_name = aws_key_pair.sre_key.key_name

  tags = {
    Name = var.name
    env = var.env
    app = var.owner
    OS   = data.aws_ami.ubuntu.name
    type = data.aws_ami.ubuntu.platform_details
  }
}

resource "local_file" "inventory" {
  content = templatefile("./template/hosts.tpl",
    {
      sre-instance = aws_instance.web.private_ip
      key_name = var.key_pair_name
    }
  )
  filename = "/home/ubuntu/ansible/hosts.cfg"
}

resource "local_file" "readme" {
  content = templatefile("./template/README.tpl",
    {
      KEY_NAME = aws_instance.web.key_name
      DNS_NAME = aws_instance.web.public_dns
      PUBLIC_IP_ADDRESS = aws_instance.web.public_ip
    }
  )
  filename = "./README.txt"
}

resource "local_file" "terraform_key_pair" {
  filename = "${var.key_pair_name}.pem"
  file_permission = "0600"
  content = tls_private_key.keypair.private_key_pem
}

resource "local_file" "ansible_key_pair" {
  filename = "/home/ubuntu/ansible/${var.key_pair_name}.pem"
  file_permission = "0600"
  content = tls_private_key.keypair.private_key_pem
}
```
**Step 6.** create Terraform.yml workflow in Git Actions

- Navigate to Actions in your repository and click "Create Workflow". 
- Click "Set up Workflow Yourself"
- Name Workflow "terraform.yml

```yaml
name: "Terraform"

on:
  push:
    branches: [ "main" ]
    paths:
      - 'terraform/EC2-Instance/**'
  pull_request:
    branches: [ "main" ]
    paths:
      - 'terraform/EC2-Instance/**'

jobs:
  terraform:
    name: "Terraform"
    runs-on: self-hosted
    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Terraform Init
        id: init
        run: cd ./terraform/EC2-Instance && terraform init
      
      - name: Terraform Validate
        id: validate
        run: cd ./terraform/EC2-Instance && terraform validate -no-color

      - name: Terraform Plan
        id: plan
        if: github.event_name == 'pull_request'
        run: cd ./terraform/EC2-Instance && terraform plan -no-color -input=false
        continue-on-error: true

      - uses: actions/github-script@v6
        if: github.event_name == 'pull_request'
        env:
          PLAN: "terraform\n${{ steps.plan.outputs.stdout }}"
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            const output = `#### Terraform Format and Style 🖌\`${{ steps.fmt.outcome }}\`
            #### Terraform Initialization ⚙️\`${{ steps.init.outcome }}\`
            #### Terraform Validation 🤖\`${{ steps.validate.outcome }}\`
            #### Terraform Plan 📖\`${{ steps.plan.outcome }}\`
            <details><summary>Show Plan</summary>
            \`\`\`\n
            ${process.env.PLAN}
            \`\`\`
            </details>
            *Pushed by: @${{ github.actor }}, Action: \`${{ github.event_name }}\`*`;
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: output
            })
      - name: Terraform Plan Status
        if: steps.plan.outcome == 'failure'
        run: exit 1

      - name: Terraform Apply
        if: github.ref == 'refs/heads/main' && github.event_name == 'push'
        run: cd ./terraform/EC2-Instance && terraform apply -auto-approve -input=false
```

**Step 7.** Push Modified code back to Github  

Navigate to the terraform/EC2-Instance folder on your jump host and type:

```cli
Git add *
git push
```
Ensure that you use the username and Github Token as the password. 

**Step 8.** Check Git Actions

Now lets verify that Git Actions is applying the terraform code. 

- Navigate to Actions
- On the left hand side, select "Terraform" workflow
- You should see a workflow in progress. Click on it to view details
- Verify the workflow has finished


**Step 9.** Verify resources created

perform the following actions
- Log into the AWS portal and navigate to the EC2 service. Verify your instance shows up under the list of Instances
- verify the appropriate key pair is being used for your instance
- verify the appropriate files have been created:

``cli
~/terraform/EC2-Instance$ ls -la
total 44
drwxrwxr-x 4 ubuntu ubuntu 4096 Apr 10 17:38 .
drwxrwxr-x 5 ubuntu ubuntu 4096 Apr  7 20:49 ..
drwxrwxr-x 3 ubuntu ubuntu 4096 Apr  7 00:02 .terraform
-rw-r--r-- 1 ubuntu ubuntu 3522 Apr  7 18:49 .terraform.lock.hcl
-rw-rw-r-- 1 ubuntu ubuntu 1646 Apr  7 19:20 main.tf
-rw-rw-r-- 1 ubuntu ubuntu  276 Apr  7 18:34 outputs.tf
-rw-rw-r-- 1 ubuntu ubuntu  231 Apr  7 00:09 provider.tf
drwxrwxr-x 2 ubuntu ubuntu 4096 Apr  7 19:27 template
-rw-rw-r-- 1 ubuntu ubuntu  288 Apr  7 00:02 terraform.tf
-rw-rw-r-- 1 ubuntu ubuntu   94 Apr 10 17:34 terraform.tfvars
-rw-rw-r-- 1 ubuntu ubuntu  268 Apr  7 18:48 variables.tf
~/terraform/EC2-Instance$
```

**Step 10.** Check README for information about your instance

Example

```cli
cat README.tpl
###############################################################################
Your EC2 instance can be accessed via ssh using the following:

Username: ubuntu
ssh_key: ${ KEY_NAME }.pem
Public IP: ${ PUBLIC_IP_ADDRESS }
Public DNS Name: ${ DNS_NAME }

To access your instance, please run either of the following commands on your jumphost:

ssh -i ${ KEY_NAME }.pem ubuntu@${ DNS_NAME }

or

ssh -i ${ KEY_NAME }.pem ubuntu@${ PUBLIC_IP_ADDRESS }

Please note that if your instance reboots, the public IP address may change. Please re-run terraform via "terraform apply" to recreate
this file with updated information.
################################################################################

```

**Step 11.** Connect to your instance

Now using the key pair and information from the README file, let's connect to our instance. Simply copy and paste either of the commands into your jumphost to connect:

Example

```cli 
 ssh -i sre_pod20_key.pem ubuntu@44.195.92.241
 ```

 type 'yes' if asked to verify the key pair. You should now be connected to your EC2 instance via SSH. Disconnect once finished!

 
