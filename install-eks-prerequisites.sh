#!/bin/bash
set -e

echo "=================================================="
echo "  Terraform + AWS CLI + Git + kubectl Installer"
echo "  Ubuntu 24.04 / 26.04 LTS (EC2)"
echo "=================================================="

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok()   { echo -e "${GREEN}[OK]${NC} $1"; }
info() { echo -e "${YELLOW}[..] $1${NC}"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; exit 1; }

# ── 1. Update System ─────────────────────────────────────
info "System packages update chesthunam..."
sudo apt-get update -y -qq
sudo apt-get install -y curl unzip wget git jq
ok "System packages ready"

# ── 2. Verify Git ────────────────────────────────────────
ok "Git installed: $(git --version)"

# ── 3. Install AWS CLI v2 ────────────────────────────────
info "AWS CLI v2 install chesthunam..."

cd /tmp

curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip -q awscliv2.zip
sudo ./aws/install --update

rm -rf aws awscliv2.zip

ok "AWS CLI installed: $(aws --version 2>&1)"

# ── 4. Install Terraform ─────────────────────────────────
info "Terraform install chesthunam..."

TF_VERSION="1.6.6"

wget -q "https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip" -O terraform.zip

unzip -q terraform.zip

sudo mv terraform /usr/local/bin/
sudo chmod +x /usr/local/bin/terraform

rm -f terraform.zip

ok "Terraform installed: $(terraform version | head -1)"

# ── 5. Install kubectl ───────────────────────────────────
info "Latest stable kubectl install chesthunam..."

KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)

curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"

chmod +x kubectl
sudo mv kubectl /usr/local/bin/

rm -f kubectl

ok "kubectl installed: $(kubectl version --client)"

# ── 6. Set Default AWS Region ────────────────────────────
info "AWS default region set chesthunam..."

BASHRC="$HOME/.bashrc"

grep -q "AWS_DEFAULT_REGION" "$BASHRC" 2>/dev/null || cat >> "$BASHRC" << 'EOF'

# AWS Default Region
export AWS_DEFAULT_REGION="ap-south-1"

EOF

ok "AWS_DEFAULT_REGION added to ~/.bashrc"

# ── 7. Summary ───────────────────────────────────────────
echo ""
echo "=================================================="
echo -e "${GREEN} Installation Completed Successfully!${NC}"
echo "=================================================="
echo ""
echo "Installed Versions:"
echo "  Git        : $(git --version)"
echo "  AWS CLI    : $(aws --version | cut -d' ' -f1)"
echo "  Terraform  : $(terraform version | head -1)"
echo "  kubectl    : $(kubectl version --client)"
echo ""
echo "=================================================="
echo " NEXT STEPS"
echo "=================================================="
echo ""
echo "1. Configure AWS Credentials:"
echo "   aws configure"
echo ""
echo "2. Reload Environment Variables:"
echo "   source ~/.bashrc"
echo ""
echo "3. Verify AWS Connection:"
echo "   aws sts get-caller-identity"
echo ""
echo "4. Verify Terraform:"
echo "   terraform version"
echo ""
echo "5. Verify kubectl:"
echo "   kubectl version --client"
echo ""
echo "6. Configure EKS kubeconfig (After Cluster Creation):"
echo "   aws eks update-kubeconfig --region ap-south-1 --name <cluster-name>"
echo ""
echo "7. Verify EKS Nodes:"
echo "   kubectl get nodes"
echo ""
echo "=================================================="
