# EKS Cluster IAM Role
resource "aws_iam_role" "eks_cluster" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.k8s_version

  vpc_config {
    subnet_ids              = aws_subnet.private[*].id
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]

  tags = {
    Name = var.cluster_name
  }
}

# kubectl install + kubeconfig setup
# EKS cluster ready iiena ventanee run avuthundhiii 
resource "null_resource" "kubectl_setup" {
  depends_on = [aws_eks_cluster.main]

  triggers = {
    cluster_name     = aws_eks_cluster.main.name
    cluster_endpoint = aws_eks_cluster.main.endpoint
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      set -e

      echo "========================================"
      echo " Step 1: kubectl install chesthunam"
      echo "========================================"

      if command -v kubectl &>/dev/null; then
        echo "kubectl already installed: $(kubectl version --client --short 2>/dev/null)"
      else
        OS=$(uname -s)
        if [ "$OS" = "Linux" ]; then
          echo "Linux detected, installing kubectl..."
          KUBECTL_VERSION=$(curl -Ls https://dl.k8s.io/release/stable.txt)
          curl -LO "https://dl.k8s.io/release/$${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
          chmod +x kubectl
          sudo mv kubectl /usr/local/bin/kubectl
          echo "kubectl installed successfully!"
        elif [ "$OS" = "Darwin" ]; then
          echo "Mac detected, installing via brew..."
          brew install kubectl
        else
          echo "Unsupported OS. Please install kubectl manually."
          exit 1
        fi
      fi

      echo ""
      echo "========================================"
      echo " Step 2: kubeconfig update chesthunam"
      echo "========================================"
      aws eks update-kubeconfig \
        --region ${var.region} \
        --name ${aws_eks_cluster.main.name}

      echo ""
      echo "========================================"
      echo " kubectl setup complete!"
      echo "========================================"
    EOT
  }
}
