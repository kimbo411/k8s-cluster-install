# k8s-cluster-install

Para la instalación del se necesita los datos de los siguientes campos

Ejecutamo el vagrant.

Luego comenzamos la instalación de los

Verificamos si el modulo esta cargado

lsmod | grep br_netfilter

Si no está cargado el modulo 

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

Instalacion del Container runtimes

Docker

sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg2

# Agregamos Docker's official GPG key:
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Agregamos Docker apt repository:
sudo add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

# Instalando Docker CE
sudo apt-get update && sudo apt-get install -y \
  containerd.io=1.2.13-2 \
  docker-ce=5:19.03.11~3-0~ubuntu-$(lsb_release -cs) \
  docker-ce-cli=5:19.03.11~3-0~ubuntu-$(lsb_release -cs)


# Set up the Docker daemon
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

Creamos carpeta del servicio Docker

sudo mkdir -p /etc/systemd/system/docker.service.d

# Restamos servicio Docker
sudo systemctl daemon-reload
sudo systemctl restart docker

# Habilitamos el servicio de Docker
sudo systemctl enable docker

# Estatus servicio de Docker
sudo systemctl status docker


Instalación de kubeadm, kubelet and kubectl

# Entodos los nodos y masters

sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

