variable "ami_name" {
  type    = string
  default = "amzn2-ami-ecs-hvm-*"
}

variable "ami_packer_name" {
  type    = string
  default = "golden-amazon-linux2-ecs"
}

variable "ami_packer_suffix" {
  type    = string
  default = ""
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_ami_regions" {
  description = "AWS AMI Regions"
  type        = list(string)
  default     = ["us-east-1", "us-east-2"]
}

variable "architecture" {
  description = "AMI Architecture"
  type        = string
  default     = "x86_64"
}

variable "awscli_version" {
  description = "AWSCli Version"
  type        = string
  default     = ""
}

variable "associate_public_ip_address" {
  description = "AWS EC2 Instance Associate Public Ip Address on Creation"
  type        = bool
  default     = false
}

variable "environment" {
  type    = string
  default = "production"
}

variable "instance_type" {
  description = "AWS EC2 Instance Type"
  type        = string
  default     = "t2.micro"
}

variable "security_group_id" {
  description = "AWS EC2 Security Group Id"
  type        = string
}

variable "ssh_clear_authorized_keys" {
  description = "SSH Clear Authorized Keys"
  type        = bool
  default     = true
}

variable "ssh_keypair_name" {
  description = "AWS EC2 Key Pair Name"
  type        = string
}

variable "ssh_private_key_file" {
  description = "AWS EC2 Key Pair"
  type        = string
}

variable "ssh_username" {
  description = "SSH Timeout"
  type        = string
  default     = "ec2-user"
}

variable "ssh_timeout" {
  description = "SSH Timeout"
  type        = string
  default     = "5m"
}

variable "subnet_id" {
  description = "AWS Subnet Id"
  type        = string
}

variable "vpc_id" {
  description = "AWS VPC Id"
  type        = string
}

locals {
  ami_name       = var.ami_packer_suffix != "" && var.ami_packer_suffix != null ? format("%s-%s-%s", var.ami_packer_name, local.timestamp, var.ami_packer_suffix) : format("%s-%s", var.ami_packer_name, local.timestamp)
  timestamp      = regex_replace(timestamp(), "[- TZ:]", "")
  awscli_version = var.awscli_version != "" && var.awscli_version != null ? format("-%s", var.awscli_version) : ""
}

data "amazon-ami" "amazon_linux2" {
  region = var.aws_region
  filters = {
    name                = var.ami_name
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["591542846629"]
}

source "amazon-ebs" "amazon_linux2" {
  ami_name                    = local.ami_name
  ami_regions                 = var.aws_ami_regions
  associate_public_ip_address = var.associate_public_ip_address
  encrypt_boot                = true
  instance_type               = var.instance_type
  region                      = var.aws_region
  security_group_id           = var.security_group_id
  source_ami                  = data.amazon-ami.amazon_linux2.id
  ssh_clear_authorized_keys   = var.ssh_clear_authorized_keys
  ssh_keypair_name            = var.ssh_keypair_name
  ssh_private_key_file        = var.ssh_private_key_file
  ssh_timeout                 = var.ssh_timeout
  ssh_username                = var.ssh_username
  subnet_id                   = var.subnet_id
  vpc_id                      = var.vpc_id

  run_tags = {
    Name          = format("packer-builder-%s", local.ami_name)
    environment   = var.environment
    source_ami_id = data.amazon-ami.amazon_linux2.id
    built_in      = timestamp()
  }

  tags = {
    Name          = local.ami_name
    environment   = var.environment
    source_ami_id = data.amazon-ami.amazon_linux2.id
    built_in      = timestamp()
  }

  snapshot_tags = {
    Name          = local.ami_name
    environment   = var.environment
    source_ami_id = data.amazon-ami.amazon_linux2.id
    built_in      = timestamp()
  }
}

build {
  sources = ["source.amazon-ebs.amazon_linux2"]

  provisioner "file" {
    destination = "/tmp/"
    source      = "./user-data/amzon-linux2.sh"
  }

  provisioner "shell" {
    inline = ["chmod +x /tmp/amzon-linux2.sh", "bash /tmp/amzon-linux2.sh"]
  }
}
