select * from dmr_h_fba_codes where level_02_cd =2;

SELECT * 
FROM DMT_USAGE_MLS;

-- TABELA U KOJU UNOSIMO MANUELNE KOREKCIJE
CREATE TABLE DME_MANUAL_CORRECTIONS
(
  ID_NUMBER                   NUMBER NOT NULL,
  FOR_DATUM_IZVJESTAJA        DATE,
  FOR_VERZIJA_IZVJESTAJA      NUMBER,
  REPORTING_POSITION_CD       NUMBER(14),
  X_CODE                      NUMBER(14),
  Y_CODE                      NUMBER(14),
  ADJUSTMENT_TABLE            VARCHAR2(30 BYTE) NOT NULL,
  adjustment_amount           number,
  DESCRIPTION                 VARCHAR2(100 BYTE),
  MOD_USER                    VARCHAR2(80 BYTE),
  MOD_DATE                    DATE,
  MATICNI_BROJ                VARCHAR2(240 BYTE),
  PARTIJA                     VARCHAR2(240 BYTE)
);

select * from TEST_DMR_RR_FBA_FACT_HIST;

select * from dme_manual_corrections; 
-------

/
set serveroutput on 
declare
    l_datum_izvjestaja date;
    l_verzija_izvjestaja number;
    l_cnt number;
    l_sql_stmt varchar2(2000);
    l_dmp_rr_t4_fact_hist varchar2(80);
    l_dmp_rr_ifrs9_fact_hist varchar2(80);
begin
    l_datum_izvjestaja := date'2021-12-31';
    l_verzija_izvjestaja := 1;
    l_dmp_rr_t4_fact_hist := 'TEST_DMP_RR_T4_FACT_HIST';
    l_dmp_rr_ifrs9_fact_hist := 'TEST_DMP_RR_IFRS9_FACT_HIST';
    
    -- check entered tables for manual addons
    select count(adjustment_table) into l_cnt
    from dme_manual_corrections 
    where for_datum_izvjestaja = l_datum_izvjestaja
    and for_verzija_izvjestaja = l_verzija_izvjestaja
    and adjustment_table in (l_dmp_rr_t4_fact_hist, l_dmp_rr_ifrs9_fact_hist);
    
        --end if;
    if l_cnt > 0 then
        dbms_output.put_line('Postoje manuelne korekcija za IFRS ili T4 izvjestaj!');
        --raise;
    end if;
    
    -- check entered positions for manual addons 
    select count(1) into l_cnt
    from dme_manual_corrections m
    where report_code in (200,300)
    and m.for_datum_izvjestaja = l_datum_izvjestaja
    and m.for_verzija_izvjestaja = l_verzija_izvjestaja
    and m.adjustment_table in  (l_dmp_rr_t4_fact_hist, l_dmp_rr_ifrs9_fact_hist)
    and (m.reporting_position_cd, m.report_code) not  in 
    (
        select reporting_position_code, report_code
        from DMR_REPORTING_POSITION_CD
        where report_code in (200,300)
        and col_type = 'FACT'
    );
   
    if l_cnt > 0 then
        dbms_output.put_line('Navedena izvjestajna pozicija nepoznata za y_code!');
        --raise;
    end if;
    
    dbms_output.put_line(l_cnt);
    -- provjera da li imamo podatlke za datum koji korigujemo u izvjehustajnim tabelama
    for i in (    select distinct adjustment_table
                  from dme_manual_corrections 
                  where for_datum_izvjestaja = l_datum_izvjestaja
                  and for_verzija_izvjestaja = l_verzija_izvjestaja
                  and report_code in (200,300)
                  ) loop
--        dbms_output.put_line(i.adjustment_table);
        l_sql_stmt := ' select count(1) from ' || 
                        l_dmp_rr_t4_fact_hist ||
                      ' where datum_izvjestaja = :datum_izvjestaja' ||
                      ' and verzija_izvjestaja = :verzija_izvjestaja'; 
       -- execute immediate l_sql_stmt into l_cnt using l_datum_izvjestaja, l_verzija_izvjestaja ;
--        dbms_output.put_line(l_cnt || ' d');
        
        --ako ima podataka za tabelu koja se koriguje
        if l_cnt > 0 then
                --brisi manuelne korekcije 
                            --brisi manuelne korekcije 
            l_sql_stmt := 'delete ' || l_dmp_rr_t4_fact_hist || ' 
                            where datum_izvjestaja = :l_datum_izvjestaja
                            and verzija_izvjestaja = :l_verzija_izvjestaja
                            and manual_corr_id_number != -999';
            execute immediate l_sql_stmt using l_datum_izvjestaja, l_verzija_izvjestaja ;
            
            -- loookup koja se kolona azurira na osnovu dict code-a
--            for j in (select id_number, sysdate, for_verzija_izvjestaja, for_datum_izvjestaja, 'MONTHLY' as freq_flag, report_code, adjustment_amount, x_code, y_code
--                          from dme_manual_corrections 
--                          where for_datum_izvjestaja = l_datum_izvjestaja
--                          and for_verzija_izvjestaja = l_verzija_izvjestaja
--                          and adjustment_table = i.adjustment_table) loop
--                   l_sql_stmt:= 'insert into test_dmr_rr_fba_fact_hist ( ' ||
--                        'manual_corr_id_number, DME_LOAD_DATE, VERZIJA_IZVJESTAJA, DATUM_IZVJESTAJA, FREQ_FLAG, REPORT_CODE, BALANCE, X_CODE, Y_CODE) values ' ||
--                        '(:id_number, :dme_load_date, :verzija_izvjestaja, :datum_izvjestaja, :freq_flag, :report_code, :balance, :x_code, :y_code)';
--                dbms_output.put_line(l_cnt || ' manual addons ' || j.adjustment_amount);
--                execute immediate l_sql_stmt using j.id_number, j.sysdate, j.for_verzija_izvjestaja, j.for_datum_izvjestaja, j.freq_flag, j.report_code, j.adjustment_amount, j.x_code, j.y_code ;
--                dbms_output.put_line(l_cnt || ' manual addons ' || j.adjustment_amount);
--                end loop;
            end if;
            dbms_output.put_line(i.adjustment_table);
    end loop;
    
    exception 
    when others then
    dbms_output.put_line('Exception!!');
    raise;
    
end;
/

select id_number, sysdate, for_verzija_izvjestaja, for_datum_izvjestaja, 'MONTHLY', report_code, adjustment_amount, x_code, y_code
from DME_MANUAL_CORRECTIONS --DMR_RR_FBA_FACT_HIST
/
alter table dme_manual_corrections add report_code number


    select x_code, y_code, report_code
    from dme_manual_corrections 
    where for_datum_izvjestaja = l_datum_izvjestaja
    and adjustment_table not in ('TEST_DMR_RR_FBA_FACT_HIST');
/
select * 
from dmr_reporting_position_cd


/
select * from  test_dmr_rr_fba_fact_hist where manual_corr_id_number != -999;

REM INSERTING into DMR_RR_FBA_FACT_HIST
SET DEFINE OFF;
'Insert into DMR_RR_FBA_FACT_HIST (
DME_LOAD_DATE, VERZIJA_IZVJESTAJA, DATUM_IZVJESTAJA, FREQ_FLAG, REPORT_CODE, BALANCE, X_CODE, Y_CODE) values 
(:dme_load_date, :verzija_izvjestaja, :datum_izvjestaja, :freq_flag, :report_code, :balance, :x_code, :y_code)';


select rowid,DMR_RR_FBA_FACT_HIST.*  
from DMR_RR_FBA_FACT_HIST
where rowid='AAtGxWADEAADqfvAAF';

select chr(39) from dual

select * 
from DME_MANUAL_CORRECTIONS 

select * from dmr_h_fba_codes
update DME_MANUAL_CORRECTIONS set report_code = 2;
/
-- check x code
select level_02_cd, code from dmr_h_fba_codes where level_01_cd=1 and level_02_cd = 2
union all
-- check y code
select level_02_cd, code from dmr_h_fba_codes where level_01_cd=2 and level_02_cd = 2;
-- check reporting_position_cd (T4 IFRS) 


/
--PrepareDataAdjustments
-- tabele: RI_DATA_ADJUSTMENT_PARAMS, 
-- radi update pocetnih vrijednosti: RI_DATA_ADJUSTMENT_PARAMS SET NUM_OF_UPDATED_RECORDS=NULL, INVALID_RULE_FLAG=0, INVALID_RULE_MSG=NULL
-- provjerava da kolone  i tabele koje su navedene u parametarskoj tabeli ispravne, da li postoje u dictionary
--RunDataAdjustments



---------------------------------------------------------------------------------
/
--KORISTITI SQL_ID I BATCH_ID. KREIRATI RESULT TABELU 
-- CREATE TABLE DMR_CHECK_DATA_LOAD (DATUM_IZVJESTAJA DATE, LOAD_TYPE VARCHAR2(20), TABELA VARCHAR2(250), IZVJESTAJ VARCHAR2(80), BROJ_SLOGOVA NUMBER)
--Tabele koje su bitne za pokretanje izvjestaja t4

/

SELECT * 
FROM DME_SQL_MAPPING_DEFINITIONS 
WHERE UPPER(SQL_SOURCE_SELECT) LIKE '%TB0_L_FBA_SEGMENTACIJA%'
--AND BUSINESS_SUBJECT ='IFRS9_BAZA'
/



