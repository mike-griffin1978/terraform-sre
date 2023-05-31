# SRE Class Build - John Swartz
# Testing On:
# Ubuntu 22.04 LTS  2vcpu 4gb ram

# this script installs:
# -kubernetes with dns, ingress controller & hostpath-storage
# Elasticsearch
# Kibana
# prometheus
# grafana
# alert manager
# argo cd
# argo workflows
# kafka

#--------------  Install Kubernetes
sudo hostnamectl set-hostname SRE-Jumphost
sudo snap install microk8s --classic --channel=1.26
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube
sudo su - $USER
sudo microk8s status --wait-ready
sudo microk8s kubectl get nodes
alias kubectl='microk8s kubectl'
echo "alias kubectl='microk8s kubectl'" >> ~/.bashrc
alias k='microk8s kubectl'
echo "alias k='microk8s kubectl'" >> ~/.bashrc
mkdir .kube
kubectl config view --raw > ~/.kube/config
echo "kubectl config view --raw > ~/.kube/config" >> ~/.bashrc
chmod 600 ~/.kube/config
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null

microk8s enable dns
microk8s enable hostpath-storage
microk8s enable community
microk8s enable fluentd
microk8s enable ingress
microk8s enable observability
microk8s enable argocd
sudo snap install helm --classic
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install sre-bitnami bitnami/argo-workflows
helm install sre-kafka bitnami/kafka
# kubectl patch svc sre-kafka-zookeeper -n observability -p '{"spec": {"ports":[{"name":"test","nodePort":32000,"port": 80}]}}'
sudo snap install terraform --classic
sudo apt install ansible-core -y
