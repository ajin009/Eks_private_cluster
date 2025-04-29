resource "null_resource" "install_nginx_ingress" {
  triggers = {
    cluster_name = var.eks_cluster_name
  }

  connection {
    type        = "ssh"
    host        = var.bastion_host
    user        = var.bastion_user
    private_key = file(var.bastion_private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'Installing Helm & configuring kubectl...'",
      "curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash",
      "aws eks update-kubeconfig --region ${var.aws_region} --name ${var.eks_cluster_name}",
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
