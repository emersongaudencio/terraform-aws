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
dbstandby01_ip=$(cat ${OUTPUT_DIR}/db_ips.txt | grep dbstandby01 | awk -F ":" {'print $2'})

### deploy MaxScale ###
echo 'resource "aws_instance" "maxscale01" {
  ami           = var.AMIS[var.AWS_REGION]
  instance_type = var.PROXY_INSTANCE_TYPE

  # the VPC subnet
  subnet_id = var.DB_SUBNET_ID_AZA

  # the security group
  vpc_security_group_ids = [aws_security_group.allow-ssh.id, aws_security_group.allow-mariadb.id]

  # the public SSH key
  key_name = aws_key_pair.mykeypair.key_name

  tags = {
    Name = "maxscale01"
  }

  root_block_device {
      volume_size = 50
      volume_type = "gp2"
      delete_on_termination = true
    }
}' > maxscale01.tf

echo 'resource "aws_instance" "maxscale02" {
  ami           = var.AMIS[var.AWS_REGION]
  instance_type = var.PROXY_INSTANCE_TYPE

  # the VPC subnet
  subnet_id = var.DB_SUBNET_ID_AZB

  # the security group
  vpc_security_group_ids = [aws_security_group.allow-ssh.id, aws_security_group.allow-mariadb.id]

  # the public SSH key
  key_name = aws_key_pair.mykeypair.key_name

  tags = {
    Name = "maxscale02"
  }

  root_block_device {
      volume_size = 50
      volume_type = "gp2"
      delete_on_termination = true
    }
}' > maxscale02.tf


echo '# Output the private IP address of the new droplet
output "private_ip_server_maxscale01" {  value = aws_instance.maxscale01.private_ip }
output "private_ip_server_maxscale02" {  value = aws_instance.maxscale02.private_ip }

# Output the public IP address of the new droplet
output "public_ip_server_maxscale01" {  value = aws_instance.maxscale01.public_ip }
output "public_ip_server_maxscale02" {  value = aws_instance.maxscale02.public_ip }
' > output_proxyservers.tf

### apply changes to digital ocean ###
terraform apply -auto-approve

### vars proxysql ###
# private ips
maxscale01_ip=`terraform output private_ip_server_maxscale01`
maxscale02_ip=`terraform output private_ip_server_maxscale02`
# public ips
maxscale01_ip_pub=`terraform output public_ip_server_maxscale01`
maxscale02_ip_pub=`terraform output public_ip_server_maxscale02`

# create db_ips file for proxysql deployment #
echo "maxscale01:$maxscale01_ip" > proxy_ips.txt
echo "maxscale02:$maxscale02_ip" >> proxy_ips.txt

# create db_hosts file for ansible database replica setup #
echo "[proxyservers]" > ${OUTPUT_DIR}/proxy_hosts.txt
echo "maxscale01 ansible_ssh_host=$maxscale01_ip_pub" >> ${OUTPUT_DIR}/proxy_hosts.txt
echo "maxscale02 ansible_ssh_host=$maxscale02_ip_pub" >> ${OUTPUT_DIR}/proxy_hosts.txt

# wait until databases are fully deployed #
sleep 90

# insert dns entries for ProxySQL on /etc/hosts
ansible -i ${OUTPUT_DIR}/proxy_hosts.txt -m shell -a 'echo "# dbservers" >> /etc/hosts && echo "{{ dbprimary01_ip }} dbprimary01.replication.local" >> /etc/hosts && echo "{{ dbstandby01_ip }} dbstandby01.replication.local" >> /etc/hosts; cat /etc/hosts' maxscale01 -u $ansible_user --private-key=$priv_key --become -e "{dbprimary01_ip: '$dbprimary01_ip', dbstandby01_ip: '$dbstandby01_ip'}" -o > ${OUTPUT_DIR}/setup_proxy_dbservers_mx1.txt
ansible -i ${OUTPUT_DIR}/proxy_hosts.txt -m shell -a 'echo "# dbservers" >> /etc/hosts && echo "{{ dbprimary01_ip }} dbprimary01.replication.local" >> /etc/hosts && echo "{{ dbstandby01_ip }} dbstandby01.replication.local" >> /etc/hosts; cat /etc/hosts' maxscale02 -u $ansible_user --private-key=$priv_key --become -e "{dbprimary01_ip: '$dbprimary01_ip', dbstandby01_ip: '$dbstandby01_ip'}" -o > ${OUTPUT_DIR}/setup_proxy_dbservers_mx2.txt

# deploy MaxScale to the new VM instances using Ansible
ansible -i ${OUTPUT_DIR}/proxy_hosts.txt -m shell -a "curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_maxscale_primary_standby.sh | sudo bash" proxyservers -u $ansible_user --private-key=$priv_key --become -o > ${OUTPUT_DIR}/install_proxysql_proxyservers.txt

echo "MaxScale deployment has been completed successfully!"
