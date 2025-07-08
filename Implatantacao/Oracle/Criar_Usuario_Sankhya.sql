-- sqlplus / as sysdba @/home/oracle/import.sql
SET ECHO ON
SET FEEDBACK ON
SET VERIFY OFF
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE

SPOOL create_sankhya.log

-- Habilita operações administrativas (necessário em alguns ambientes Oracle)
ALTER SESSION SET "_ORACLE_SCRIPT"=TRUE;

PROMPT ============================
PROMPT = Remoção do usuário
PROMPT ============================

BEGIN
  DECLARE
    v_exists NUMBER := 0;
  BEGIN
    SELECT COUNT(*) INTO v_exists FROM dba_users WHERE username = 'SANKHYA';

    IF v_exists > 0 THEN
      EXECUTE IMMEDIATE 'DROP USER SANKHYA CASCADE';
      DBMS_OUTPUT.PUT_LINE('Usuário SANKHYA excluído.');
    ELSE
      DBMS_OUTPUT.PUT_LINE('Usuário SANKHYA não existe.');
    END IF;
  END;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro ao excluir usuário SANKHYA: ' || SQLERRM);
END;
/

PROMPT ============================
PROMPT = Remoção das tablespaces
PROMPT ============================

DECLARE
  v_tablespace VARCHAR2(30);
BEGIN
  FOR rec IN (SELECT tablespace_name FROM dba_tablespaces 
              WHERE tablespace_name IN ('SANKHYA','SANKIND','SANKLOB')) LOOP
    BEGIN
      v_tablespace := rec.tablespace_name;
      EXECUTE IMMEDIATE 'DROP TABLESPACE ' || v_tablespace || ' INCLUDING CONTENTS AND DATAFILES';
      DBMS_OUTPUT.PUT_LINE('Tablespace ' || v_tablespace || ' excluída.');
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao excluir tablespace ' || v_tablespace || ': ' || SQLERRM);
    END;
  END LOOP;
END;
/

PROMPT ============================
PROMPT = Criação das tablespaces
PROMPT ============================

BEGIN
  EXECUTE IMMEDIATE q'[
    CREATE TABLESPACE SANKHYA
    DATAFILE '/u01/app/oracle/oradata/ORCL/SANKHYA.DBF'
    SIZE 10G
    AUTOEXTEND ON NEXT 1G
    MAXSIZE UNLIMITED
    SEGMENT SPACE MANAGEMENT AUTO
  ]';
  DBMS_OUTPUT.PUT_LINE('Tablespace SANKHYA criada.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro ao criar tablespace SANKHYA: ' || SQLERRM);
END;
/

BEGIN
  EXECUTE IMMEDIATE q'[
    CREATE TABLESPACE SANKIND
    DATAFILE '/u01/app/oracle/oradata/ORCL/SANKIND.DBF'
    SIZE 10G
    AUTOEXTEND ON NEXT 1G
    MAXSIZE UNLIMITED
    SEGMENT SPACE MANAGEMENT AUTO
  ]';
  DBMS_OUTPUT.PUT_LINE('Tablespace SANKIND criada.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro ao criar tablespace SANKIND: ' || SQLERRM);
END;
/

BEGIN
  EXECUTE IMMEDIATE q'[
    CREATE TABLESPACE SANKLOB
    DATAFILE '/u01/app/oracle/oradata/ORCL/SANKLOB.DBF'
    SIZE 10G
    AUTOEXTEND ON NEXT 1G
    MAXSIZE UNLIMITED
    SEGMENT SPACE MANAGEMENT AUTO
  ]';
  DBMS_OUTPUT.PUT_LINE('Tablespace SANKLOB criada.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro ao criar tablespace SANKLOB: ' || SQLERRM);
END;
/

PROMPT ============================
PROMPT = Criação do usuário SANKHYA
PROMPT ============================

BEGIN
  EXECUTE IMMEDIATE q'[
    CREATE USER SANKHYA IDENTIFIED BY "tecsis"
      DEFAULT TABLESPACE SANKHYA
      TEMPORARY TABLESPACE TEMP
      QUOTA UNLIMITED ON SANKHYA
      QUOTA UNLIMITED ON SANKIND
      QUOTA UNLIMITED ON SANKLOB
      PASSWORD EXPIRE
      ACCOUNT UNLOCK
  ]';
  DBMS_OUTPUT.PUT_LINE('Usuário SANKHYA criado.');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro ao criar usuário SANKHYA: ' || SQLERRM);
END;
/

PROMPT ============================
PROMPT = Concessão de privilégios
PROMPT ============================

BEGIN
  FOR stmt IN (
    SELECT 'GRANT ' || priv || ' TO SANKHYA' AS sql_cmd FROM (
      SELECT 'CONNECT' priv FROM DUAL UNION ALL
      SELECT 'RESOURCE' FROM DUAL UNION ALL
      SELECT 'DBA' FROM DUAL UNION ALL
      SELECT 'ALL PRIVILEGES' FROM DUAL UNION ALL
      SELECT 'SELECT ON DBA_TRIGGERS' FROM DUAL UNION ALL
      SELECT 'SELECT ON DBA_OBJECTS' FROM DUAL UNION ALL
      SELECT 'SELECT ON V_$SESSION' FROM DUAL UNION ALL
      SELECT 'SELECT ON V_$INSTANCE' FROM DUAL UNION ALL
      SELECT 'EXECUTE ON DBMS_CRYPTO' FROM DUAL UNION ALL
      SELECT 'EXECUTE ON DBMS_OUTPUT' FROM DUAL UNION ALL
      SELECT 'EXECUTE ON DBMS_OBFUSCATION_TOOLKIT' FROM DUAL UNION ALL
      SELECT 'EXECUTE ON DBMS_LOCK' FROM DUAL UNION ALL
      SELECT 'CREATE SESSION' FROM DUAL UNION ALL
      SELECT 'CREATE TABLE' FROM DUAL UNION ALL
      SELECT 'CREATE VIEW' FROM DUAL UNION ALL
      SELECT 'CREATE SEQUENCE' FROM DUAL UNION ALL
      SELECT 'CREATE PROCEDURE' FROM DUAL UNION ALL
      SELECT 'CREATE TRIGGER' FROM DUAL UNION ALL
      SELECT 'CREATE SYNONYM' FROM DUAL UNION ALL
      SELECT 'CREATE MATERIALIZED VIEW' FROM DUAL UNION ALL
      SELECT 'DEBUG CONNECT SESSION' FROM DUAL UNION ALL
      SELECT 'SELECT_CATALOG_ROLE' FROM DUAL
    )
  ) LOOP
    BEGIN
      EXECUTE IMMEDIATE stmt.sql_cmd;
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro ao executar: ' || stmt.sql_cmd || ' - ' || SQLERRM);
    END;
  END LOOP;
END;
/

-- Ajuste de perfil e roles padrão
BEGIN
  EXECUTE IMMEDIATE 'ALTER USER SANKHYA DEFAULT ROLE ALL';
  EXECUTE IMMEDIATE 'ALTER PROFILE DEFAULT LIMIT FAILED_LOGIN_ATTEMPTS UNLIMITED';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro ao ajustar perfil do usuário: ' || SQLERRM);
END;
/

-- Desativar HTTP via XDB (segurança)
BEGIN
  DBMS_XDB.SETHTTPPORT(0);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Erro ao desativar HTTP: ' || SQLERRM);
END;
/

COMMIT;

SPOOL OFF;

PROMPT **********************************************
PROMPT * Script executado com sucesso!              *
PROMPT * Verifique o arquivo create_sankhya.log     *
PROMPT * Usuário: SANKHYA                           *
PROMPT * Senha: tecsis                              *
PROMPT **********************************************

