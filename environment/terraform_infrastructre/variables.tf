variable "namespace" {
  default = ""
  description = "The app/organization name given to create lable for the resources from label module "
}

variable "vpc_name" {
  default = "new-vpc"
}

variable "stage" {
  default = ""
  description = "The environment prefix name given to create lable for the resources from label module "
}

variable "cidr_block" {
  default = "172.32.0.0/16"
  description = "CIDR block for creating the VPC"
}

variable "enable_dns_hostnames" {
  default = true
  description = "This variable is to enable/disable dns hostnames in VPC"
}

variable "enable_dns_support" {
  default = true
  description = "This variable is to enable/disable dns support in VPC"
}

variable "enable_default_security_group_with_custom_rules" {
  default = true
  description = "This variable is to enable the default security with custom rules in the VPC"
}

variable "availability_zones" {
  default = ["ap-south-1a","ap-south-1b", "ap-south-1c"]
  description = "This are the availability zones that we are creating the subnets and our aws resources are running"
}

variable "nat_gateways_count" {
  default = 1
  description = "This variable is to restrict the creation of NAT gateways and override the default behaviour of VPC module which will create NAT gateways as per the AZ count"
}

variable "enable_ecr" {
  default = true
  description = "This variable will decide whether the elastic container registries are created or not for the environment"
}

# variable "ecr_name" {
#   default = "my-new-ecr"
#   description = "ECR prefix name given to create lable for the resources from label module "
# }

variable "enable_lifecycle_policy" {
  type        = bool
  description = "Set to false to prevent the module from adding any lifecycle policies to any repositories"
  default     = true
}

variable "kubernetes_version" {
  default ="1.25"
  description = "Kubernetes version. Defaults to EKS Cluster Kubernetes version. Terraform will only perform drift detection if a configuration value is provided"
}

variable "eks_cluster_name" {
  default = "my-new-cluster"
  description = "EKS prefix name given to create lable for the resources from label module "
}

variable "oidc_provider_enabled" {
  default = true
  description = "Create an IAM OIDC identity provider for the cluster, then you can create IAM roles to associate with a service account in the cluster, instead of using kiam or kube2iam. For more information, see https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html"
}

variable "write_kubeconfig" {
  default = true
  description = "Whether to write a Kubectl config file containing the cluster configuration. Saved to `config_output_path`."
}

variable "eks_nodegroup_instance_type" {
  default = ["t2.medium"]
  description = <<-EOT
    Single instance type to use for this node group, passed as a list. Defaults to ["t2.medium"].
    It is a list because Launch Templates take a list, and it is a single type because EKS only supports a single type per node group.
    EOT
}

variable "desired_size" {
  default = 1
  description = "Initial desired number of worker nodes (external changes ignored)"
}

variable "min_size" {
  default = 1
  description = "Minimum number of worker nodes"
}

variable "max_size" {
  default = 2
  description = "Maximum number of worker nodes"
}

variable "disk_size" {
  default = 20
  description = <<-EOT
    Disk size in GiB for worker nodes. Defaults to 20. Ignored it `launch_template_id` is supplied.
    Terraform will only perform drift detection if a configuration value is provided.
    EOT
}

variable "cluster_autoscaler_enabled" {
  default = true
  description = "Set true to label the node group so that the [Kubernetes Cluster Autoscaler](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md#auto-discovery-setup) will discover and autoscale it"
}

variable "existing_workers_role_policy_arns" {
  default = ["arn:aws:iam::aws:policy/CloudWatchLogsFullAccess", "arn:aws:iam::aws:policy/SecretsManagerReadWrite"]
  description = "List of existing policy ARNs that will be attached to the workers default role on creation"
}

variable "worker_role_autoscale_iam_enabled" {
  default = true
  description = <<-EOT
    If true, the worker IAM role will be authorized to perform autoscaling operations. Not recommended.
    Use [EKS IAM role for cluster autoscaler service account](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) instead.
    EOT
}

variable "resources_to_tag" {
  default = ["instance","volume"]
  description = "List of auto-launched resource types to tag. Valid types are \"instance\", \"volume\", \"elastic-gpu\", \"spot-instances-request\"."
}
variable "region" {
  default = "ap-south-1"
  description = "AWS Region"
}

variable "bastion_aws_key_pair_name" {
  default = "woooba-prod-bastion-key"
}

variable "ssh_public_key_path" {
  default     = "./secrets"
  description = "This is the local host path where the bastion public and private keys are stored once created"
}

variable "generate_ssh_key" {
  default     = true
  description = "This variable generate SSH key for the ec2 instance module"
}

variable "bastion_ami" {
  type        = string
  description = "The AMI to use for the instance/bastion. By default it is the AMI provided by Amazon with Ubuntu 20.04 LTS"
  default     = "ami-0694d931cee176e7d"
}

variable "ami_owner" {
  default     = "amazon"
  description = "This is a variable to choose the owner of the AMI that we have to choose for bastion/ec2"
}

variable "create_default_security_group" {
  default     = true
  description = "This variable will enable the default security group in the VPC module"
}

variable "assign_eip_address" {
  default     = true
  description = "This variable is to disable or enable eip creation for the bastion/ec2"
}

variable "associate_public_ip_address" {
  default     = true
  description = "Variable to enable public ip address for the bastion/ec2"
}

variable "bastion_instance_type" {
  default     = "t2.micro"
  description = "The instance type of the ec2/bastion"
}

variable "bastion_root_volume_size" {
  type        = number
  description = "Size of the root volume in gigabytes"
  default     = 30
}
variable "bastion_allowed_ports" {
  default     = [80,443]
  description = "The allowed ports from the ec2/bastion on the security group"
}


variable "bastion_root_volume_type" {
  type        = string
  description = "Type of root volume. Can be standard, gp2 or io1"
  default     = "gp2"
}

variable "bastion_delete_on_termination" {
  default     = true
  description = "Variable to Enable/Disable delete on termination feature for the ec2/bastion"
}

variable "bastion_monitoring" {
  default     = true
  description = "Enable/disable detailed Monitoring for the ec2/bastion instance"
}

variable "bastion_ebs_optimized" {
  type        = bool
  description = "Launched EC2 instance will be EBS-optimized"
  default     = false
}

variable "user_data" {
  type        = string
  description = "The user data to provide when launching the instance. Do not pass gzip-compressed data via this argument; use `user_data_base64` instead"
  default     = <<EOF
#!/bin/bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip
unzip awscliv2.zip
sudo ./aws/install
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl

chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

EOF
}

variable "bastion_ip" {
  default = "13.201.49.146"
  type    = string
}

# variable "tls_private_key" {
#   description = "/home/ajin/project1/environment/terraform_infrastructre/test.pem"
#   type        = string
# }