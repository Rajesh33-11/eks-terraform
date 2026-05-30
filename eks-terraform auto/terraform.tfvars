region             = "ap-south-1"
cluster_name       = "my-eks-cluster"
k8s_version        = "1.31"
node_instance_type = "t3.micro"    # ← t3.medium → t2.micro (Free Tier ✅)
desired_nodes      = 2
min_nodes          = 1
max_nodes          = 4
