#!/usr/bin/env bash

cat > cloud_init.sh << EOT
#!/usr/bin/env bash
cat > /etc/fuse_connection.cfg << EOF
accountName ${TF_VAR_STORAGE_ACCOUNT_NAME}
accountKey ${STORAGE_KEY}
containerName ${TF_VAR_STORAGE_CONTAINER_NAME}
EOF

cat > /etc/vsftpd.conf << EOF
secure_chroot_dir=/var/tmp/vsftp_empty
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
pam_service_name=vsftpd
allow_writeable_chroot=YES
pam_service_name=ftp
write_enable=YES
chroot_local_user=YES
local_umask=022
force_dot_files=YES
pasv_min_port=40000
pasv_max_port=41000
userlist_enable=YES
userlist_file=/etc/vsftpd.userlist
userlist_deny=NO
log_ftp_protocol=YES
xferlog_std_format=NO
ssl_enable=YES
rsa_cert_file=/etc/ssl/private/vsftpd.pem
rsa_private_key_file=/etc/ssl/private/vsftpd.pem
allow_anon_ssl=NO
#force_local_data_ssl=NO
#force_local_logins_ssl=NO
ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO
#require_ssl_reuse=NO
#ssl_ciphers=HIGH
EOF

cat > /etc/rc.local << EOF
#!/bin/sh -e
modprobe fuse
blobfuse /${TF_VAR_STORAGE_BLOB_NAME}  --tmp-path=/fuse_tmp  --config-file=/etc/fuse_connection.cfg -o attr_timeout=240 -o entry_timeout=240 -o negative_timeout=120 -o allow_other
service vsftpd start
exit 0
EOF

cat > /etc/openssl.cnf <<EOF
[ req ]
prompt = no
distinguished_name = ${TF_VAR_STORAGE_BLOB_NAME}.hadoopol.com

[ ${TF_VAR_STORAGE_BLOB_NAME}.hadoopol.com ]
C = BR
ST = FtpServer
L = FtpServer
O = FtpServer
OU = FtpServer
CN = hadoopol
emailAddress = localhost@localhost
EOF

mkdir /fuse_tmp
mkdir -p /var/tmp/vsftp_empty
mkdir /${TF_VAR_STORAGE_BLOB_NAME}
chmod gou+rx /etc/rc.local
chmod 600 /etc/fuse_connection.cfg
chmod 777 /${TF_VAR_STORAGE_BLOB_NAME}
chmod +x /etc/rc.local
groupadd ftp

apt-get update
apt-get -y install curl gnupg software-properties-common libcurl3-gnutls vsftpd kmod
curl -sSL https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
apt-add-repository https://packages.microsoft.com/ubuntu/18.04/prod
apt-get -y install blobfuse

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/vsftpd.pem -out /etc/ssl/private/vsftpd.pem -config /etc/openssl.cnf

systemctl disable sshd
systemctl disable vsftpd
systemctl enable rc-local
service rc-local start
EOT

for ftpuser in "${FTP_USERS[@]}" ; do
  user=`echo $ftpuser | cut -d":" -f1`
cat >> cloud_init.sh << EOT
  useradd -m -d /${TF_VAR_STORAGE_BLOB_NAME} -s /bin/false -G ftp ${user}
  echo ${user} >> /etc/vsftpd.userlist
  echo ${ftpuser} | chpasswd
EOT
done

chmod 777 cloud_init.sh












