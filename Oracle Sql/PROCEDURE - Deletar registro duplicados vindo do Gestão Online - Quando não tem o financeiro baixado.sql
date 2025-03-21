create or replace PROCEDURE STP_SNK_DELDUPGESONLINE_SOL
AS
BEGIN
DECLARE
  P_NUNOTA INT;
  P_IDPEDINTEG VARCHAR(20);

CURSOR DUPLICADOS IS
SELECT
      MAX(IDG.NUNOTA), IDG.AD_IDPEDINTEG
FROM
    (
     SELECT
         T.NUNOTA, D.AD_IDPEDINTEG
       FROM
       (SELECT AD_IDPEDINTEG, COUNT(1) AS CONTADOR
          FROM TGFCAB
         WHERE AD_IDPEDINTEG IS NOT NULL
           AND AD_IDPEDINTEG <> 0
           AND DTNEG > '01/05/2021'
         GROUP BY AD_IDPEDINTEG
         HAVING COUNT(1) > 1
      ) D,

       (
        SELECT NUNOTA, AD_IDPEDINTEG
          FROM TGFCAB
         WHERE AD_IDPEDINTEG IS NOT NULL
           AND AD_IDPEDINTEG <> 0
           AND DTNEG > '01/05/2021'
        )T

      WHERE D.AD_IDPEDINTEG = T.AD_IDPEDINTEG

    ) IDG,

   (   SELECT NUNOTA
         FROM TGFFIN
        WHERE NUNOTA NOT IN ( SELECT NUNOTA
                                FROM TGFFIN
                               WHERE VLRBAIXA > 0
                                 AND DHBAIXA IS NOT NULL
                                 AND NUNOTA IS NOT NULL
                                 AND RECDESP = 1
                            GROUP BY NUNOTA)
    ) FIN
WHERE IDG.NUNOTA = FIN.NUNOTA
GROUP BY IDG.AD_IDPEDINTEG

UNION ALL

(
    SELECT NUNOTA, AD_IDPEDINTEG
      FROM TGFCAB
     WHERE AD_IDPEDINTEG IS NOT NULL
       AND AD_IDPEDINTEG <> 0
       AND DTNEG > '01/05/2021'
       AND NUNOTA NOT IN (SELECT NUNOTA FROM TGFITE)
);

BEGIN
   OPEN DUPLICADOS;
   LOOP
     FETCH DUPLICADOS INTO P_NUNOTA, P_IDPEDINTEG;

 IF STP_GET_ATUALIZANDO THEN RETURN; END IF;

 IF (NVL(P_NUNOTA,0)) > 0 THEN
  STP_SNK_REGLOG('STP_SNK_DELDUPGESONLINE_SOL:'||P_NUNOTA ||' - IDPEDINTEG '||P_IDPEDINTEG||' DUPLICADO');
 END IF;
 
 -- DELTA A CONTABILIZAÇÃO DA NOTA
 DELETE FROM TCBINT WHERE NUNICO =  P_NUNOTA;
 COMMIT;
 -- DELETA TGFREN
 DELETE FROM tgfren WHERE nufin IN ( SELECT nufin FROM tgffin WHERE nunota = P_NUNOTA );
 COMMIT;
 -- DELETA FIN
 DELETE FROM tgffin WHERE nunota = P_NUNOTA;
 COMMIT;
 -- DELETA CAB
 DELETE FROM tgfcab WHERE nunota = P_NUNOTA;
 COMMIT;
 -- DELETA TGFITE
 DELETE FROM tgfite WHERE nunota = P_NUNOTA;
 COMMIT;
  -- DELETA TGFITE
 DELETE FROM tgfnfse WHERE nunota = P_NUNOTA;
 COMMIT;

EXIT WHEN DUPLICADOS%NOTFOUND;
  END LOOP;
  CLOSE DUPLICADOS;
 END;
END;
