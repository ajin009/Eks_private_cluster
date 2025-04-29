variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "aws_region" {
  description = "AWS Region of the EKS cluster"
  type        = string
}

variable "bastion_host" {
  description = "Public IP of the bastion host"
  type        = string
}

variable "bastion_user" {
  description = "SSH username for the bastion host"
  type        = string
  default     = "ubuntu"
}

variable "bastion_private_key_path" {
  description = "Path to the SSH private key for the bastion host"
  type        = string
}
