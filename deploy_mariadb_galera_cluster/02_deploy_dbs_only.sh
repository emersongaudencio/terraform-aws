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
### deploy databases ###
echo 'resource "aws_instance" "dbcluster01" {
  ami           = var.AMIS[var.AWS_REGION]
  instance_type = var.DB_INSTANCE_TYPE

  # the VPC subnet
  subnet_id = var.DB_SUBNET_ID_AZA

  # the security group
  vpc_security_group_ids = [aws_security_group.allow-ssh.id, aws_security_group.allow-mariadb.id]

  # the public SSH key
  key_name = aws_key_pair.mykeypair.key_name

  root_block_device {
      volume_size = 50
      volume_type = "gp2"
      delete_on_termination = true
    }

  tags = {
    Name = "dbcluster01"
    Terraform   = "true"
    Environment = "turbodba-prod"
    Group = "mariadb-galera-cluster"
  }
}' > dbcluster01.tf

echo 'resource "aws_instance" "dbcluster02" {
  ami           = var.AMIS[var.AWS_REGION]
  instance_type = var.DB_INSTANCE_TYPE

  # the VPC subnet
  subnet_id = var.DB_SUBNET_ID_AZB

  # the security group
  vpc_security_group_ids = [aws_security_group.allow-ssh.id, aws_security_group.allow-mariadb.id]

  # the public SSH key
  key_name = aws_key_pair.mykeypair.key_name

  tags = {
    Name = "dbcluster02"
    Terraform   = "true"
    Environment = "turbodba-prod"
    Group = "mariadb-galera-cluster"
  }

  root_block_device {
      volume_size = 50
      volume_type = "gp2"
      delete_on_termination = true
    }
}' > dbcluster02.tf

echo 'resource "aws_instance" "dbcluster03" {
  ami           = var.AMIS[var.AWS_REGION]
  instance_type = var.DB_INSTANCE_TYPE

  # the VPC subnet
  subnet_id = var.DB_SUBNET_ID_AZC

  # the security group
  vpc_security_group_ids = [aws_security_group.allow-ssh.id, aws_security_group.allow-mariadb.id]

  # the public SSH key
  key_name = aws_key_pair.mykeypair.key_name

  tags = {
    Name = "dbcluster03"
    Terraform   = "true"
    Environment = "turbodba-prod"
    Group = "mariadb-galera-cluster"
  }

  root_block_device {
      volume_size = 50
      volume_type = "gp2"
      delete_on_termination = true
    }
}' > dbcluster03.tf

echo '# Output the private IP address of the new droplet
output "private_ip_server_dbcluster01" {  value = aws_instance.dbcluster01.private_ip }
output "private_ip_server_dbcluster02" {  value = aws_instance.dbcluster02.private_ip }
output "private_ip_server_dbcluster03" {  value = aws_instance.dbcluster03.private_ip }

# Output the public IP address of the new droplet
output "public_ip_server_dbcluster01" {  value = aws_instance.dbcluster01.public_ip }
output "public_ip_server_dbcluster02" {  value = aws_instance.dbcluster02.public_ip }
output "public_ip_server_dbcluster03" {  value = aws_instance.dbcluster03.public_ip }
' > output_dbservers.tf

### apply changes to digital ocean ###
terraform apply -auto-approve

### vars databases ###
# private ips
dbcluster01_ip=`terraform output private_ip_server_dbcluster01`
dbcluster02_ip=`terraform output private_ip_server_dbcluster02`
dbcluster03_ip=`terraform output private_ip_server_dbcluster03`
# public ips
dbcluster01_ip_pub=`terraform output public_ip_server_dbcluster01`
dbcluster02_ip_pub=`terraform output public_ip_server_dbcluster02`
dbcluster03_ip_pub=`terraform output public_ip_server_dbcluster03`

# create db_ips file for proxysql deployment #
echo "dbcluster01_ip:$dbcluster01_ip" > ${OUTPUT_DIR}/db_ips.txt
echo "dbcluster02_ip:$dbcluster02_ip" >> ${OUTPUT_DIR}/db_ips.txt
echo "dbcluster03_ip:$dbcluster03_ip" >> ${OUTPUT_DIR}/db_ips.txt

# create db_hosts file for ansible database replica setup #
echo "[galeracluster]" > ${OUTPUT_DIR}/db_hosts.txt
echo "dbcluster01 ansible_ssh_host=$dbcluster01_ip_pub" >> ${OUTPUT_DIR}/db_hosts.txt
echo "dbcluster02 ansible_ssh_host=$dbcluster02_ip_pub" >> ${OUTPUT_DIR}/db_hosts.txt
echo "dbcluster03 ansible_ssh_host=$dbcluster03_ip_pub" >> ${OUTPUT_DIR}/db_hosts.txt

### pre-reqs install ###
curl -s https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_latest.sh -o install_ansible_latest.sh
sh install_ansible_latest.sh

sleep 60

# MariaDB Galera Cluster installation setup #
git clone https://github.com/emersongaudencio/ansible-mariadb-galera-cluster.git
cd ansible-mariadb-galera-cluster/ansible
priv_key="/root/repos/ansible_keys/ansible"
# adjusting ansible parameters
sed -ie 's/ansible/\/usr\/local\/bin\/ansible/g' run_mariadb_galera_install.sh
sed -ie 's/# remote_user = ec2-user/remote_user = centos/g' ansible.cfg
#### MariaDB deployment variables ####
GTID=$(($RANDOM))
echo $GTID > GTID
MARIADB_VERSION="104"
echo $MARIADB_VERSION > MARIADB_VERSION
CLUSTER_NAME="mariadbcluster"
echo $CLUSTER_NAME > CLUSTER_NAME
#### MariaDB deployment ansible hosts variables ####
echo "[galeracluster]" > hosts
echo "dbcluster01 ansible_ssh_host=$dbcluster01_ip_pub" >> hosts
echo "dbcluster02 ansible_ssh_host=$dbcluster02_ip_pub" >> hosts
echo "dbcluster03 ansible_ssh_host=$dbcluster03_ip_pub" >> hosts
#### private key link ####
ln -s $priv_key ansible
#### Execution section ####
sudo sh run_mariadb_galera_install.sh dbcluster01 $MARIADB_VERSION $GTID "$dbcluster01_ip" "$CLUSTER_NAME" "$dbcluster01_ip,$dbcluster02_ip,$dbcluster03_ip"
sleep 30
sudo sh run_mariadb_galera_install.sh dbcluster02 $MARIADB_VERSION $GTID "$dbcluster01_ip" "$CLUSTER_NAME" "$dbcluster01_ip,$dbcluster02_ip,$dbcluster03_ip"
sleep 30
sudo sh run_mariadb_galera_install.sh dbcluster03 $MARIADB_VERSION $GTID "$dbcluster01_ip" "$CLUSTER_NAME" "$dbcluster01_ip,$dbcluster02_ip,$dbcluster03_ip"

# setup proxysql user for monitoring purpose #
ansible -i hosts -m shell -a "mysql -N -e \"GRANT PROCESS, REPLICATION CLIENT ON *.* TO 'proxysqlchk'@'%' IDENTIFIED BY 'Test123?dba';\"" dbcluster01 -o > setup_galeracluster_proxysql_user.txt

echo "Database deployment has been completed successfully!"
