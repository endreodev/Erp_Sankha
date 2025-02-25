https://www.youtube.com/watch?v=pA3gXH65ZIU

Link para o edelivery da oracle para download do oracle linux 8.4
https://edelivery.oracle.com/osdc/faces/Home.jspx


Link para o download do rpm do Oracle 19c
https://www.oracle.com/database/technologies/oracle19c-linux-downloads.html


Segue link do download do passo a passo e arquivo de variáveis de ambiente:
https://drive.google.com/drive/folders/1NVPhRegRrbBTXkt5OSEeOe6LRSPqWRZ3

-- Instalando Oracle  
S.O: Oracle Linux 8.4
Oracle: 19.3.0.0

- desabilitando firewall

systemctl stop firewalld
systemctl disable firewalld

putyy root paswd


- configurando hosts

vi /etc/hosts 
vpn-rk.ddns.net logistica-db logistica-db.localdomain 
vpn-rk.ddns.net transriodb-resende transriodb-resende.localdomain 

-- instalando pacote preinstall

yum search preinstall
yum install oracle-database-preinstall-19c.x86_64


- criando grupos e ajustando user oracle

useradd oracle 
Obs: caso não tenha criado na instalação do S.O

id oracle 

groupadd oinstall
groupadd dba
groupadd oper
groupadd backupdba
groupadd dgdba
groupadd kmdba
groupadd racdba
usermod -g oinstall -G dba,oper,backupdba,dgdba,kmdba,racdba oracle

passwd oracle 


-- instalando com o RPM 
yum -y localinstall oracle-database-ee-19c-1.0-1.x86_64.rpm

---/etc/init.d/oracledb_ORCLCDB-19c configure

-- comando criação listener (NETCA)

local: $ORACLE_HOME/assistants/netca
arquivo: netca.rsp
netca -silent -responsefile /home/oracle/netca.rsp

-- Banco de dados (DBCA)

Pode ser deito de duas formas

- arquivo: dbca.rsp
local: $ORACLE_HOME/assistants/dbca

dbca -silent -createDatabase \
     -templateName General_Purpose.dbc \
     -gdbname orcl -sid orcl -responseFile NO_VALUE \
     -characterSet AL32UTF8 \
     -sysPassword tecsis \
     -systemPassword tecsis \
     -createAsContainerDatabase false \  
     -databaseType MULTIPURPOSE \
     -memoryMgmtType auto_sga \
     -totalMemory 2000 \
     -redoLogFileSize 200 \
     -emConfiguration NONE \
     -ignorePreReqs


dbca -silent -deleteDatabase -sourceDB orcl -sysDBAUserName sys -sysDBAPassword tecsis


