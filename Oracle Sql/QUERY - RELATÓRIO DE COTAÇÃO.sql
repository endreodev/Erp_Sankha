/************************
*                       *
*   QUERY PARA FILTROS  *
*                       *
*************************

/**************************
*    FILTRO - SITUAÇÃO    *
***************************/

SELECT 
 COT.SITUACAO AS VALUE,
CASE 
WHEN COT.SITUACAO = 'A' THEN 'ABERTA'
WHEN COT.SITUACAO = 'C' THEN 'CANCELADA'
WHEN COT.SITUACAO = 'E' THEN 'EM APROVAÇÃO'
WHEN COT.SITUACAO = 'F' THEN 'FECHADA'
WHEN COT.SITUACAO = 'P' THEN 'APROVADA' 
END AS LABEL
FROM TGFCOT COT
GROUP BY COT.SITUACAO
ORDER BY 2


/********************************
*    FILTRO - SITUAÇÃO ITENS    *
*********************************/

SELECT ITC.SITUACAO AS VALUE, 
(
CASE 
WHEN ITC.SITUACAO = 'A' THEN 'APROVADA'
WHEN ITC.SITUACAO = 'C' THEN 'RECUSADA'
WHEN ITC.SITUACAO = 'E' THEN 'ENVIADA'
WHEN ITC.SITUACAO = 'F' THEN 'FATURADA'
WHEN ITC.SITUACAO = 'G' THEN 'NEGOCIAR'
WHEN ITC.SITUACAO = 'N' THEN 'REPROVADA'
WHEN ITC.SITUACAO = 'P' THEN 'PENDENTE'
WHEN ITC.SITUACAO = 'R' THEN 'RESPONDIDA'
END
) AS LABEL
FROM TGFITC ITC
GROUP BY ITC.SITUACAO
ORDER BY 1


/***************************
*    FILTRO - COMPRADOR    *
****************************/

SELECT COT.CODUSUREQ AS VALUE,
       USU.NOMEUSU AS LABEL 
FROM TGFCOT COT, 
     TSIUSU USU
WHERE USU.CODUSU = COT.CODUSUREQ
GROUP BY COT.CODUSUREQ, USU.NOMEUSU
ORDER BY USU.NOMEUSU



/*********************************
*                                *
*   QUERY PARA TELA PRINCIPAL    *
*                                *
**********************************/

/********************************
*   GRÁFICO - PIZZA PRINCIPAL   *
*********************************/
--  VALOR GASTOS, PERCENTUAL DO COMPRADOR

SELECT C_COMPRADOR,
       COMPRADOR,
       VLRGASTO
FROM (
SELECT COT.CODUSUREQ AS C_COMPRADOR,
       NVL((SELECT TSIUSU.NOMEUSU FROM TSIUSU WHERE TSIUSU.CODUSU = COT.CODUSUREQ),'Sem Comprador') AS COMPRADOR,
       SUM((ITC.PRECO * ITC.QTDCOTADA) + ITC.FRETE) AS VLRGASTO
FROM TGFCOT COT, TGFITC ITC
WHERE COT.NUMCOTACAO = ITC.NUMCOTACAO
  AND TRUNC(COT.DHINIC,'DD') >= :PERIODO.INI
  AND TRUNC(COT.DHINIC,'DD') <= :PERIODO.FIN
  AND COT.SITUACAO IN :SITUACAO
  AND COT.CODUSUREQ IN :CODCOMP 
  AND ((COT.NUMCOTACAO = :NUMCOTACAO) OR (:NUMCOTACAO IS NULL))
  AND ITC.SITUACAO  IN :S_ITEM
GROUP BY COT.CODUSUREQ ) GRAFPIZZA
GROUP BY C_COMPRADOR, COMPRADOR, VLRGASTO

/*********************************
*   GRÁFICO - COLUNA PRINCIPAL   *
**********************************/
-- QUANTIDADE DE COTAÇÕES REALIZADAS PELO O COMPRADOR

SELECT COMPRADOR,
       QTCOT,
       C_COMPRADOR
FROM  (
SELECT NVL((SELECT TSIUSU.NOMEUSU FROM TSIUSU WHERE TSIUSU.CODUSU = COT.CODUSUREQ),'Sem Comprador') AS COMPRADOR,
       COUNT(1) AS QTCOT,
       COT.CODUSUREQ AS C_COMPRADOR,
      (SELECT COUNT(1) 
        FROM TGFCOT QT 
    WHERE TRUNC(QT.DHINIC,'DD') >= :PERIODO.INI 
         AND TRUNC(QT.DHINIC,'DD')<= :PERIODO.FIN 
         AND QT.SITUACAO IN :SITUACAO) AS QTCOTTOT,
      (SELECT SUM((ITC.PRECO * ITC.QTDCOTADA) + ITC.FRETE) AS TOTAL 
         FROM TGFCOT COT, TGFITC ITC 
         WHERE COT.NUMCOTACAO = ITC.NUMCOTACAO
          AND TRUNC(COT.DHINIC,'DD') >= :PERIODO.INI 
          AND TRUNC(COT.DHINIC,'DD') <= :PERIODO.FIN AND COT.SITUACAO IN :SITUACAO) AS VLRTOT
FROM TGFCOT COT
WHERE TRUNC(COT.DHINIC,'DD') >= :PERIODO.INI
  AND TRUNC(COT.DHINIC,'DD') <= :PERIODO.FIN
  AND COT.SITUACAO  IN :SITUACAO
  AND COT.CODUSUREQ IN :CODCOMP 
  AND ((COT.NUMCOTACAO = :NUMCOTACAO) OR (:NUMCOTACAO IS NULL))
GROUP BY COT.CODUSUREQ 
    ) PERCOT
GROUP BY COMPRADOR,
         QTCOT,
         C_COMPRADOR
ORDER BY 2 DESC

/*********************************
*   GRÁFICO - TABELA PRINCIPAL   *
**********************************/
-- DETALHES DA COTAÇÃO REALIZADAS -> CABEÇALHO
SELECT
COT.NUNOTAORIG,
COT.NUMCOTACAO,
EMP.CODEMP,
EMP.NOMEFANTASIA,
COT.CODCENCUS || '-' || CUS.DESCRCENCUS as C_RESULTADO,
COT.DHINIC ,
NVL(SUM((ITC.PRECO * ITC.QTDCOTADA) + ITC.FRETE),0) AS VLRTOTCOT,
(
CASE 
WHEN COT.SITUACAO = 'A' THEN 'ABERTA'
WHEN COT.SITUACAO = 'C' THEN 'CANCELADA'
WHEN COT.SITUACAO = 'E' THEN 'EM APROVAÇÃO'
WHEN COT.SITUACAO = 'F' THEN 'FECHADA'
WHEN COT.SITUACAO = 'P' THEN 'APROVADA'
END
) AS SITUACAO,
(SELECT TSIUSU.NOMEUSU FROM TSIUSU WHERE TSIUSU.CODUSU = COT.CODUSUREQ) AS COMPRADOR

FROM TGFCOT COT 
INNER JOIN TSIEMP EMP ON COT.CODEMP     = EMP.CODEMP
INNER JOIN TSICUS CUS ON COT.CODCENCUS  = CUS.CODCENCUS
LEFT JOIN  TGFITC ITC ON COT.NUMCOTACAO = ITC.NUMCOTACAO
                      AND ITC.SITUACAO IN ('F', 'A')
                      AND COT.SITUACAO IN ('F')
WHERE 
    TRUNC(COT.DHINIC,'DD') >= :PERIODO.INI
AND TRUNC(COT.DHINIC,'DD') <= :PERIODO.FIN
AND ((COT.NUMCOTACAO = :NUMCOTACAO) OR (:NUMCOTACAO IS NULL))
AND COT.SITUACAO  IN :SITUACAO
AND ITC.SITUACAO  IN :S_ITEM
AND COT.CODUSUREQ IN :CODCOMP 
GROUP BY 
COT.NUNOTAORIG,
COT.NUMCOTACAO,
EMP.CODEMP,
EMP.NOMEFANTASIA,
COT.CODCENCUS || '-' || CUS.DESCRCENCUS,
COT.DHINIC, COT.CODUSUREQ,
(CASE WHEN COT.SITUACAO = 'A' THEN 'ABERTA' WHEN COT.SITUACAO = 'C' THEN 'CANCELADA'
WHEN COT.SITUACAO = 'E' THEN 'EM APROVAÇÃO' WHEN COT.SITUACAO = 'F' THEN 'FECHADA'
WHEN COT.SITUACAO = 'P' THEN 'APROVADA' END )
ORDER BY COT.DHINIC


/*******************************************************
*                                                      *
*   QUERY PARA TELA SUB NÍVEL DA PRINCIPAL COMPRADOR   *
*                                                      *
********************************************************/

/*********************************************
*   1° GRÁFICO - BARRA SUB NÍVEL COMPRADOR   *
**********************************************/
-- COTAÇÕES AGRUPADAS PELA SITUAÇÃO DAS PROPOSTAS
SELECT (CASE 
        WHEN ITC.SITUACAO = 'A' THEN 'APROVADA'
        WHEN ITC.SITUACAO = 'C' THEN 'RECUSADA'
        WHEN ITC.SITUACAO = 'E' THEN 'ENVIADA'
        WHEN ITC.SITUACAO = 'F' THEN 'FATURADA'
        WHEN ITC.SITUACAO = 'G' THEN 'NEGOCIAR'
        WHEN ITC.SITUACAO = 'N' THEN 'REPROVADA'
        WHEN ITC.SITUACAO = 'P' THEN 'PENDENTE'
        WHEN ITC.SITUACAO = 'R' THEN 'RESPONDIDA'
END ) AS SITUACAO,
       NVL(SUM((ITC.PRECO * ITC.QTDCOTADA) + ITC.FRETE),0) AS TOTAL, COT.CODUSUREQ as C_COMPRADOR
FROM TGFCOT COT, 
     TGFITC ITC
WHERE COT.NUMCOTACAO = ITC.NUMCOTACAO
AND TRUNC(COT.DHINIC,'DD') >= :PERIODO.INI
AND TRUNC(COT.DHINIC,'DD') <= :PERIODO.FIN
AND ((COT.NUMCOTACAO = :NUMCOTACAO) OR (:NUMCOTACAO IS NULL))
AND COT.SITUACAO  IN :SITUACAO
AND ITC.SITUACAO  IN :S_ITEM
AND COT.CODUSUREQ = :C_COMPRADOR
GROUP BY COT.CODUSUREQ, (CASE WHEN ITC.SITUACAO = 'A' THEN 'APROVADA' WHEN ITC.SITUACAO = 'C' THEN 'RECUSADA' WHEN ITC.SITUACAO = 'E' THEN 'ENVIADA' WHEN ITC.SITUACAO = 'F' THEN 'FATURADA' WHEN ITC.SITUACAO = 'G' THEN 'NEGOCIAR' WHEN ITC.SITUACAO = 'N' THEN 'REPROVADA' WHEN ITC.SITUACAO = 'P' THEN 'PENDENTE' WHEN ITC.SITUACAO = 'R' THEN 'RESPONDIDA' END )
ORDER BY 2 DESC


/*********************************************
*   2° GRÁFICO - BARRA SUB NÍVEL COMPRADOR   *
**********************************************/
-- COTAÇÕES AGRUPADAS PELA A NATUREZA DO LANÇAMENTO DAS PROPOSTAS

  SELECT (SELECT DESCRNAT FROM TGFNAT WHERE CODNAT = COT.CODNAT) AS NATUREZA,
        NVL(SUM((ITC.PRECO * ITC.QTDCOTADA) + ITC.FRETE),0) AS TOTAL
   FROM TGFCOT COT, TGFITC ITC
   WHERE COT.NUMCOTACAO = ITC.NUMCOTACAO
     AND TRUNC(COT.DHINIC,'DD') >= :PERIODO.INI
     AND TRUNC(COT.DHINIC,'DD') <= :PERIODO.FIN
     AND ((COT.NUMCOTACAO = :NUMCOTACAO) OR (:NUMCOTACAO IS NULL))
     AND COT.SITUACAO  IN :SITUACAO
     AND ITC.SITUACAO  IN :S_ITEM
     AND COT.CODUSUREQ = :C_COMPRADOR
     GROUP BY COT.CODNAT
     ORDER BY 2 DESC


/********************************************************
*                                                       *
*   QUERY PARA TELA SUB NÍVEL DA PRINCIPAL qUANTIDADE   *
*                                                       *
*********************************************************/

/*********************************************
*   1° GRÁFICO - BARRA SUB NÍVEL QUANTIDADE  *
**********************************************/
-- RANKING DE FORNECEDORES PELO A QUANTIDADE DE ITENS

SELECT ITC.CODPARC, 
       (SELECT PAR.NOMEPARC FROM TGFPAR PAR WHERE PAR.CODPARC = ITC.CODPARC) AS FORNECEDOR,
       COUNT(*) AS QTITEM
FROM TGFCOT COT, TGFITC ITC
WHERE COT.NUMCOTACAO = ITC.NUMCOTACAO
AND TRUNC(COT.DHINIC,'DD') >= :PERIODO.INI
AND TRUNC(COT.DHINIC,'DD') <= :PERIODO.FIN
AND ((COT.NUMCOTACAO = :NUMCOTACAO) OR (:NUMCOTACAO IS NULL))
AND COT.SITUACAO IN :SITUACAO 
AND COT.CODUSUREQ = :C_COMPRADOR
GROUP BY ITC.CODPARC
ORDER BY 3 DESC


/************************************************************
*                                                           *
*   QUERY PARA TELA SUB NÍVEL DA PRINCIPAL TABELA COTAÇÃO   *
*                                                           *
*************************************************************/

/*****************************************
*   1° TABELA - BARRA SUB NÍVEL COTAÇÃO  *
******************************************/
-- PROSPOSTAS DA COTAÇÃO SELECIONADA

SELECT 
NVL(ITC.NUNOTACPA ,0) AS NUNOTA,
COT.NUMCOTACAO, 
ITC.TIPOCOLPRECO,
ITC.CODPROD,
PROD.DESCRPROD,
ITC.QTDCOTADA,
ITC.CODVOL,
ITC.CODPARC, 
PAR.NOMEPARC,
ITC.PRECO,
SUM((ITC.PRECO * ITC.QTDCOTADA) + ITC.FRETE) AS TOTAL,

(
CASE 
WHEN ITC.SITUACAO = 'A' THEN 'APROVADA'
WHEN ITC.SITUACAO = 'C' THEN 'RECUSADA'
WHEN ITC.SITUACAO = 'E' THEN 'ENVIADA'
WHEN ITC.SITUACAO = 'F' THEN 'FATURADA'
WHEN ITC.SITUACAO = 'G' THEN 'NEGOCIAR'
WHEN ITC.SITUACAO = 'N' THEN 'REPROVADA'
WHEN ITC.SITUACAO = 'P' THEN 'PENDENTE'
WHEN ITC.SITUACAO = 'R' THEN 'RESPONDIDA'
END
) AS SITUACAO,

NVL(PSG.PERCENTUAL,0) AS PERCENTUAL

FROM 
TGFCOT COT INNER JOIN TGFITC ITC
ON COT.NUMCOTACAO = ITC.NUMCOTACAO

INNER JOIN TGFPRO PROD 
ON ITC.CODPROD =  PROD.CODPROD

INNER JOIN TGFPAR PAR 
ON ITC.CODPARC = PAR.CODPARC

LEFT JOIN (SELECT  PESO.CODPROD,
        PESO.NUMCOTACAO,
        MIN(PESO.SITUACAO) AS SITUACAO,
        ROUND(100 * ROUND((SUM((PESO.VLRTOTALPROD * PESO.INDICE))/SUM(PESO.INDICE)) - (MIN(PESO.VLRTOTALPROD)),2)/MIN(PESO.VLRTOTALPROD),2) AS PERCENTUAL
  FROM ( SELECT PES.CODPROD,
                PES.SITUACAO,
                PES.NUMCOTACAO,
                PES.PRECO,
                PES.QTDCOTADA,
               (PES.PRECO * PES.QTDCOTADA) AS VLRTOTALPROD,
                RANK() OVER( partition by PES.NUMCOTACAO ORDER BY PRECO ASC) AS INDICE
           FROM  TGFITC PES
          WHERE  PES.PRECO > 0
         ) PESO
GROUP BY PESO.CODPROD,
        PESO.NUMCOTACAO) PSG ON PSG.CODPROD = ITC.CODPROD
                            AND PSG.NUMCOTACAO = ITC.NUMCOTACAO
                            AND PSG.SITUACAO = ITC.SITUACAO

WHERE ITC.NUMCOTACAO IN :COTACAO

GROUP BY
NVL(ITC.NUNOTACPA ,0), COT.NUMCOTACAO, ITC.TIPOCOLPRECO, ITC.CODPROD, PROD.DESCRPROD, 
ITC.QTDCOTADA, ITC.CODVOL, ITC.CODPARC, PAR.NOMEPARC, ITC.PRECO, PSG.PERCENTUAL, 
( CASE WHEN ITC.SITUACAO = 'A' THEN 'APROVADA' WHEN ITC.SITUACAO = 'C' THEN 'RECUSADA' WHEN ITC.SITUACAO = 'E' THEN 'ENVIADA' WHEN ITC.SITUACAO = 'F' THEN 'FATURADA' WHEN ITC.SITUACAO = 'G' THEN 'NEGOCIAR' WHEN ITC.SITUACAO = 'N' THEN 'REPROVADA' WHEN ITC.SITUACAO = 'P' THEN 'PENDENTE' WHEN ITC.SITUACAO = 'R' THEN 'RESPONDIDA' END )

/******************************************************************
*                                                                 *
*   QUERY PARA TELA DO SEGUNDO SUB NÍVEL DO GRÁFICO DE SITUAÇÕES  *
*                                                                 *
*******************************************************************/

/***********************************************
*   1° TABELA - BARRA SUB NÍVEL DAS SITUAÇÕES  *
************************************************/
-- RESUMO DOS GANHOS QUE O COMPRADOR GEROU PARA EMPRESA

  SELECT  TOT.C_COMPRADOR,
         NVL((SELECT TSIUSU.NOMEUSU FROM TSIUSU WHERE TSIUSU.CODUSU = TOT.C_COMPRADOR),'Sem Comprador') AS COMPRADOR,
         TOT.VLRTOT,
         APROV.VLRAPROV,
         QTCOT.QTCOTCOMP,
         ROUND(TOT.VLRTOT / QTCOT.QTCOTCOMP,2) AS VLR_MEDIA,
         ROUND(VLRAPROV - (TOT.VLRTOT / QTCOT.QTCOTCOMP),2) AS GANHO,
         100 - ROUND(((VLRAPROV - (TOT.VLRTOT / QTCOT.QTCOTCOMP)) / APROV.VLRAPROV)*100,2) AS PERC         
 FROM 
 ( 
  SELECT COT.CODUSUREQ AS C_COMPRADOR,
        NVL(SUM((ITC.PRECO * ITC.QTDCOTADA) + ITC.FRETE),0) AS VLRTOT
   FROM TGFCOT COT, TGFITC ITC
   WHERE COT.NUMCOTACAO = ITC.NUMCOTACAO
     AND TRUNC(COT.DHINIC,'DD') >= :PERIODO.INI
     AND TRUNC(COT.DHINIC,'DD') <= :PERIODO.FIN
     AND COT.CODUSUREQ IN :C_COMPRADOR
     AND ((COT.NUMCOTACAO = :NUMCOTACAO) OR (:NUMCOTACAO IS NULL))
     AND COT.SITUACAO NOT IN ('C')
    GROUP BY COT.CODUSUREQ
  ) TOT ,
(
  SELECT COT.CODUSUREQ AS C_COMPRADOR,
        NVL(SUM((ITC.PRECO * ITC.QTDCOTADA) + ITC.FRETE),0) AS VLRAPROV
   FROM TGFCOT COT, TGFITC ITC
   WHERE COT.NUMCOTACAO = ITC.NUMCOTACAO
     AND TRUNC(COT.DHINIC,'DD') >= :PERIODO.INI
     AND TRUNC(COT.DHINIC,'DD') <= :PERIODO.FIN
     AND COT.CODUSUREQ IN :C_COMPRADOR
     AND ((COT.NUMCOTACAO = :NUMCOTACAO) OR (:NUMCOTACAO IS NULL))
     AND COT.SITUACAO IN ('F', 'P')
     AND ITC.SITUACAO IN ('A')
GROUP BY COT.CODUSUREQ 
) APROV,
(
SELECT COT.CODUSUREQ AS C_COMPRADOR, 
        COUNT(*) AS QTCOTCOMP
FROM TGFCOT COT, TGFITC ITC
WHERE COT.NUMCOTACAO = ITC.NUMCOTACAO
  AND TRUNC(COT.DHINIC,'DD') >= :PERIODO.INI
  AND TRUNC(COT.DHINIC,'DD') <= :PERIODO.FIN
  AND ((COT.NUMCOTACAO = :NUMCOTACAO) OR (:NUMCOTACAO IS NULL))
  AND COT.CODUSUREQ IN :C_COMPRADOR
  AND COT.SITUACAO <> 'C'
GROUP BY COT.CODUSUREQ

) QTCOT

WHERE TOT.C_COMPRADOR = APROV.C_COMPRADOR
  AND TOT.C_COMPRADOR = QTCOT.C_COMPRADOR
  AND APROV.C_COMPRADOR = QTCOT.C_COMPRADOR
