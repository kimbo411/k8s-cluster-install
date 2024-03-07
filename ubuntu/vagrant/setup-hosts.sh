#!/bin/bash
set -e
IFNAME=$1
ADDRESS="$(ip -4 addr show $IFNAME | grep "inet" | head -1 |awk '{print $2}' | cut -d/ -f1)"
sed -e "s/^.*${HOSTNAME}.*/${ADDRESS} ${HOSTNAME} ${HOSTNAME}.local/" -i /etc/hosts

# remove ubuntu-bionic entry
sed -e '/^.*ubuntu-bionic.*/d' -i /etc/hosts

# Update /etc/hosts about other hosts
#cat >> /etc/hosts <<EOF
#192.168.56.11  master01
#192.168.56.12  master02
#192.168.56.13  master03
#192.168.56.2  node01
#EOF

echo "##############################################"
echo "----- Alex Giancarlo Camacho Zegarra ------"
echo "##############################################"

echo "### Editando sshd_config ###"
echo "•	 Editando /etc/ssh/sshd_config"
sudo sed -i '/PermitRootLogin prohibit-password/c\PermitRootLogin yes' /etc/ssh/sshd_config
sudo sed -i '/PasswordAuthentication no/c\PasswordAuthentication yes' /etc/ssh/sshd_config

echo "•	 Riniciando servicio SSH"
sudo systemctl restart sshd

echo "### Habilitar timezone Lima y habilitar NTP Service ###"
sudo timedatectl set-timezone America/Lima
sudo timedatectl set-ntp on

echo "•	 Actualizando OS"
sudo apt update -y
echo "---- Finalizado ----"
