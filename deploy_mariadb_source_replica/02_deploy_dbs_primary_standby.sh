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
echo 'resource "aws_instance" "dbprimary01" {
  ami           = var.AMIS[var.AWS_REGION]
  instance_type = var.DB_INSTANCE_TYPE

  # the VPC subnet
  subnet_id = var.DB_SUBNET_ID_AZA

  # the security group
  vpc_security_group_ids = [aws_security_group.allow-ssh.id, aws_security_group.allow-mariadb.id]

  # the public SSH key
  key_name = aws_key_pair.mykeypair.key_name

  tags = {
    Name = "dbprimary01"
  }

  root_block_device {
      volume_size = 50
      volume_type = "gp2"
      delete_on_termination = true
    }
}' > dbprimary01.tf

echo 'resource "aws_instance" "dbstandby01" {
  ami           = var.AMIS[var.AWS_REGION]
  instance_type = var.DB_INSTANCE_TYPE

  # the VPC subnet
  subnet_id = var.DB_SUBNET_ID_AZB

  # the security group
  vpc_security_group_ids = [aws_security_group.allow-ssh.id, aws_security_group.allow-mariadb.id]

  # the public SSH key
  key_name = aws_key_pair.mykeypair.key_name

  tags = {
    Name = "dbstandby01"
  }

  root_block_device {
      volume_size = 50
      volume_type = "gp2"
      delete_on_termination = true
    }
}' > dbstandby01.tf

echo '# Output the private IP address of the new VM instance
output "private_ip_server_dbprimary01" {  value = aws_instance.dbprimary01.private_ip }
output "private_ip_server_dbstandby01" {  value = aws_instance.dbstandby01.private_ip }

# Output the public IP address of the new VM instance
output "public_ip_server_dbprimary01" {  value = aws_instance.dbprimary01.public_ip }
output "public_ip_server_dbstandby01" {  value = aws_instance.dbstandby01.public_ip }
' > output_dbservers.tf

### apply changes to digital ocean ###
terraform apply -auto-approve

### vars databases ###
# private ips
dbprimary01_ip=`terraform output private_ip_server_dbprimary01`
dbstandby01_ip=`terraform output private_ip_server_dbstandby01`
# public ips
dbprimary01_ip_pub=`terraform output public_ip_server_dbprimary01`
dbstandby01_ip_pub=`terraform output public_ip_server_dbstandby01`

# create db_ips file for proxysql deployment #
echo "dbprimary01:$dbprimary01_ip" > ${OUTPUT_DIR}/db_ips.txt
echo "dbstandby01:$dbstandby01_ip" >> ${OUTPUT_DIR}/db_ips.txt

# create db_hosts file for ansible database replica setup #
echo "[dbservers]" > ${OUTPUT_DIR}/db_hosts.txt
echo "dbprimary01 ansible_ssh_host=$dbprimary01_ip_pub" >> ${OUTPUT_DIR}/db_hosts.txt
echo "dbstandby01 ansible_ssh_host=$dbstandby01_ip_pub" >> ${OUTPUT_DIR}/db_hosts.txt

# wait until ssh conn are fully deployed #
sleep 90

# deploy MariaDB to the new VM instances using Ansible
ansible -i ${OUTPUT_DIR}/db_hosts.txt -m shell -a "curl -sS https://raw.githubusercontent.com/emersongaudencio/general-deployment-scripts/master/automation/install_ansible_mariadb_104.sh | sudo bash" dbservers -u $ansible_user --private-key=$priv_key --become -o > ${OUTPUT_DIR}/install_mariadb_dbservers.txt
ansible -i ${OUTPUT_DIR}/db_hosts.txt -m shell -a "sed -ie 's/gtid_strict_mode                        = 0/gtid_strict_mode                        = 1/g' /etc/my.cnf.d/server.cnf" dbservers -u $ansible_user --private-key=$priv_key --become -o > ${OUTPUT_DIR}/setup_change_server_parameters.txt
# wait until databases are fully deployed #
sleep 60

# replication setup using ansbile for automation purpose #
ansible -i ${OUTPUT_DIR}/db_hosts.txt -m shell -a "mysql -N -e 'show master status'" dbprimary01 -u $ansible_user --private-key=$priv_key --become -o > ${OUTPUT_DIR}/setup_replication_master_position.txt
ansible -i ${OUTPUT_DIR}/db_hosts.txt -m shell -a "cat /root/.my.cnf | grep replication_user" dbprimary01 -u $ansible_user --private-key=$priv_key --become -o > ${OUTPUT_DIR}/setup_replication_user_master.txt
# get replication_credentials info
rep_user=$(cat ${OUTPUT_DIR}/setup_replication_user_master.txt | awk -F "|" {'print $4'} | awk {'print $3'})
rep_pwd=$(cat ${OUTPUT_DIR}/setup_replication_user_master.txt | awk -F "|" {'print $4'} | awk {'print $6'})
# get replication file info #
log_file=$(cat ${OUTPUT_DIR}/setup_replication_master_position.txt | awk -F "|" {'print $4'} | awk {'print $2'})
log_position=$(cat ${OUTPUT_DIR}/setup_replication_master_position.txt | awk -F "|" {'print $4'} | awk {'print $3'})
# get replication gtid position info #
ansible -i ${OUTPUT_DIR}/db_hosts.txt -m shell -a 'mysql -N -e "SELECT BINLOG_GTID_POS(\"{{ log_file }}\",\"{{ log_position }}\");"' dbprimary01 -u $ansible_user --private-key=$priv_key --become -e "{log_file: '$log_file', log_position: '$log_position'}" -o > ${OUTPUT_DIR}/setup_replication_master_gtid.txt
gtid_slave_pos=$(cat ${OUTPUT_DIR}/setup_replication_master_gtid.txt | awk -F "|" {'print $4'} | awk {'print $2'})
# setup replication on replica servers #
master_host=$(cat ${OUTPUT_DIR}/db_ips.txt | grep dbprimary01 | awk -F ":" {'print $2'})
ansible -i ${OUTPUT_DIR}/db_hosts.txt -m shell -a 'mysql -N -e "RESET SLAVE ALL; RESET MASTER; SET GLOBAL gtid_slave_pos = \"{{ gtid_slave_pos }}\"; CHANGE MASTER TO master_host=\"{{ master_host }}\", master_port=3306, master_user=\"{{ master_user }}\", master_password = \"{{ master_password }}\", master_use_gtid=CURRENT_POS; START SLAVE; SHOW SLAVE STATUS\G"' dbstandby01 -u $ansible_user --private-key=/root/repos/ansible_keys/ansible --become -e "{gtid_slave_pos: '$gtid_slave_pos', master_host: '$master_host', master_user: '$rep_user' , master_password: '$rep_pwd' }" -o > ${OUTPUT_DIR}/setup_replication_dbstandby01_activation.txt
# setup proxysql user for monitoring purpose #
ansible -i ${OUTPUT_DIR}/db_hosts.txt -m shell -a "mysql -N -e \"CREATE USER 'maxscalechk'@'%' IDENTIFIED BY 'Test123?dba'; GRANT SELECT ON mysql.* TO 'maxscalechk'@'%'; GRANT SHOW DATABASES ON *.* TO 'maxscalechk'@'%';\"" dbprimary01 -u $ansible_user --private-key=$priv_key --become -o > ${OUTPUT_DIR}/setup_replication_proxysql_maxscalechk.txt
ansible -i ${OUTPUT_DIR}/db_hosts.txt -m shell -a "mysql -N -e \"CREATE USER 'monitor_user'@'%' IDENTIFIED BY 'Test123?dba'; GRANT SUPER, RELOAD, REPLICATION CLIENT, REPLICATION SLAVE on *.* to 'monitor_user'@'%';\"" dbprimary01 -u $ansible_user --private-key=$priv_key --become -o > ${OUTPUT_DIR}/setup_replication_proxysql_monitor_user.txt
# restart db servers #
ansible -i ${OUTPUT_DIR}/db_hosts.txt -m shell -a "sudo service mariadb restart" dbservers -u $ansible_user --private-key=$priv_key --become -o > ${OUTPUT_DIR}/setup_replication_dbservers_restart.txt
# insert dns entries for DB servers on /etc/hosts
ansible -i ${OUTPUT_DIR}/db_hosts.txt -m shell -a 'echo "# dbservers" >> /etc/hosts && echo "{{ dbprimary01_ip }} dbprimary01.replication.local" >> /etc/hosts && echo "{{ dbstandby01_ip }} dbstandby01.replication.local" >> /etc/hosts; cat /etc/hosts' dbprimary01 -u $ansible_user --private-key=$priv_key --become -e "{dbprimary01_ip: '$dbprimary01_ip', dbstandby01_ip: '$dbstandby01_ip'}" -o > ${OUTPUT_DIR}/setup_dns_on_dbprimary01.txt
ansible -i ${OUTPUT_DIR}/db_hosts.txt -m shell -a 'echo "# dbservers" >> /etc/hosts && echo "{{ dbprimary01_ip }} dbprimary01.replication.local" >> /etc/hosts && echo "{{ dbstandby01_ip }} dbstandby01.replication.local" >> /etc/hosts; cat /etc/hosts' dbstandby01 -u $ansible_user --private-key=$priv_key --become -e "{dbprimary01_ip: '$dbprimary01_ip', dbstandby01_ip: '$dbstandby01_ip'}" -o > ${OUTPUT_DIR}/setup_dns_on_dbstandby01.txt

echo "Database deployment has been completed successfully!"
