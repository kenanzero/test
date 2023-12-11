--OBJECT DEPENDECIES: DME_DATA_ADJUSTMENT_PARAMS


/*
test data
REM INSERTING into EXPORT_TABLE
SET DEFINE OFF;
Insert into DME_TABLE_LOAD_PARAMETERS (TABLE_NAME,TABLE_TYPE,MANAGE_PARTITIONS,MANAGE_INDEXES,REGISTER_IN_fdm,MOD_USER,MOD_DATE,STATS_GRANULARITY,STATS_FOR_NONIND_COLUMNS) values ('TST_DMP_RR_T4_FACT_HIST','USER PARAMETER','N','N','Y','OFSA_OWNER',to_date('03-DEC-10','DD-MON-RR'),null,null);

REM INSERTING into 
SET DEFINE OFF;
Insert into DME_DATA_ADJUSTMENT_PARAMS (PARAM_TYPE_ID,RUN_AS_OF_DATE,UPDATE_TABLE_NAME,UPDATE_COLUMN_NAME,UPDATE_CRITERIA,NEW_VALUE,EXECUTION_ORDER,LOG_ORIGINAL_VALUES_FLAG,DESCRIPTION,DISABLED_FLAG,INVALID_RULE_FLAG,INVALID_RULE_MSG,NUM_OF_UPDATED_RECORDS,LAST_EXECUTION,COMPLETED_FLAG) values (1064773,to_date('31-DEC-16','DD-MON-RR'),'RI_MANUAL_JOURNAL_ENTRIES','PROD_COA_ID','GL_ACCOUNT_ID IN (100111) AND PROD_COA_ID=0 AND source_system_id_number like ''950321000%'' and adjustment_type=''I''','3015152130',null,1,'Updating RI_MANUAL_JOURNAL_ENTRIES.PROD_COA_ID column za kamate po partijama 57 Treasury',null,0,null,0,to_date('20-JAN-16','DD-MON-RR'),1);

*/


--testna table

create table TST_DMP_RR_T4_FACT_HIST as select * from DMP_RR_T4_FACT_HIST where datum_izvjestaja=date'2022-03-31' and verzija_izvjestaja =1

SELECT * FROM DMP_RR_T4_FACT_HIST


--SELECT  * FROM RI_DATA_ADJUSTMENT_PARAMS WHERE PARAM_TYPE_ID =1064773
/
CREATE OR REPLACE
PROCEDURE prepare_data_adjustments IS
    -----------------------------------------------------------------------------------
    -- Date       Modified By     Comments
    -- 20221504   kz              initail version
    --Notes:
      -- za pokretanje procedure DME_DATA_ADJUSTMENT_PARAMS COMPLETED_FLAG = 0;
    -----------------------------------------------------------------------------------
    sSQL LONG;
    nRet NUMBER;
    l_datum_val DATE;
    l_verzija_izvjestaja NUMBER;
    l_cnt number;
BEGIN
    -- inicijalizacija parametara verzija izvjestaja i datum izvjestaja 
    select to_date(PARAM_VALUE,'YYYYMMDD') into l_datum_val
    from dme_running_params
    where param_name in ('P_DATUM_VAL');
    
    select PARAM_VALUE into l_verzija_izvjestaja
    from dme_running_params
    where param_name in ('P_VERZIJA_IZVJESTAJA');

    --update DME_DATA_ADJUSTMENT_PARAMS set RUN_AS_OF_DATE = L_DATUM_VAL;
    COMMIT;

    sSQL := 'UPDATE DME_DATA_ADJUSTMENT_PARAMS SET NUM_OF_UPDATED_RECORDS=NULL, INVALID_RULE_FLAG=0, INVALID_RULE_MSG=NULL
             WHERE NVL(DISABLED_FLAG,0)=0 AND NVL(RUN_AS_OF_DATE,'''||l_datum_val||''')='''||l_datum_val||''' AND NVL(COMPLETED_FLAG,0)=0 ';
    EXECUTE IMMEDIATE sSQL;
    commit;
    for rec in (SELECT PARAM_TYPE_ID, RUN_AS_OF_DATE, UPDATE_TABLE_NAME, UPDATE_COLUMN_NAME, UPDATE_CRITERIA, NEW_VALUE, EXECUTION_ORDER, LOG_ORIGINAL_VALUES_FLAG
                FROM DME_DATA_ADJUSTMENT_PARAMS
                WHERE NVL(DISABLED_FLAG,0)=0
                  AND NVL(RUN_AS_OF_DATE,l_datum_val)=l_datum_val
                  AND NVL(COMPLETED_FLAG,0)=0
               )
    Loop
        -- Validate table name
        SSQL := 'SELECT TABLE_NAME FROM DME_TABLE_LOAD_PARAMETERS WHERE TABLE_TYPE = ''MANUAL_CORRECTION'' and TABLE_NAME = '''||REC.UPDATE_TABLE_NAME||'''';
        EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ('||sSQL||')' into l_cnt;
        --DBMS_OUTPUT.PUT_LINE(sSQL);
        if l_cnt <= 0 then
            sSQL := 'UPDATE DME_DATA_ADJUSTMENT_PARAMS SET INVALID_RULE_FLAG=-1, INVALID_RULE_MSG=''Invalid Update Table. Valid Values are tables which '' WHERE PARAM_TYPE_ID='||rec.PARAM_TYPE_ID;
            execute immediate (sSQL);
            commit;
            Goto NextForPDA;
        End If;

        -- Validate update column
        sSQL := 'SELECT COUNT(*) FROM USER_TAB_COLUMNS WHERE TABLE_NAME='''||rec.UPDATE_TABLE_NAME||''' AND COLUMN_NAME='''||rec.UPDATE_COLUMN_NAME||'''';
        EXECUTE IMMEDIATE sSQL into l_cnt;
        if l_cnt = 0 then
            sSQL := 'UPDATE DME_DATA_ADJUSTMENT_PARAMS SET INVALID_RULE_FLAG=-1,
                     INVALID_RULE_MSG=''Invalid Update Column Name. Following SQL returns no record:'||replace(sSQL,'''','''''')||'''
                     WHERE PARAM_TYPE_ID='||rec.PARAM_TYPE_ID;
            execute immediate SSQL;
            commit;
            Goto NextForPDA;
        End If;

        -- Validate update criteria
        sSQL := 'SELECT COUNT(*) FROM '||rec.UPDATE_TABLE_NAME||' WHERE 1=2 AND ('||rec.UPDATE_CRITERIA||')';
        BEGIN
            --nRet := RI_P_LOAD.ExecSQLRetNum(sSQL);
            EXECUTE IMMEDIATE sSQL into l_cnt;

            EXCEPTION WHEN NO_DATA_FOUND Then
                NULL;
            when others then
                sSQL := 'UPDATE DME_DATA_ADJUSTMENT_PARAMS SET INVALID_RULE_FLAG=-1,
                         INVALID_RULE_MSG=''Invalid Update Criteria. Following SQL fails:'||replace(sSQL,'''','''''')||'''
                         WHERE PARAM_TYPE_ID='||rec.PARAM_TYPE_ID;
                execute immediate SSQL;
                commit;
                Goto NextForPDA;
        END;

        -- Validate NEW_VALUE
        sSQL := 'UPDATE '||rec.UPDATE_TABLE_NAME||' SET '||rec.UPDATE_COLUMN_NAME||'='||rec.NEW_VALUE||' WHERE 1=2 AND ('||rec.UPDATE_CRITERIA||')';
        BEGIN
            EXECUTE IMMEDIATE sSQL;

            ROLLBACK;

            EXCEPTION WHEN NO_DATA_FOUND Then
                NULL;
            WHEN OTHERS Then
                ROLLBACK;

                sSQL := 'UPDATE DME_DATA_ADJUSTMENT_PARAMS SET INVALID_RULE_FLAG=-1,
                         INVALID_RULE_MSG=''Invalid NEW_VALUE Criteria. Following SQL fails:'||replace(sSQL,'''','''''')||'''
                         WHERE PARAM_TYPE_ID='||rec.PARAM_TYPE_ID;
                EXECUTE IMMEDIATE sSQL;
                commit;
                Goto NextForPDA;
        END;

        <<NextForPDA>>
        NULL;

    End Loop;

    -- Raise error if there are invalid rules
    sSQL := 'SELECT COUNT(*) FROM DME_DATA_ADJUSTMENT_PARAMS WHERE NVL(DISABLED_FLAG,0)=0 AND INVALID_RULE_FLAG=-1';
    execute immediate  sSQL into l_cnt;
    if l_cnt <> 0 then
       RAISE_APPLICATION_ERROR(-20030, 'Invalid rule definitions found in table DME_DATA_ADJUSTMENT_PARAMS! SQL: SELECT * FROM DME_DATA_ADJUSTMENT_PARAMS WHERE NVL(DISABLED_FLAG,0)=0 AND INVALID_RULE_FLAG=-1');
    End if;

end PREPARE_DATA_ADJUSTMENTS;
/

