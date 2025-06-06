module "vpc" {
 source     = "./modules/terraform-aws-vpc"
 namespace  = var.namespace
 stage      = var.stage
 name       = var.vpc_name
 cidr_block = var.cidr_block
 enable_dns_hostnames = var.enable_dns_hostnames
 enable_dns_support = var.enable_dns_support
 enable_default_security_group_with_custom_rules = var.enable_default_security_group_with_custom_rules
  tags = {
   Environment   = "prod"
   Resource_type = "vpc"
   Terraform     = "true"
  }
}

module "dynamic_subnets" {
 source             = "./modules/terraform-aws-dynamic-subnets"
 namespace          = var.namespace
 stage              = var.stage
 name               = var.vpc_name
 availability_zones = var.availability_zones
 vpc_id             = module.vpc.vpc_id
 igw_id             = module.vpc.igw_id
 nat_gateways_count = var.nat_gateways_count
 cidr_block         = var.cidr_block
  tags = {
   Environment   = "prod"
   Resource_type = "dynamic_subnets"
   Terraform     = "true"
  }
}

module "eks_cluster_label" {
 source     = "./modules/terraform-null-label"
 namespace  = var.namespace
 name       = var.eks_cluster_name
 stage      = var.stage
 delimiter  = "-"
 attributes = ["cluster"]
}

module "eks_cluster" {
 source                = "./modules/terraform-aws-eks-cluster"
 namespace             = var.namespace
 stage                 = var.stage
 name                  = var.eks_cluster_name
 region                = var.region
 vpc_id                = module.vpc.vpc_id
 subnet_ids            = module.dynamic_subnets.public_subnet_ids
 kubernetes_version    = var.kubernetes_version
 oidc_provider_enabled = var.oidc_provider_enabled
 write_kubeconfig      = var.write_kubeconfig
 workers_role_arns     = [module.eks_node_group.eks_node_group_role_arn]
 workers_security_group_ids = []
 tags = {
   Environment   = "prod"
   Resource_type = "eks_cluster"
   Terraform     = "true"
 }
}

module "eks_node_group" {
 source                = "./modules/terraform-aws-eks-node-group"
 cluster_name              = data.null_data_source.wait_for_cluster_and_kubernetes_configmap.outputs["cluster_name"]
 namespace                 = var.namespace
 stage                     = var.stage
 name                      = var.eks_cluster_name
 subnet_ids                = module.dynamic_subnets.private_subnet_ids
 instance_types            = var.eks_nodegroup_instance_type
 # capacity_type             = "SPOT"
 capacity_type             = "ON_DEMAND"
 desired_size              = var.desired_size
 min_size                  = var.min_size
 max_size                  = var.max_size
 disk_size                 = var.disk_size
 kubernetes_version        = var.kubernetes_version
 cluster_autoscaler_enabled = var.cluster_autoscaler_enabled
 resources_to_tag         = var.resources_to_tag
 existing_workers_role_policy_arns = var.existing_workers_role_policy_arns
 worker_role_autoscale_iam_enabled = var.worker_role_autoscale_iam_enabled
 node_role_policy_arns     = ["arn:aws:iam::aws:policy/SecretsManagerReadWrite"]
 tags = {
   Environment   = "prod"
   Resource_type = "eks-nodegroup"
   Terraform     = "true"
 }
}

 module "bastion_aws_key_pair" {
  source              = "./modules/terraform-aws-key-pair"
  namespace           = var.namespace
  stage               = var.stage
  name                = var.bastion_aws_key_pair_name
  ssh_public_key_path = var.ssh_public_key_path
  generate_ssh_key    = var.generate_ssh_key
 }

 module "instance_profile_label_bastion" {
  source    = "./modules/terraform-null-label"
  namespace = var.namespace
  stage     = var.stage
  name      = "prod-bastion-host"
 }

 resource "aws_iam_role" "bastion" {
  name               = module.instance_profile_label_bastion.id
  assume_role_policy = data.aws_iam_policy_document.bastion_role.json
  tags               = module.instance_profile_label_bastion.tags
 }

 resource "aws_iam_instance_profile" "bastion" {
  name = module.instance_profile_label_bastion.id
  role = aws_iam_role.bastion.name
 }

 module "bastion" {
  source                        = "./modules/terraform-aws-ec2-instance"
  ssh_key_pair                  = module.bastion_aws_key_pair.key_name
  name                          = module.instance_profile_label_bastion.name
  vpc_id                        = module.vpc.vpc_id
  ami                           = var.bastion_ami
  ami_owner                     = var.ami_owner
  subnet                        = module.dynamic_subnets.public_subnet_ids[0]
  create_default_security_group = var.create_default_security_group
  assign_eip_address            = var.assign_eip_address
  associate_public_ip_address   = var.associate_public_ip_address
  instance_type                 = var.bastion_instance_type
  user_data                     = var.user_data
 #  user_data_base64              = var.user_data_base64
  root_volume_size              = var.bastion_root_volume_size
  allowed_ports                 = var.bastion_allowed_ports
  root_volume_type              = var.bastion_root_volume_type
  instance_profile              = aws_iam_instance_profile.bastion.name
  delete_on_termination         = var.bastion_delete_on_termination
  monitoring                    = var.bastion_monitoring
  ebs_optimized                 = var.bastion_ebs_optimized
  tags = {
    Environment   = "prod"
    Resource_type = "ec2"
    Terraform     = "true"
  }
 }


 resource "null_resource" "install_nginx_ingress" {
 
   triggers = {
     cluster_name = var.eks_cluster_name
 
   }
 
   connection {
     type        = "ssh"
     host        = var.bastion_ip
     user        = "ubuntu"
     private_key = file("/home/ajin/project1/environment/terraform_infrastructre/test.pem")
   }
   provisioner "remote-exec" {
   inline = [
       "echo 'Installing Helm & configuring kubectl...'",
       "curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash",
       "aws eks update-kubeconfig --region ap-south-1 --name my-new-cluster-cluster",
       "kubectl get nodes",
       "echo 'Installing NGINX Ingress Controller...'",
       "kubectl create namespace ingress-nginx || echo 'Namespace already exists'",
       "kubectl wait --for=condition=Ready ns/ingress-nginx --timeout=30s",
       "helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx",
       "helm repo update",
       "helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \\",
       "  --namespace ingress-nginx \\",
       "  --set controller.service.type=LoadBalancer \\",
       "  --set controller.service.annotations.\"service.beta.kubernetes.io/aws-load-balancer-type\"=nlb \\",
       "  --wait",
       "echo 'NGINX Ingress Controller installed successfully'"
     ]
 }
 
 }
