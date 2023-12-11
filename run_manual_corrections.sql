create or replace
PROCEDURE run_data_adjustments(bForceRun Boolean DEFAULT FALSE) IS
------------------------------------------------------------------------------------
-- Date       Modified By     Comments
-- 20121031   wzhsaq          RunDataAdjustments restart protection (BI00005753)
------------------------------------------------------------------------------------
  SSQL clob;
  sSQL2 CLOB;
  l_cnt_for_upd number;
  l_datum_val DATE;
  l_verzija_izvjestaja NUMBER;
  l_cnt number;
begin
    select to_date(PARAM_VALUE,'YYYYMMDD') into l_datum_val
    from dme_running_params
    where param_name in ('P_DATUM_VAL');
    
    select PARAM_VALUE into l_verzija_izvjestaja
    from DME_RUNNING_PARAMS
    where PARAM_NAME in ('P_VERZIJA_IZVJESTAJA');
    
    -- Validate RI_DATA_ADJUSTMENT_PARAMS
    prepare_data_adjustments;

    for REC in (select PARAM_TYPE_ID, RUN_AS_OF_DATE, UPDATE_TABLE_NAME, UPDATE_COLUMN_NAME, UPDATE_CRITERIA, NEW_VALUE, EXECUTION_ORDER, LOG_ORIGINAL_VALUES_FLAG,MOD_USER
                 FROM DME_DATA_ADJUSTMENT_PARAMS
                 WHERE NVL(DISABLED_FLAG,0)=0
                 AND NVL(RUN_AS_OF_DATE,l_datum_val)=l_datum_val
                 AND NVL(COMPLETED_FLAG,0)=0
                 ORDER BY CASE WHEN NVL(EXECUTION_ORDER,0)=0 THEN PARAM_TYPE_ID ELSE EXECUTION_ORDER END
               )
    Loop

      -- If logging is enabled, log original values
        if nvl(rec.log_original_values_flag,0) != 0 then
            sSQL := 'INSERT INTO DME_DATA_ADJUSTMENT_LOG(RULE_PARAM_TYPE_ID,RULE_UPDATE_CRITERIA,RULE_NEW_VALUE,AS_OF_DATE,TABLE_NAME,COLUMN_NAME,MOD_USER,ID_NUMBER,MATICNI_BROJ, PARTIJA,ORIGINAL_VALUE,SYSTEM_DATE,ROW_ID)
                     (SELECT '||rec.PARAM_TYPE_ID||','''||replace(rec.UPDATE_CRITERIA,'''','''''')||''','''||replace(rec.NEW_VALUE,'''','''''')||''','||
                     'TO_DATE('''||TO_CHAR(l_datum_val,'DD.MM.YYYY')||''', ''DD.MM.YYYY'')' ||','''||rec.UPDATE_TABLE_NAME||''','''||rec.UPDATE_COLUMN_NAME||''','''||rec.MOD_USER||''',';
            
            --Na isti nacin se mogu provjeriti dodatni atributi (osim ovdje navedenog ID_NUMBER, npr neki business atibuti: maticni_broj, partija)
           FOR X in ( SELECT COUNT(*) CNT FROM DUAL WHERE EXISTS ( SELECT COLUMN_NAME FROM USER_TAB_COLUMNS WHERE TABLE_NAME = rec.UPDATE_TABLE_NAME and COLUMN_NAME ='ID_NUMBER' ))
           LOOP
                IF ( X.CNT = 1 ) THEN
                   sSQL := sSQL ||'ID_NUMBER'||',';
                ELSE
                   sSQL := sSQL ||'NULL'||',';
                END IF;
           end loop;
           
           FOR X in ( SELECT COUNT(*) CNT FROM DUAL WHERE EXISTS ( SELECT COLUMN_NAME FROM USER_TAB_COLUMNS WHERE TABLE_NAME = rec.UPDATE_TABLE_NAME and COLUMN_NAME ='MATICNI_BROJ' ))
           LOOP
                IF ( X.CNT = 1 ) THEN
                   sSQL := sSQL ||'MATICNI_BROJ'||',';
                ELSE
                   sSQL := sSQL ||'NULL'||',';
                end if;
           end loop;
           
           FOR X in ( SELECT COUNT(*) CNT FROM DUAL WHERE EXISTS ( SELECT COLUMN_NAME FROM USER_TAB_COLUMNS WHERE TABLE_NAME = rec.UPDATE_TABLE_NAME and COLUMN_NAME ='PARTIJA' ))
           LOOP
                IF ( X.CNT = 1 ) THEN
                   sSQL := sSQL ||'PARTIJA'||',';
                ELSE
                   sSQL := sSQL ||'NULL'||',';
                end if;
           end loop;
           
           ssql := ssql ||rec.update_column_name||', sysdate, rowid FROM '||rec.update_table_name||' WHERE '||rec.update_criteria||')';
           execute immediate SSQL;
--           DBMS_OUTPUT.PUT_LINE(sSQL);
           COMMIT;
        End If;

       -- Select the number of records that will be updated
        SSQL := 'SELECT COUNT(*) FROM ' || REC.UPDATE_TABLE_NAME || ' WHERE ' || REC.UPDATE_CRITERIA;
        SSQL2 := 'select count(0) from user_tab_columns u where u.table_name = ''' || REC.UPDATE_TABLE_NAME || ''' and u.column_name IN (''DATUM_IZVJESTAJA'',''VERZIJA_IZVJESTAJA'')';
        execute immediate sSQL2  into l_cnt;
        if l_cnt > 0 then
           SSQL :=  SSQL ||' AND DATUM_IZVJESTAJA='''||L_DATUM_VAL||'''';
           sSQL :=  sSQL ||' AND VERZIJA_IZVJESTAJA='''||l_verzija_izvjestaja||'''';
        end if;
        execute immediate sSQL into l_cnt_for_upd;

        If l_cnt_for_upd > 0 Then
           -- Run the update
           SSQL := 'UPDATE ' || REC.UPDATE_TABLE_NAME || ' SET ' || REC.UPDATE_COLUMN_NAME || '=' || REC.NEW_VALUE || ' WHERE ' || REC.UPDATE_CRITERIA;-- || ' AND DATUM_IZVJESTAJA =''' || g_AS_OF_DATE || '''';
           SSQL2 := 'select count(0) from user_tab_columns u where u.table_name = ''' || REC.UPDATE_TABLE_NAME || ''' and u.column_name IN (''DATUM_IZVJESTAJA'',''VERZIJA_IZVJESTAJA'')';
           execute immediate sSQL2  into l_cnt;
           if L_CNT > 0 then
              SSQL :=  SSQL || ' AND DATUM_IZVJESTAJA = ''' || L_DATUM_VAL || '''';
              sSQL :=  sSQL || ' AND VERZIJA_IZVJESTAJA= ''' || l_verzija_izvjestaja || '''';
           end if;
           execute immediate(SSQL);
           commit;
        End If;

        -- Update general level logging information in RI_DATA_ADJUSTMENT_PARAMS
        sSQL := 'UPDATE DME_DATA_ADJUSTMENT_PARAMS SET LAST_EXECUTION=SYSDATE, NUM_OF_UPDATED_RECORDS='||l_cnt_for_upd||', COMPLETED_FLAG= -1
                 WHERE PARAM_TYPE_ID='||rec.PARAM_TYPE_ID;
        execute immediate(SSQL);
        commit;
    End Loop;

EXCEPTION
     WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
end RUN_DATA_ADJUSTMENTS;
/
grant execute on PREPARE_DATA_ADJUSTMENTS to BI_FIN_INIT;
/
execute RUN_DATA_ADJUSTMENTS;
create synonym RUN_DATA_ADJUSTMENTS for BI_FIN_REP.RUN_DATA_ADJUSTMENTS
/
grant debug RUN_DATA_ADJUSTMENTS to bi_fin_init

/
create procedure HELLO is begin DBMS_OUTPUT.PUT_LINE('hello'); end;
create synonym hello for BI_FIN_REP.hello
/
grant execute on hello to bi_fin_init
/
select TO_CHAR(A.SYSTEM_DATE,'dd.mm.yyyy hh.mi.ss') AS SYSTEM_DATE, A.*
from DME_DATA_ADJUSTMENT_LOG a
ORDER BY A.SYSTEM_DATE DESC;

/
select *
from DME_DATA_ADJUSTMENT_PARAMS;
/
select to_char(end_time,'dd.mm.yyyy hh.mi.ss')ISPRAVKA_VRIJEDNOSTI_BIL_STAGE_2 
from TST_DMP_RR_T4_FACT_HIST
where ID_NUMBER in (32768760,33181359)

select ISPRAVKA_VRIJEDNOSTI_BIL_STAGE_2 
from DMP_RR_T4_FACT_HIST PARTITION(P_2022)
where ID_NUMBER in (32768760,33181359)
/
select distinct datum_izvjestaja from OLD_INS_RR_T4_FACT_PROV_I_NAKN;
select * from TST_DMP_RR_T4_FACT_HIST;
DROP TABLE  OLD_INS_RR_T4_FACT_PROV_I_NAKN PURGE;

/
/
select column_name
from user_tab_cols
where table_name like 'DMP_RR_T4_FACT_HIST'
and column_name not like 'SYS%'
order by column_name

/
grant select on TST_DMP_RR_T4_FACT_HIST to bi_fin_init
/
select * 
from tst_dmp_rr_t4_fact_hist
where ID_NUMBER =32944208
/

create synonym tst_dmp_rr_t4_fact_hist for bi_fin_rep.tst_dmp_rr_t4_fact_hist
select * 
from tst_dmp_rr_t4_fact_hist
where id_number =32944208
/
create table DME_DATA_ADJUSTMENT_PARAMS as  select * from BI_FIN_REP.DME_DATA_ADJUSTMENT_PARAMS;
/
GRANT SELECT ON DME_DATA_ADJUSTMENT_PARAMS TO BI_FIN_INIT
