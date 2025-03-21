CREATE OR REPLACE VIEW VGFFIN AS
SELECT
  DECODE (TIPJURO, '1', 0, VLRJURO) AS VLRJUROEXTRA,
  DECODE (TIPMULTA, '1', 0, VLRMULTA) AS VLRMULTAEXTRA,
  DECODE (ISSRETIDO, 'S', 0, VLRISS) AS VLRISSEXTRA,
  NVL((SELECT SUM(VALOR) FROM TGFIMF WHERE TGFIMF.NUFIN = TGFFIN.NUFIN AND TIPIMP = 0),0) AS OUTROSIMPOSTOSEXTRA,
  DECODE (TIPJURO, '1', VLRJURO, 0) AS VLRJUROINC,
  DECODE (TIPMULTA, '1', VLRMULTA, 0) AS VLRMULTAINC,
  DECODE (ISSRETIDO, 'S', VLRISS, 0) AS VLRISSINC,
  NVL((SELECT SUM(VALOR) FROM TGFIMF WHERE TGFIMF.NUFIN = TGFFIN.NUFIN AND TIPIMP = -1),0) AS OUTROSIMPOSTOSINC,
  CAST(DECODE (DHBAIXA, NULL,
  VLRDESDOB
  + CASE WHEN TIPJURO = 1 AND VLRJURO <> 0 AND NVL((SELECT INTEIRO FROM TSIPAR WHERE CHAVE = 'CVL-JUROS' AND CODUSU = 0),0) <> 0 THEN VLRJURO ELSE 0 END
  + CASE WHEN TIPMULTA = 1 AND VLRMULTA <> 0 AND NVL((SELECT INTEIRO FROM TSIPAR WHERE CHAVE = 'CVL-MULTA' AND CODUSU = 0),0) <> 0 THEN VLRMULTA ELSE 0 END
  + CASE WHEN VLRVENDOR <> 0 AND NVL((SELECT INTEIRO FROM TSIPAR WHERE CHAVE = 'CVL-VENDOR' AND CODUSU = 0),0) <> 0 THEN VLRVENDOR ELSE 0 END
  + CASE WHEN DESPCART <> 0 AND NVL((SELECT INTEIRO FROM TSIPAR WHERE CHAVE = 'CVL-DESPCART' AND CODUSU = 0),0) <> 0 THEN DESPCART ELSE 0 END
  - CASE WHEN VLRDESC <> 0 AND NVL((SELECT INTEIRO FROM TSIPAR WHERE CHAVE = 'CVL-DESCONTO' AND CODUSU = 0),0) <> 0 THEN VLRDESC ELSE 0 END
  - CASE WHEN CARTAODESC <> 0 AND NVL((SELECT INTEIRO FROM TSIPAR WHERE CHAVE = 'CVL-TAXAADM' AND CODUSU = 0),0) <> 0 THEN CARTAODESC ELSE 0 END
  - CASE WHEN ISSRETIDO = 'S' AND VLRISS <> 0 AND NVL((SELECT INTEIRO FROM TSIPAR WHERE CHAVE = 'CVL-ISS' AND CODUSU = 0),0) <> 0 THEN VLRISS ELSE 0 END
  - CASE WHEN IRFRETIDO = 'S' AND VLRIRF <> 0 AND NVL((SELECT INTEIRO FROM TSIPAR WHERE CHAVE = 'CVL-IRF' AND CODUSU = 0),0) <> 0 THEN VLRIRF ELSE 0 END
  - CASE WHEN INSSRETIDO = 'S' AND VLRINSS <> 0 AND NVL((SELECT INTEIRO FROM TSIPAR WHERE CHAVE = 'CVL-INSS' AND CODUSU = 0),0) <> 0 THEN VLRINSS ELSE 0 END
  + NVL(VLRVARCAMBIAL,0)
  + NVL(VLRMULTANEGOC,0)
  + NVL(VLRJURONEGOC,0)
  - NVL(VLRMULTALIB,0)
  - NVL(VLRJUROLIB,0)
  + NVL((SELECT SUM(VALOR * TIPIMP) FROM TGFIMF WHERE TGFIMF.NUFIN = TGFFIN.NUFIN),0), VLRBAIXA) AS FLOAT) AS VLRLIQUIDO
  , TGFFIN.VLRDESDOB / CASE WHEN TGFFIN.CODMOEDA = 0 THEN 1 WHEN TGFFIN.VLRMOEDA <> 0 THEN TGFFIN.VLRMOEDA ELSE NVL((SELECT COTACAO FROM TSICOT WHERE CODMOEDA = TGFFIN.CODMOEDA AND DTMOV = (SELECT MAX(C2.DTMOV) FROM TSICOT C2 WHERE C2.CODMOEDA = TGFFIN.CODMOEDA AND C2.DTMOV <= TGFFIN.DTNEG)),1) END
  * CASE WHEN TGFFIN.CODMOEDA = 0 THEN 1 WHEN TGFFIN.VLRMOEDABAIXA <> 0 THEN TGFFIN.VLRMOEDABAIXA ELSE NVL((SELECT COTACAO FROM TSICOT WHERE CODMOEDA = TGFFIN.CODMOEDA AND DTMOV = (SELECT MAX(C2.DTMOV) FROM TSICOT C2 WHERE C2.CODMOEDA = TGFFIN.CODMOEDA AND C2.DTMOV <= TGFFIN.DTVENC)),1) END AS VLRATUALIZADO
  , TGFFIN.VLRDESDOB / CASE WHEN TGFFIN.CODMOEDA = 0 THEN 1 WHEN TGFFIN.VLRMOEDA <> 0 THEN TGFFIN.VLRMOEDA ELSE NVL((SELECT COTACAO FROM TSICOT WHERE CODMOEDA = TGFFIN.CODMOEDA AND DTMOV = (SELECT MAX(C2.DTMOV) FROM TSICOT C2 WHERE C2.CODMOEDA = TGFFIN.CODMOEDA AND C2.DTMOV <= TGFFIN.DTNEG)),1) END AS VLREMMOEDA
  , CASE WHEN TGFFIN.CODMOEDA = 0 THEN 1 WHEN TGFFIN.VLRMOEDA <> 0 THEN TGFFIN.VLRMOEDA ELSE NVL((SELECT COTACAO FROM TSICOT WHERE CODMOEDA = TGFFIN.CODMOEDA AND DTMOV = (SELECT MAX(C2.DTMOV) FROM TSICOT C2 WHERE C2.CODMOEDA = TGFFIN.CODMOEDA AND C2.DTMOV <= TGFFIN.DTNEG)),1) END VLRMOEDANEG
  , CASE WHEN TGFFIN.CODMOEDA = 0 THEN 1 WHEN TGFFIN.VLRMOEDABAIXA <> 0 THEN TGFFIN.VLRMOEDABAIXA ELSE NVL((SELECT COTACAO FROM TSICOT WHERE CODMOEDA = TGFFIN.CODMOEDA AND DTMOV = (SELECT MAX(C2.DTMOV) FROM TSICOT C2 WHERE C2.CODMOEDA = TGFFIN.CODMOEDA AND C2.DTMOV <= TGFFIN.DTVENC)),1) END AS VLRMOEDAVENC
  , ((TGFFIN.VLRBAIXA +
       CASE WHEN TGFFIN.NUNOTA IS NULL THEN 0
            ELSE (SELECT ROUND((CASE WHEN CAB.ISSRETIDO = 'S' THEN CAB.VLRISS ELSE 0 END +
                          CAB.VLRIRF +
                          CASE WHEN CAB.IRFRETIDO = 'S' THEN CAB.VLRINSS ELSE 0 END +
                          NVL((SELECT SUM(IMN.VALOR) FROM TGFIMN IMN
                               WHERE IMN.NUNOTA = TGFFIN.NUNOTA AND IMN.TIPIMP = -1),0)
                         ) * TGFFIN.VLRDESDOB / CAB.VLRNOTA,2)
                  FROM TGFCAB CAB
                  WHERE CAB.NUNOTA = TGFFIN.NUNOTA) +
                 NVL((SELECT SUM(IMF.VALOR) FROM TGFIMF IMF
                      WHERE IMF.NUFIN = TGFFIN.NUFIN AND IMF.TIPIMP = -1),0)
            END) * TGFFIN.RECDESP)
  AS VLRBAIXACOMIMP
  , ((CASE WHEN TGFFIN.NUNOTA IS NULL THEN 0
            ELSE (SELECT ROUND((CASE WHEN CAB.ISSRETIDO = 'S' THEN CAB.VLRISS ELSE 0 END +
                          CAB.VLRIRF +
                          CASE WHEN CAB.IRFRETIDO = 'S' THEN CAB.VLRINSS ELSE 0 END +
                          NVL((SELECT SUM(IMN.VALOR) FROM TGFIMN IMN
                               WHERE IMN.NUNOTA = TGFFIN.NUNOTA AND IMN.TIPIMP = -1),0)
                         ) * TGFFIN.VLRDESDOB / CAB.VLRNOTA,2)
                  FROM TGFCAB CAB
                  WHERE CAB.NUNOTA = TGFFIN.NUNOTA) +
                 NVL((SELECT SUM(IMF.VALOR) FROM TGFIMF IMF
                      WHERE IMF.NUFIN = TGFFIN.NUFIN AND IMF.TIPIMP = -1),0)
            END) * TGFFIN.RECDESP)
  AS IMPNOTA
  ,TGFFIN."NUFIN",TGFFIN."CODEMP",TGFFIN."NUMNOTA",TGFFIN."SERIENOTA",TGFFIN."DTNEG",TGFFIN."DESDOBRAMENTO",TGFFIN."DHMOV",TGFFIN."DTVENCINIC",TGFFIN."DTVENC",TGFFIN."DHBAIXA",TGFFIN."DTCONTAB",TGFFIN."DTCONTABBAIXA",TGFFIN."CODPARC",TGFFIN."CODTIPOPER",TGFFIN."DHTIPOPER",TGFFIN."CODBCO",TGFFIN."CODCTABCOINT",TGFFIN."CODNAT",TGFFIN."CODCENCUS",TGFFIN."CODPROJ",TGFFIN."CODVEND",TGFFIN."CODMOEDA",TGFFIN."CODTIPTIT",TGFFIN."NUMDUPL",TGFFIN."DESDOBDUPL",TGFFIN."NOSSONUM",TGFFIN."HISTORICO",TGFFIN."VLRDESDOB",TGFFIN."VLRVENDOR",TGFFIN."VLRIRF",TGFFIN."VLRISS",TGFFIN."VLRCHEQUE",TGFFIN."DESPCART",TGFFIN."ISSRETIDO",TGFFIN."VLRDESC",TGFFIN."VLRMULTA",TGFFIN."VLRINSS",TGFFIN."TIPMULTA",TGFFIN."VLRJURO",TGFFIN."TIPJURO",TGFFIN."BASEICMS",TGFFIN."ALIQICMS",TGFFIN."CODEMPBAIXA",TGFFIN."CODTIPOPERBAIXA",TGFFIN."DHTIPOPERBAIXA",TGFFIN."VLRBAIXA",TGFFIN."NUMREMESSA",TGFFIN."AUTORIZADO",TGFFIN."RECDESP",TGFFIN."PROVISAO",TGFFIN."ORIGEM",TGFFIN."TIPMARCCHEQ",TGFFIN."NUNOTA",TGFFIN."NUBCO",TGFFIN."NUDEV",TGFFIN."NURENEG",TGFFIN."CARTA",TGFFIN."RATEADO",TGFFIN."DTENTSAI",TGFFIN."CODUSUBAIXA",TGFFIN."VLRPROV",TGFFIN."IRFRETIDO",TGFFIN."INSSRETIDO",TGFFIN."CARTAODESC",TGFFIN."DTALTER",TGFFIN."NUMCONTRATO",TGFFIN."ORDEMCARGA",TGFFIN."CODVEICULO",TGFFIN."CODBARRA",TGFFIN."CODUSU",TGFFIN."SEQUENCIA",TGFFIN."VLRVARCAMBIAL",TGFFIN."CODIGOBARRA",TGFFIN."LINHADIGITAVEL",TGFFIN."VLRDESCEMBUT",TGFFIN."VLRJUROEMBUT",TGFFIN."VLRMULTAEMBUT",TGFFIN."VLRMOEDA",TGFFIN."VLRMOEDABAIXA",TGFFIN."NUCOMPENS",TGFFIN."CODCFO",TGFFIN."VLRMULTANEGOC",TGFFIN."VLRJURONEGOC",TGFFIN."VLRMULTALIB",TGFFIN."VLRJUROLIB",TGFFIN."DTBAIXAPREV",TGFFIN."NUMOS",TGFFIN."NATUREZAOPERDES",TGFFIN."SERIENFDES",TGFFIN."MODELONFDES",TGFFIN."CODFUNC",TGFFIN."CODCONTATO",TGFFIN."NUAPONTA",TGFFIN."NUMBOR",TGFFIN."M2",TGFFIN."DIGSAFRA",TGFFIN."NFENTSEQFIX",TGFFIN."NFCOMPLFIX",TGFFIN."CODPARCRESP",TGFFIN."PDD",TGFFIN."CODUSUCOBR",TGFFIN."NUIMP",TGFFIN."NUMNFSE",TGFFIN."VLRALIBERAR",TGFFIN."CONVENIO",TGFFIN."CHAVECTE",TGFFIN."CHAVECTEREF",TGFFIN."NOMEEMITENTE_CMC7",TGFFIN."CODRATEIO",TGFFIN."VLRCESSAO",TGFFIN."IDLOTEFDIC",TGFFIN."NRODOCTEF",TGFFIN."NUPED",TGFFIN."CODBCO_CMC7",TGFFIN."AGENCIA_CMC7",TGFFIN."CONTA_CMC7",TGFFIN."CGC_CPF_CMC7",TGFFIN."CODCC",TGFFIN."VLRFATCARTAO",TGFFIN."NUCCR",TGFFIN."AD_PRIORIDADE",TGFFIN."AD_PERCJURO",TGFFIN."AD_PERCMULTA",TGFFIN."AD_TIPOPROTESTO",TGFFIN."AD_DIASPROTESTO",TGFFIN."NUFTC",TGFFIN."PARCRENEG",TGFFIN."SITESPECIALRESP",TGFFIN."EXIGEISSQN",TGFFIN."REGESPTRIBUT",TGFFIN."MOTNAORETERISSQN",TGFFIN."AD_PARCEIRO",TGFFIN."NROLOTEGNRE",TGFFIN."STATUSGNRE",TGFFIN."REJEICAOGNRE",TGFFIN."CODCARTAO",TGFFIN."TPAGNFCE",TGFFIN."VALORPRESENTE",TGFFIN."JUROSAVP",TGFFIN."BLOQVAR",TGFFIN."VLRFRETENFS",TGFFIN."VLRDESCCALC",TGFFIN."NSUECONECT",TGFFIN."VLRHONOR",TGFFIN."BASEIRF",TGFFIN."BASEINSS",TGFFIN."MONIOCOREM",TGFFIN."AD_NUFINCCW",TGFFIN."DTPRAZO",TGFFIN."AD_NUFINTXADM",TGFFIN."AD_STATUSCORRECAO",TGFFIN."AD_TEMPROVISAO",TGFFIN."VLRTROCOECONECT",TGFFIN."TIPOTROCOECONECT",TGFFIN."RECEBCARTAO",TGFFIN."ABATIMENTO",TGFFIN."ABATIMENTOCAN",TGFFIN."VLRDESCSSPMB",TGFFIN."AD_TXJUROCOBX",TGFFIN."AD_TXMULTACOBX",TGFFIN."AD_TIPOPROTCOBX",TGFFIN."AD_TIPODESCCOBX",TGFFIN."AD_DIASPROTCOBX",TGFFIN."AD_DIASMULTACOBX",TGFFIN."AD_DIASBAIXACOBX",TGFFIN."AD_DTLIMDESCCOBX",TGFFIN."AD_NOSSONUMCOBX",TGFFIN."AD_STATUSCOBX",TGFFIN."AD_ESPECIECOBX",TGFFIN."AD_ATUALIZABOLCOBX",TGFFIN."TIPOABATSSPMB",TGFFIN."CODCBE",TGFFIN."AD_CODVEICULO",TGFFIN."DESPADVOGADO",TGFFIN."CUSTASPROCESSUAIS",TGFFIN."DEPOSITOJUDICIAL",TGFFIN."NUMPROCADMJUDIC",TGFFIN."OBRACONSTCIVIL",TGFFIN."CLASSIFCESSAOOBRA",TGFFIN."CODLST",TGFFIN."CODCIDINICTE",TGFFIN."CODCIDFIMCTE",TGFFIN."CODTRIB",TGFFIN."AD_NUMNSUCCW",TGFFIN."CODOBRA",TGFFIN."AD_TIPCONTAPARC",TGFFIN."AD_CODBCOPARC",TGFFIN."AD_AGENCIAPARC",TGFFIN."AD_CONTAPARC",TGFFIN."AD_CGCCPFSOCIO",TGFFIN."AD_NOMESOCIO",TGFFIN."CHEQUERASTREADO_CMC7",TGFFIN."NUCHQ",TGFFIN."AD_SEQGATEWAY",TGFFIN."AD_FLAGAPLICATIVO",TGFFIN."CODREGUA",TGFFIN."IDUNICO",TGFFIN."SEQCAIXA",TGFFIN."AD_AUTENTICAPGTO",TGFFIN."AD_IDPROVISAOFIN",TGFFIN."TIMPARCELA",TGFFIN."TIMCONTRATOLOC",TGFFIN."TIMNEGOCIACAO",TGFFIN."TIMDTIMPBOL",TGFFIN."TIMDTREPASSE",TGFFIN."TIMDHBAIXA",TGFFIN."TIMDATADEJUR",TGFFIN."TIMNUMREG",TGFFIN."TIMORIGEM",TGFFIN."TIMNUFINORIG",TGFFIN."TIMVENDAIMV",TGFFIN."TIMRENEGIMV",TGFFIN."TIMVENDALOTE",TGFFIN."TIMRENEGLOTE",TGFFIN."TIMSAC",TGFFIN."TIMNOMEADVOGADO",TGFFIN."TIMDHGERREPASSE",TGFFIN."TIMCONTAREP",TGFFIN."TIMIMOVEL",TGFFIN."TIMCONTRATOADM",TGFFIN."TIMBLOQUEADA",TGFFIN."TIMFECHAMENTOALU",TGFFIN."TIMDTIMPBOLLOCAL",TGFFIN."TIMFECHAMENTO",TGFFIN."TIMRENEGCANCLOTE",TGFFIN."TIMCONTRATOLTV",TGFFIN."TIMRESCISAOLTV",TGFFIN."TIMNUNOTA",TGFFIN."TIMCONTALANC",TGFFIN."TIMTXADMGERALU",TGFFIN."TIMFINGARANTORIG",TGFFIN."TIMREPINTELIGENTE",TGFFIN."TIMDHGERREPPARCIAL",TGFFIN."TIMDTREPPARCIAL",TGFFIN."TIMREPPARCIAL",TGFFIN."TIMVLRJUROCONTRATO",TGFFIN."TIMVLRAMORTCONTRATO",TGFFIN."TIMVLRCORRMONET",TGFFIN."CODIPTU",TGFFIN."TIMORIGRENEG",TGFFIN."TIMRESCISAOLOC",TGFFIN."TIMTIPOINTERMED",TGFFIN."AD_DTINC",TGFFIN."AD_CODUSUINC",TGFFIN."AD_ANO_GP",TGFFIN."CODOBSPADRAO",TGFFIN."AD_AJUSTERATEIO"
  ,TGFFIN."AD_NUSCO", TGFFIN."AD_NUPARCTA"
 FROM
  TGFFIN;
