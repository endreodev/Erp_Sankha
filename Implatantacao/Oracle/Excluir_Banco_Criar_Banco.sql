
--Excluir Banco 
dbca -silent -deleteDatabase \
     -sourceDB orcl \
     -sysDBAUserName sys \
     -sysDBAPassword T3csis#2025


--Criar Banco
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
