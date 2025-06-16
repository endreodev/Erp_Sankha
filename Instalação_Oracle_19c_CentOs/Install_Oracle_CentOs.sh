#!/bin/bash
# repositorios funcional CENTOS7
#sudo curl -o /etc/yum.repos.d/CentOS-Base.repo https://el7.repo.almalinux.org/centos/CentOS-Base.repo
#informe a interface de rede na lina 88, no campo eth0
#
# Instalacao de recursos e bibliotecas
yum install -y bc \
binutils \
elfutils-libelf \
elfutils-libelf-devel \
fontconfig-devel \
glibc \
ksh \
glibc-devel \
libaio \
libaio-devel \
libXrender \
libXrender-devel \
libX11 \
libXau \
libXi \
libXtst \
libgcc \
librdmacm-devel \
libstdc++ \
libstd++-devel \
libxcb \
make \
net-tools \
smartmontools \
sysstat \
unzip \
libnsl \
libnsl2 \ 
wget 
## adicionar pacotes adicionais para o CentOS 8

# criar do usuario oracle
adduser oracle
usermod -a -G wheel oracle
echo "oracle" | passwd oracle --stdin

# criando grupos
groupadd oinstall
groupadd dba
groupadd oper
groupadd backupdba
groupadd dgdba
groupadd kmdba
groupadd racdba
usermod -g oinstall -G dba,oper,backupdba,dgdba,kmdba,racdba oracle

### criando limatacoes oracle 
touch /etc/security/limits.d/30-oracle.conf
echo "oracle    soft    nofile    1024
oracle    hard    nofile    65536
oracle    soft    nproc     16384
oracle    hard    nproc     16384
oracle    soft    stack     10240
oracle    hard    stack     32768
oracle    hard    memlock   134217728
oracle    soft    memlock   134217728" > /etc/security/limits.d/30-oracle.conf

### criando parametros de Kernel
touch /etc/sysctl.d/98-oracle.conf
echo "fs.file-max = 6815744
kernel.sem = 250 32000 100 128
kernel.shmmni = 4096
kernel.shmall = 1073741824
kernel.shmmax = 4398046511104
kernel.panic_on_oops = 1
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
net.ipv4.conf.all.rp_filter = 2
net.ipv4.conf.default.rp_filter = 2
fs.aio-max-nr = 1048576
net.ipv4.ip_local_port_range = 9000 65500" > /etc/sysctl.d/98-oracle.conf

# reconhecer os parametros
sysctl -p

# Configurando selinux 
sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/sysconfig/selinux
setenforce permissive

# Configurando Firewall
###inteface de rede
firewall-cmd --zone=home --change-interface=eth0
firewall-cmd --set-default-zone=home
firewall-cmd --zone=home --permanent --add-port=1521/tcp
#firewall-cmd --zone=home --permanent --list-ports

# Configurando hosts
echo "localhost $HOSTNAME $HOSTNAME.localdomain" >> /etc/hosts

# Configurando diretorios
mkdir -p /u01/app/oracle/product/19.3.0.0/dbhome_1

# Download do arquivo Base
URL_19C="https://init-tecnologia.s3.sa-east-1.amazonaws.com/LINUX.X64_193000_db_home.zip"
wget -P /u01/app/oracle/product/19.3.0.0/dbhome_1 $URL_19C

# Extrair conteudo
unzip /u01/app/oracle/product/19.3.0.0/dbhome_1/LINUX.X64_193000_db_home.zip -d /u01/app/oracle/product/19.3.0.0/dbhome_1

## configurando compatibilidade de SO para instalacao
sed -i 's/^#CV_ASSUME_DISTID=OEL5/CV_ASSUME_DISTID=OEL8.1/g' /u01/app/oracle/product/19.3.0.0/dbhome_1/cv/admin/cvu_config

### Configurando Variavel ###
echo ' # .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

# User specific environment and startup programs

export ORACLE_SID=orcl
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/19.3.0.0/dbhome_1
export ORACLE_UNQNAME=orcl
export NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P1
export ORACLE_OWNER=oracle
export ORACLE_TERM=xterm
export PATH=$ORACLE_HOME/bin:$ORA_CRS_HOME/bin:$PATH:/usr/local/bin
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$ORA_CRS_HOME/lib:/usr/local/lib:$LD_LIBRARY_PATH
export CLASSPATH=$ORACLE_HOME/JRE:$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib' > /home/oracle/.bash_profile
sleep 2
source /home/oracle/.bash_profile
chown oracle: /home/oracle/.bash_profile

##### instalacao ####
# Copiar arquivo para backup
cp /u01/app/oracle/product/19.3.0.0/dbhome_1/install/response/db_install.rsp /home/oracle/

### config responsefile ####
sed -i 's/^oracle.install.option=.*/oracle.install.option=INSTALL_DB_SWONLY/g' /u01/app/oracle/product/19.3.0.0/dbhome_1/install/response/db_install.rsp
sed -i 's/^UNIX_GROUP_NAME=.*/UNIX_GROUP_NAME=oinstall/g' /u01/app/oracle/product/19.3.0.0/dbhome_1/install/response/db_install.rsp
sed -i 's/^INVENTORY_LOCATION=.*/INVENTORY_LOCATION=\/u01\/app\/oraInventory/g' /u01/app/oracle/product/19.3.0.0/dbhome_1/install/response/db_install.rsp
sed -i 's/^ORACLE_HOME=.*/ORACLE_HOME=\/u01\/app\/oracle\/product\/19.3.0.0\/dbhome_1/g' /u01/app/oracle/product/19.3.0.0/dbhome_1/install/response/db_install.rsp
sed -i 's/^ORACLE_BASE=.*/ORACLE_BASE=\/u01\/app\/oracle/g' /u01/app/oracle/product/19.3.0.0/dbhome_1/install/response/db_install.rsp
sed -i 's/^oracle.install.db.InstallEdition=.*/oracle.install.db.InstallEdition=EE/g' /u01/app/oracle/product/19.3.0.0/dbhome_1/install/response/db_install.rsp
sed -i 's/^oracle.install.db.OSDBA_GROUP=.*/oracle.install.db.OSDBA_GROUP=dba/g' /u01/app/oracle/product/19.3.0.0/dbhome_1/install/response/db_install.rsp
sed -i 's/^oracle.install.db.OSOPER_GROUP=.*/oracle.install.db.OSOPER_GROUP=oper/g' /u01/app/oracle/product/19.3.0.0/dbhome_1/install/response/db_install.rsp
sed -i 's/^oracle.install.db.OSBACKUPDBA_GROUP=.*/oracle.install.db.OSBACKUPDBA_GROUP=backupdba/g' /u01/app/oracle/product/19.3.0.0/dbhome_1/install/response/db_install.rsp
sed -i 's/^oracle.install.db.OSDGDBA_GROUP=.*/oracle.install.db.OSDGDBA_GROUP=dgdba/g' /u01/app/oracle/product/19.3.0.0/dbhome_1/install/response/db_install.rsp
sed -i 's/^oracle.install.db.OSKMDBA_GROUP=.*/oracle.install.db.OSKMDBA_GROUP=kmdba/g' /u01/app/oracle/product/19.3.0.0/dbhome_1/install/response/db_install.rsp
sed -i 's/^oracle.install.db.OSRACDBA_GROUP=.*/oracle.install.db.OSRACDBA_GROUP=racdba/g' /u01/app/oracle/product/19.3.0.0/dbhome_1/install/response/db_install.rsp
sleep 2
chown -R oracle:oinstall /u01

### instalcao do SGBD
su - oracle -c "bash /u01/app/oracle/product/19.3.0.0/dbhome_1/./runInstaller -silent -responseFile /u01/app/oracle/product/19.3.0.0/dbhome_1/install/response/db_install.rsp"

# scripts em root
bash /u01/app/oraInventory/orainstRoot.sh
bash /u01/app/oracle/product/19.3.0.0/dbhome_1/root.sh

# criacao do listener
cp /u01/app/oracle/product/19.3.0.0/dbhome_1/assistants/netca/netca.rsp /home/oracle/
su - oracle -c "netca -silent -responsefile /u01/app/oracle/product/19.3.0.0/dbhome_1/assistants/netca/netca.rsp"

# criacao do banco
su - oracle -c "dbca -silent -createDatabase \
     -templateName General_Purpose.dbc \
     -gdbname orcl -sid orcl -responseFile NO_VALUE \
     -characterSet WE8ISO8859P1 \
     -sysPassword Tecsis@2655 \
     -systemPassword Tecsis@2655 \
     -createAsContainerDatabase false \
     -databaseType MULTIPURPOSE \
     -memoryMgmtType auto_sga \
     -totalMemory 2000 \
     -redoLogFileSize 200 \
     -emConfiguration NONE \
     -ignorePreReqs"

# FINAL
rm -rf /u01/app/oracle/product/19.3.0.0/dbhome_1/LINUX.X64_193000_db_home.zip

echo "##################################################"
echo "#      Instalacao realizada com sucesso!         #"
echo "#  A segue a senha de acesso sys = Tecsis@2655   #"
echo "##################################################"
echo 'Teste o banco utilizando os seguintes comandos
su - oracle
sqlplus / as sysdba
select instance_name, status from v$instance;'