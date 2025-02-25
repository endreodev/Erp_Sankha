📌 1. Verificar o Tamanho Atual do /dev/shm
Antes de configurar, verifique o tamanho atual:

sh

df -h | grep shm
Se estiver menor que 12G, prossiga com os ajustes.

📌 2. Configurar /dev/shm Permanentemente no /etc/fstab
Edite o arquivo /etc/fstab:

sh

sudo nano /etc/fstab
Adicione ou edite a seguinte linha:

sh

tmpfs   /dev/shm   tmpfs   defaults,size=12G   0 0
🔹 Isso garante que o tamanho de /dev/shm seja 12GB toda vez que o sistema for reiniciado.

Salve e saia (Ctrl + X, depois Y e Enter).

📌 3. Aplicar as Configurações Sem Reiniciar
Para aplicar a mudança imediatamente sem reiniciar, execute:

sh

sudo mount -o remount,size=12G /dev/shm
Verifique se a mudança foi aplicada corretamente:

sh

df -h | grep shm
Agora /dev/shm deve aparecer com 12G.

📌 4. Testar Após Reinicialização
Para confirmar que a configuração é permanente, reinicie o sistema:

sh

sudo reboot
Depois que o sistema reiniciar, rode novamente:

sh

df -h | grep shm
Se mostrar 12G, a configuração foi aplicada corretamente.

📌 Conclusão
🚀 Agora seu /dev/shm está configurado permanentemente com 12GB!
Isso evita o erro ORA-00845: MEMORY_TARGET not supported on this system no Oracle.

Se precisar de mais ajustes, me avise! 🔥



# Somente ate passo 2 
🔹 1. Habilitar o Uso de Memória Automática
Se quiser que o Oracle gerencie a memória automaticamente, ajuste MEMORY_MAX_TARGET e MEMORY_TARGET para um valor adequado.

Passo 1: Definir o Gerenciamento de Memória
sql

ALTER SYSTEM SET MEMORY_MAX_TARGET=12G SCOPE=SPFILE;
ALTER SYSTEM SET MEMORY_TARGET=12G SCOPE=SPFILE;
🔹 Substitua 8G pelo valor apropriado para sua máquina. Se tiver 16GB de RAM, pode usar 12G.

🔹 2. Se Usar Configuração Manual (SGA + PGA)
Caso queira definir manualmente a distribuição da memória, use:

sql

ALTER SYSTEM SET SGA_TARGET=6G SCOPE=SPFILE;
ALTER SYSTEM SET SGA_MAX_SIZE=6G SCOPE=SPFILE;
ALTER SYSTEM SET PGA_AGGREGATE_TARGET=2G SCOPE=SPFILE;
Isso dividirá 6GB para SGA (System Global Area) e 2GB para PGA (Program Global Area).

🔹 3. Reiniciar o Banco de Dados
Após definir a memória, é necessário reiniciar o banco para aplicar as mudanças:

sql

SHUTDOWN IMMEDIATE;
STARTUP;
🔹 4. Verificar se a Configuração Foi Aplicada
Após a reinicialização, confira os novos valores de memória:

sql

SHOW PARAMETER MEMORY;
SHOW PARAMETER SGA;
SHOW PARAMETER PGA;
Se MEMORY_TARGET estiver correto, agora o Oracle usará mais memória disponível. 🚀

Se precisar de mais ajustes, me avise! 🔥