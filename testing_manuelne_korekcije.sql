/
-- pregled originalnih podataka za korekciju prema filteru u manuelnim korekcijama koje se pripreme
select ISPRAVKA_VRIJEDNOSTI_BIL_STAGE_2, ISPRAVKA_VRIJEDNOSTI_BIL_STAGE_3
from ins_rr_t4_fact
where maticni_broj='2023250' and partija='12000055251'  and segmentation_step = 0
/
--/
--update tst_ins_rr_t4_fact
--set ISPRAVKA_VRIJEDNOSTI_BIL_STAGE_2=0
--where maticni_broj='2023250' and partija='12000055251'  and segmentation_step = 0
--/
--/
-- ocekujemo da uradimo sa st_3 na st_2
select ISPRAVKA_VRIJEDNOSTI_BIL_STAGE_2, ISPRAVKA_VRIJEDNOSTI_BIL_STAGE_3
from tst_ins_rr_t4_fact
where maticni_broj='2023250' and partija='12000055251'  and segmentation_step = 0
/
begin
  RUN_DATA_ADJUSTMENTS;
end;
/
-- pregled rezultata procedure
select * from dme_data_adjustment_log;
/

-- reset current status za manuelne korekcije
update dme_data_adjustment_params
set last_execution = null,
disabled_flag = null,
num_of_updated_records = null,
completed_flag = null;
/

CREATE TABLE TST_ins_rr_t4_fact AS 
select * 
from ins_rr_t4_fact

set serveroutput on 
exec restore_manual_adjustment (31);
/
select * from  DME_TABLE_LOAD_PARAMETERS ;
select * from dme_data_adjustment_params;
select * from dme_data_adjustment_log;
delete from DME_DATA_ADJUSTMENT_PARAMS;
delete dme_data_adjustment_log;
commit;


--
/*
- spasi originalnu vrijednost
TST_DMP_RR_T4_FACT_HIST
*/
/
select segmentation_step, datum_izvjestaja, verzija_izvjestaja, ISPRAVKA_VRIJEDNOSTI_BIL_STAGE_2, ISPRAVKA_VRIJEDNOSTI_BIL_STAGE_3
from INS_RR_T4_FACT 
where MATICNI_BROJ='2023250' and PARTIJA='250039284-6'
and segmentation_step =0;

/
select * from dme_data_adjustment_log where rule_param_type_id = 33
--MATICNI_BROJ='2023250' and PARTIJA='250039284-6';
/

update  TST_INS_RR_T4_FACT 
set ispravka_vrijednosti_bil_stage_2 = 0,
ispravka_vrijednosti_bil_stage_3 = 0
where maticni_broj='2023250' and partija='250039284-6'
and segmentation_step =0;;
/
update dme_data_adjustment_log
set restored_flag=0,
RULE_NEW_VALUE = 0
WHERE rule_param_type_id = 33;

select * 
FROM dme_data_adjustment_log
WHERE rule_param_type_id = 33;

create synonym  DME_RUNNING_PARAMS for bi_fin_rep.DME_RUNNING_PARAMS

grant select on DME_RUNNING_PARAMS to bi_fin_init
grant execute on restore_manual_adjustment to bi_fin_init
create synonym  restore_manual_adjustment for bi_fin_rep.restore_manual_adjustment
update TST_INS_RR_T4_FACT set ISPRAVKA_VRIJEDNOSTI_BIL_STAGE_2 = '13.4' where datum_izvjestaja= to_date('31.03.2022', 'dd.mm.yyyy') and rowid = 'AA058tADRAAEBoRABG'