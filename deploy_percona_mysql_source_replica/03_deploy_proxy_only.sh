#!/bin/bash
### initialize aws config ###
TF_VAR_AWS_ACCESS_KEY=$(cat .aws_cred | grep AWS_ACCESS_KEY | awk -F ":" {'print $2'})
TF_VAR_AWS_SECRET_KEY=$(cat .aws_cred | grep AWS_SECRET_KEY | awk -F ":" {'print $2'})
export $TF_VAR_AWS_ACCESS_KEY
export $TF_VAR_AWS_SECRET_KEY

### output directory ###
OUTPUT_DIR="output"
if [ ! -d ${OUTPUT_DIR} ]; then
    mkdir -p ${OUTPUT_DIR}
    chmod 755 ${OUTPUT_DIR}
fi
### ansible config ###
export ANSIBLE_HOST_KEY_CHECKING=False
priv_key="/root/repos/ansible_keys/ansible"
ansible_user="centos"
### vars databases ###
dbprimary01_ip=$(cat ${OUTPUT_DIR}/db_ips.txt | grep dbprimary01 | awk -F ":" {'print $2'})
dbreplica01_ip=$(cat ${OUTPUT_DIR}/db_ips.txt | grep dbreplica01 | awk -F ":" {'print $2'})
dbreplica02_ip=$(cat ${OUTPUT_DIR}/db_ips.txt | grep dbreplica02 | awk -F ":" {'print $2'})

### deploy proxysql ###
echo 'resource "aws_instance" "proxysql01" {
  ami           = var.AMIS[var.AWS_REGION]
  instance_type = var.PROXY_INSTANCE_TYPE

  # the VPC subnet
  subnet_id = var.DB_SUBNET_ID_AZA

  # the security group
  vpc_security_group_ids = [aws_security_group.allow-ssh.id, aws_security_group.allow-mariadb.id]

  # the public SSH key
  key_name = aws_key_pair.mykeypair.key_name

  tags = {
    Name = "proxysql01"
    Terraform   = "true"
    Environment = "turbodba-prod"
    Group = "proxysql-source-replica"
  }

  root_block_device {
      volume_size = 50
      volume_type = "gp2"
      delete_on_termination = true
    }
}' > proxysql01.tf

echo 'resource "aws_instance" "proxysql02" {
  ami           = var.AMIS[var.AWS_REGION]
  instance_type = var.PROXY_INSTANCE_TYPE

  # the VPC subnet
  subnet_id = var.DB_SUBNET_ID_AZB

  # the security group
  vpc_security_group_ids = [aws_security_group.allow-ssh.id, aws_security_group.allow-mariadb.id]

  # the public SSH key
  key_name = aws_key_pair.mykeypair.key_name

  tags = {
    Name = "proxysql02"
    Terraform   = "true"
    Environment = "turbodba-prod"
    Group = "proxysql-source-replica"
  }

  root_block_device {
      volume_size = 50
      volume_type = "gp2"
      delete_on_termination = true
    }
}' > proxysql02.tf


echo '# Output the private IP address of the new droplet
output "private_ip_server_proxysql01" {  value = aws_instance.proxysql01.private_ip }
output "private_ip_server_proxysql02" {  value = aws_instance.proxysql02.private_ip }

# Output the public IP address of the new droplet
output "public_ip_server_proxysql01" {  value = aws_instance.proxysql01.public_ip }
output "public_ip_server_proxysql02" {  value = aws_instance.proxysql02.public_ip }
' > output_proxyservers.tf

### apply changes to digital ocean ###
terraform apply -auto-approve

### vars proxysql ###
# private ips
proxysql01_ip=`terraform output private_ip_server_proxysql01`
proxysql02_ip=`terraform output private_ip_server_proxysql02`
# public ips
proxysql01_ip_pub=`terraform output public_ip_server_proxysql01`
proxysql02_ip_pub=`terraform output public_ip_server_proxysql02`

# create db_ips file for proxysql deployment #
echo "proxysql01:$proxysql01_ip" > proxy_ips.txt
echo "proxysql02:$proxysql02_ip" >> proxy_ips.txt

# create db_hosts file for ansible database replica setup #
echo "[proxyservers]" > ${OUTPUT_DIR}/proxy_hosts.txt
echo "proxysql01 ansible_ssh_host=$proxysql01_ip_pub" >> ${OUTPUT_DIR}/proxy_hosts.txt
echo "proxysql02 ansible_ssh_host=$proxysql02_ip_pub" >> ${OUTPUT_DIR}/proxy_hosts.txt

# wait until databases are fully deployed #
sleep 90

# setup change hostname #
ansible -i ${OUTPUT_DIR}/proxy_hosts.txt -m shell -a "echo \"127.0.0.1 proxysql01\" | sudo tee -a /etc/hosts && hostnamectl set-hostname proxysql01" proxysql01 -u $ansible_user --private-key=$priv_key --become -o > ${OUTPUT_DIR}/setup_change_hostname_proxysql01.txt
ansible -i ${OUTPUT_DIR}/proxy_hosts.txt -m shell -a "echo \"127.0.0.1 proxysql02\" | sudo tee -a /etc/hosts && hostnamectl set-hostname proxysql02" proxysql02 -u $ansible_user --private-key=$priv_key --become -o > ${OUTPUT_DIR}/setup_change_hostname_proxysql02.txt

# deploy ProxySQL to the new VM instances using Ansible
ansible -i ${OUTPUT_DIR}/proxy_hosts.txt -m shell -a "curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_proxysql2_replica.sh | sudo bash" proxyservers -u $ansible_user --private-key=$priv_key --become -o > ${OUTPUT_DIR}/install_proxysql_proxyservers.txt

# insert dns entries for ProxySQL on /etc/hosts
ansible -i ${OUTPUT_DIR}/proxy_hosts.txt -m shell -a 'echo "# dbservers" >> /etc/hosts && echo "{{ dbprimary01_ip }} primary.replication.local" >> /etc/hosts && echo "{{ dbreplica01_ip }} replica1.replication.local" >> /etc/hosts && echo "{{ dbreplica02_ip }} replica2.replication.local" >> /etc/hosts; cat /etc/hosts' proxysql01 -u $ansible_user --private-key=$priv_key --become -e "{dbprimary01_ip: '$dbprimary01_ip', dbreplica01_ip: '$dbreplica01_ip', dbreplica02_ip: '$dbreplica02_ip'}" -o > ${OUTPUT_DIR}/setup_proxy_dbservers_px1.txt
ansible -i ${OUTPUT_DIR}/proxy_hosts.txt -m shell -a 'echo "# dbservers" >> /etc/hosts && echo "{{ dbprimary01_ip }} primary.replication.local" >> /etc/hosts && echo "{{ dbreplica01_ip }} replica1.replication.local" >> /etc/hosts && echo "{{ dbreplica02_ip }} replica2.replication.local" >> /etc/hosts; cat /etc/hosts' proxysql02 -u $ansible_user --private-key=$priv_key --become -e "{dbprimary01_ip: '$dbprimary01_ip', dbreplica01_ip: '$dbreplica01_ip', dbreplica02_ip: '$dbreplica02_ip'}" -o > ${OUTPUT_DIR}/setup_proxy_dbservers_px2.txt

echo "ProxySQL deployment has been completed successfully!"
