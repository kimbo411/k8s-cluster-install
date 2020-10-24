# k8s-cluster-install

Ejecutamo el vagrant.
```
vagrant up
```

Luego comenzamos la instalación en todos los nodos y master

Para permitir que iptables acceda al trafico de red, primero verificamos si el modulo de filtro de red esté cargado.
```
lsmod | grep br_netfilter
```

Si no está cargado el modulo 

```
sudo modprobe br_netfilter
```
Luego habilitamos el bridge
```
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system
```

## Instalación del Container runtimes

Como usuario root
```
sudo -i
```
### Instalamos Docker
```
apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg2
```
### Agregamos Docker's official GPG key:
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```
### Agregamos Docker apt repository:
```
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"
```
### Instalando Docker CE
```
apt-get update && sudo apt-get install -y \
  containerd.io=1.2.13-2 \
  docker-ce=5:19.03.11~3-0~ubuntu-$(lsb_release -cs) \
  docker-ce-cli=5:19.03.11~3-0~ubuntu-$(lsb_release -cs)
```

### Set up the Docker daemon
```
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
```

### Creamos carpeta del servicio Docker
```
mkdir -p /etc/systemd/system/docker.service.d
```

### Restamos servicio Docker
```
systemctl daemon-reload
systemctl restart docker
```

### Habilitamos el servicio de Docker
```
systemctl enable docker
```

### Estatus servicio de Docker
```
systemctl status docker
```

## Instalación de kubeadm, kubelet and kubectl

### Entodos los nodos y masters
```
apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
```

### Initializar el control-plane node (master)

> Nota: Verificar la IP del master

```
kubeadm init --pod-network-cidr 10.244.0.0/16 --apiserver-advertise-address=192.168.56.2
```

Copiamos la salida: kubeadm join 192.168.56.2:6443 --token ogdulm.uru61th3hhnygpxn \
    --discovery-token-ca-cert-hash sha256:9c28adc5d340d32d4a327fe76db60be3f9ed8aab18d883ffdf4f7d25cbb2d4d5

### Ahora nos realizamos logout para ser usuarios regulares solo en master, para aislar los componentes de las tareas posteriores.
```
logout
```

### Agregamos el kube-config para acceder al cluster solo en master
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### Verificamos el cluster actual
```
kubectl get nodes
```

### Ahora instalaremos la solución de red, en este caso Weave

> Nota: https://www.weave.works/docs/net/latest/kubernetes/kube-addon/
```
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
```

### Agregamos los nodos
```
kubeadm join 192.168.56.2:6443 --token ud7vom.1v57cniocm6gtz8n --discovery-token-ca-cert-hash sha256:2abc2565242d24dfb1da4c3e0f91de44494fe99287cc19c59a1a5ae0dff19e97
