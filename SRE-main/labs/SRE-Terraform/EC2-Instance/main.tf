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