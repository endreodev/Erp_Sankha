Verifique permissões do usuário

O usuário system precisa de privilégios para realizar a exportação:
GRANT EXP_FULL_DATABASE TO system;

Importação
expdp system/0000d121c554 directory=DATA_PUMP_DIR dumpfile=SANKHYA.dmp logfile=SANKHYA.log exclude=statistics schemas=SANKHYA

Verifique se o usuário SANKHYA existe
SELECT username FROM dba_users WHERE username = 'SANKHYA';


Abra o SQL*Plus como SYSDBA 
sqlplus / as sysdba

Verifique o status do usuário SYSTEM
SELECT username, account_status FROM dba_users WHERE username = 'SYSTEM';

Desbloqueie o usuário SYSTEM
ALTER USER system ACCOUNT UNLOCK;

Redefina a senha do usuário SYSTEM (caso tenha sido esquecida)
ALTER USER system IDENTIFIED BY tecsis;


Para Executar comando de criar usuaro 

sqlplus / as sysdba @home/oracle/Criar_Usuario_Sankhya.sql


#memoria 
SHOW PARAMETER MEMORY;





ALTER SYSTEM SET MEMORY_MAX_TARGET=8G SCOPE=SPFILE;
ALTER SYSTEM SET MEMORY_TARGET=8G SCOPE=SPFILE;

SHUTDOWN IMMEDIATE;
STARTUP;



Registrar Automaticamente o Serviço
Outra opção é ativar o registro dinâmico, para que o banco de dados se registre automaticamente ao iniciar. Para isso, edite o init.ora ou spfile.ora e adicione:

sql
alter system set local_listener='(ADDRESS=(PROTOCOL=TCP)(HOST=127.0.0.1)(PORT=1521))' scope=both;
Depois, registre o serviço:

sql
alter system register;
6. Testar a Conexão
Agora, tente conectar ao banco de dados:

sh
sqlplus usuario/senha@orcl
Se houver problemas, rode:

sh
tnsping orcl
Se precisar de mais detalhes, execute:

sh
lsnrctl services
Isso listará os serviços disponíveis no listener.


UPDATE SANKHYA.TSIUSU SET INTERNO = NULL WHERE CODUSU = 0;