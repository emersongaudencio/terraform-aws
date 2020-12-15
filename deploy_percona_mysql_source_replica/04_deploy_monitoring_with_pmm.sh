#!/bin/bash
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

### deploy PMM ###
echo 'resource "aws_security_group" "allow-pmm" {
  vpc_id      = var.VPC_ID
  name        = "allow-pmm"
  description = "allow-pmm"
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }
  tags = {
    Name = "allow-pmm"
  }
}
' > securitygroup_pmmserver.tf

echo 'resource "aws_instance" "pmmserver01" {
  ami           = var.AMIS[var.AWS_REGION]
  instance_type = "t3.xlarge"

  # the VPC subnet
  subnet_id = var.DB_SUBNET_ID_AZC

  # the security group
  vpc_security_group_ids = [aws_security_group.allow-ssh.id, aws_security_group.allow-mariadb.id, aws_security_group.allow-pmm.id]

  # the public SSH key
  key_name = aws_key_pair.mykeypair.key_name

  tags = {
    Name = "pmmserver01"
    Terraform   = "true"
    Environment = "turbodba-prod"
    Group = "monitoring-tool"
  }

  root_block_device {
      volume_size = 50
      volume_type = "gp2"
      delete_on_termination = true
    }

  ebs_block_device {
      device_name = "/dev/sdb"
      volume_type = "gp2"
      volume_size = 100
    }
}' > pmmserver01.tf

echo '# Output the private IP address of the new VM
output "private_ip_server_pmmserver01" {  value = aws_instance.pmmserver01.private_ip }

# Output the public IP address of the new VM
output "public_ip_server_pmmserver01" {  value = aws_instance.pmmserver01.public_ip }
' > output_pmmserver.tf

### apply changes to AWS ###
terraform apply -auto-approve

### vars pmm ###
# private ips
pmmserver01_ip=`terraform output private_ip_server_pmmserver01`
# public ips
pmmserver01_ip_pub=`terraform output public_ip_server_pmmserver01`

# create db_ips file for proxysql deployment #
echo "pmmserver01:$pmmserver01_ip" > pmmserver_ips.txt

# create db_hosts file for ansible setup #
echo "[monitoring]" > ${OUTPUT_DIR}/pmmserver_hosts.txt
echo "pmmserver01 ansible_ssh_host=$pmmserver01_ip_pub" >> ${OUTPUT_DIR}/pmmserver_hosts.txt

# wait until databases are fully deployed #
sleep 90

# setup change hostname #
ansible -i ${OUTPUT_DIR}/pmmserver_hosts.txt -m shell -a "echo \"127.0.0.1 pmmserver01\" | sudo tee -a /etc/hosts && hostnamectl set-hostname pmmserver01" pmmserver01 -u $ansible_user --private-key=$priv_key --become -o > ${OUTPUT_DIR}/setup_change_hostname_pmmserver01.txt

# Setup disks for PMM to the new VM instances using Ansible
ansible -i ${OUTPUT_DIR}/pmmserver_hosts.txt -m shell -a "curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/setup_disks_pmm_server_standalone.sh | sudo bash" pmmserver01 -u $ansible_user --private-key=$priv_key --become -o > ${OUTPUT_DIR}/setup_disks_pmmserver01.txt

# deploy PMM to the new VM instances using Ansible
ansible -i ${OUTPUT_DIR}/pmmserver_hosts.txt -m shell -a "curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_pmm_server_standalone.sh | sudo bash" pmmserver01 -u $ansible_user --private-key=$priv_key --become -o > ${OUTPUT_DIR}/install_pmmserver01.txt

echo "PMM deployment has been completed successfully!"
