CREATE OR REPLACE FUNCTION JIVA.OBTER_TEMPTURNO_OEE_P(P_CODEMP NUMBER, P_DHINICIO DATE, P_DHFINAL DATE)
RETURN T_TEMPOTURNO_OEE_TAB PIPELINED IS
    V_TEMPOTURNO FLOAT;
BEGIN

      SELECT
           ROUND(SUM(TEMPOTURNO),2)  AS TEMPO  INTO V_TEMPOTURNO
        FROM (
            SELECT
                CASE WHEN TURNO = 'C' THEN DTREF + 22.6666/24 
                     WHEN TURNO = 'A' THEN DTREF + 6/24 
                     WHEN TURNO = 'B' THEN DTREF + 14.3333/24 END AS DHREF,
                TURNO,
                CASE WHEN TURNO IN('A','B') THEN 8.3333
                     WHEN TURNO = 'C' THEN 7.3334 END AS TEMPOTURNO
            FROM AD_CABMAIL 
            WHERE LOCAL = 'EX'
            AND PESOEX > 0 
            AND 1 = P_CODEMP
            AND NVL(NCONSIDERAOEE,'N') = 'N'
            UNION ALL
            SELECT
                 /* CASE WHEN TURNO = 'C' THEN DTREF + 22.6666/24 
                     WHEN TURNO = 'A' THEN DTREF + 6/24 
                     WHEN TURNO = 'B' THEN DTREF + 14.3333/24 END */
                --DTREF + INTERVAL '1' SECOND AS DHREF,
                 DTREF + 23/24 + interval '59' minute  AS DHREF,
                TURNO,
                CASE WHEN TURNO = 'A' THEN 24 END AS TEMPOTURNO
            FROM AD_CABMAILBV
            WHERE LOCAL = 'EX'
            AND 14 = P_CODEMP
              AND NVL(NCONSIDERAOEE,'N') = 'N'
        )
        WHERE DHREF BETWEEN P_DHINICIO  AND P_DHFINAL - INTERVAL '1'SECOND;
        
          IF V_TEMPOTURNO IS NOT NULL THEN
                PIPE ROW(T_TEMPOTURNO_OEE_REC(V_TEMPOTURNO));
          END IF;

    RETURN;
END;
/