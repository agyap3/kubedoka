#!/bin/bash

# Update the system
dnf update -y

# Install required packages
dnf install -y dnf-utils device-mapper-persistent-data lvm2

# Add Docker repository
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker
dnf install -y docker-ce docker-ce-cli containerd.io

# Start and enable Docker
systemctl start docker
systemctl enable docker

# Add Kubernetes repository
cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# Install Kubernetes components
dnf install -y kubelet kubeadm kubectl

# Start and enable kubelet
systemctl enable --now kubelet

# Disable SELinux
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Disable swap
swapoff -a
sed -i '/swap/d' /etc/fstab

# Configure sysctl
cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

# Initialize Kubernetes cluster
kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.50.10

# Set up kubeconfig for vagrant user
mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config

# Install Flannel network plugin
kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# Generate join command for worker nodes
kubeadm token create --print-join-command > /home/vagrant/join-command.sh
chmod +x /home/vagrant/join-command.sh

