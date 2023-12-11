--DESCRIBE DME_DATA_ADJUSTMENT_PARAMS



--------------------------------------------------------
--  DDL for Table DME_DATA_ADJUSTMENT_PARAMS
--------------------------------------------------------
alter table DME_DATA_ADJUSTMENT_PARAMS add MOD_USER VARCHAR2(120);

  CREATE TABLE DME_DATA_ADJUSTMENT_PARAMS 
   (	PARAM_TYPE_ID NUMBER(14,0) NOT NULL, 
	RUN_AS_OF_DATE DATE, 
	UPDATE_TABLE_NAME VARCHAR2(30 BYTE) NOT NULL, 
	UPDATE_COLUMN_NAME VARCHAR2(30 BYTE)  NOT NULL, 
	UPDATE_CRITERIA VARCHAR2(4000 BYTE)  NOT NULL, 
	NEW_VALUE VARCHAR2(4000 BYTE) NOT NULL, 
	EXECUTION_ORDER NUMBER(5,0), 
	LOG_ORIGINAL_VALUES_FLAG NUMBER(5,0), 
	DESCRIPTION VARCHAR2(4000 BYTE), 
	DISABLED_FLAG NUMBER(5,0), 
	INVALID_RULE_FLAG NUMBER(5,0), 
	INVALID_RULE_MSG VARCHAR2(4000 BYTE), 
	NUM_OF_UPDATED_RECORDS NUMBER(10,0), 
	LAST_EXECUTION DATE, 
	COMPLETED_FLAG number(5,0),
  MOD_USER VARCHAR2(120)
   );

   COMMENT ON COLUMN DME_DATA_ADJUSTMENT_PARAMS.COMPLETED_FLAG IS 'If the rule have been executed in actual run is set to 1, otherwise is NULL';
--------------------------------------------------------
--  DDL for Index I_DME_DATA_ADJUSTMENT_PARAMS_U
--------------------------------------------------------

  CREATE UNIQUE INDEX I_DME_DATA_ADJUSTMENT_PARAMS_U ON DME_DATA_ADJUSTMENT_PARAMS (PARAM_TYPE_ID);
  
--------------------------------------------------------
--  Constraints for Table DME_DATA_ADJUSTMENT_PARAMS
--------------------------------------------------------

  ALTER TABLE DME_DATA_ADJUSTMENT_PARAMS ADD CONSTRAINT C_DME_DATA_ADJUSTMENT_PARAMS_PK PRIMARY KEY (PARAM_TYPE_ID);
  
  
  --------------------------------------------------------
--  DDL for Table DME_TABLE_LOAD_PARAMETERS
--------------------------------------------------------

  CREATE TABLE DME_TABLE_LOAD_PARAMETERS 
   (	TABLE_NAME VARCHAR2(30 BYTE) NOT NULL, 
	TABLE_TYPE VARCHAR2(30 BYTE) NOT NULL, 
	MANAGE_PARTITIONS VARCHAR2(1 BYTE) NOT NULL, 
	MANAGE_INDEXES VARCHAR2(1 BYTE), 
	REGISTER_IN_FDM VARCHAR2(1 BYTE), 
	MOD_USER VARCHAR2(30 BYTE), 
	MOD_DATE DATE, 
	STATS_GRANULARITY VARCHAR2(25 BYTE), 
	STATS_FOR_NONIND_COLUMNS VARCHAR2(1000 BYTE)
   );

   COMMENT ON COLUMN DME_TABLE_LOAD_PARAMETERS.TABLE_NAME IS 'Unique Key';
   COMMENT ON COLUMN DME_TABLE_LOAD_PARAMETERS.TABLE_TYPE IS 'S:Staging O:FDM T:Temporary';
   COMMENT ON COLUMN DME_TABLE_LOAD_PARAMETERS.MANAGE_PARTITIONS IS 'Y:Manage Paritions before load N:Don''t manage partitions';
   COMMENT ON COLUMN DME_TABLE_LOAD_PARAMETERS.MANAGE_INDEXES IS 'Y:Manage indexes before load N:Don''t manage indexes';
   COMMENT ON COLUMN DME_TABLE_LOAD_PARAMETERS.REGISTER_IN_FDM IS 'Y: Register in FDM';
   COMMENT ON COLUMN DME_TABLE_LOAD_PARAMETERS.MOD_USER IS 'Modified By';
   COMMENT ON COLUMN DME_TABLE_LOAD_PARAMETERS.MOD_DATE IS 'Modification Date';
   COMMENT ON COLUMN DME_TABLE_LOAD_PARAMETERS.STATS_GRANULARITY IS 'Possible values ''ALL'' - gathers all (subpartition, partition, and global) statistics- This is the default value, if column is NULL or not one of the following values, ALL will be used, ''AUTO''- determines the granularity based on the partitioning type. ''GLOBAL'' - gathers global statistics ''GLOBAL AND PARTITION'' - gathers the global and partition level statistics. No subpartition level statistics are gathered even if it is a composite partitioned object.  ''PARTITION ''- gathers partition-level statistics ''SUBPARTITION'' - gathers subpartition-level statistics.';
   COMMENT ON COLUMN DME_TABLE_LOAD_PARAMETERS.STATS_FOR_NONIND_COLUMNS IS 'Comma separated list of non-indexed columns which require the gathering of statistics. These columns will go into the argument method_opt when gathering table stats.';


--------------------------------------------------------
--  DDL for Index I_RI_TABLE_LOAD_PARAMS_U
--------------------------------------------------------

  CREATE UNIQUE INDEX I_DME_TABLE_LOAD_PARAMS_U ON DME_TABLE_LOAD_PARAMETERS (TABLE_NAME);
--------------------------------------------------------
--  Constraints for Table DME_TABLE_LOAD_PARAMETERS
--------------------------------------------------------

  ALTER TABLE DME_TABLE_LOAD_PARAMETERS ADD CONSTRAINT C_DME_TABLE_LOAD_PARAMS_PK PRIMARY KEY (TABLE_NAME);

--------------------------------------------------------
--  DDL for Trigger T_RI_TABLE_LOAD_PARAMS_M
--------------------------------------------------------

  CREATE OR REPLACE TRIGGER DME_TABLE_LOAD_PARAMS_TG
BEFORE INSERT OR UPDATE ON DME_TABLE_LOAD_PARAMETERS
FOR EACH ROW
DECLARE
BEGIN
    select user, sysdate into :new.mod_user, :new.mod_date from dual;
END;


/
ALTER TRIGGER DME_TABLE_LOAD_PARAMS_TG ENABLE;



--FDM_DATA_ADJUSTMENT_LOG

--------------------------------------------------------
--  DDL for Table FDM_DATA_ADJUSTMENT_LOG
--------------------------------------------------------
  create table DME_DATA_ADJUSTMENT_LOG 
   (	RULE_PARAM_TYPE_ID number(14,0) not null, 
	RULE_UPDATE_CRITERIA varchar2(4000 byte) NOT NULL, 
	RULE_NEW_VALUE varchar2(4000 byte) NOT NULL, 
	AS_OF_DATE date  NOT NULL, 
	TABLE_NAME VARCHAR2(80 BYTE) NOT NULL, 
	COLUMN_NAME VARCHAR2(80 BYTE), 
	ID_NUMBER NUMBER(25,0), 
	IDENTITY_CODE NUMBER(10,0), 
	TRANSACTION_UNID VARCHAR2(240 BYTE), 
	SOURCE_SYSTEM_ID_NUMBER VARCHAR2(240 BYTE), 
	ORIGINAL_VALUE VARCHAR2(1000 BYTE), 
	SYSTEM_DATE DATE, 
	row_id varchar2(30 byte),
  MOD_USER VARCHAR2(120),
  maticni_broj varchar2(120), 
  partija varchar2(120),
  log_id number ,
  restored_flag number
   );
   
   
alter table dme_data_adjustment_log add restored_flag number;
alter table dme_data_adjustment_log modify log_id default "DME_DATA_ADJ_LOG_SEQ_ID"."NEXTVAL"
alter table dme_data_adjustment_log  add constraint pk_dme_data_adj_log primary key (LOG_ID)
select * from DME_DATA_ADJUSTMENT_PARAMS_LOG
/
--------------------------------------------------------
--  DDL for Sequence DME_LOG_SEQ_ID_NUMBER
--------------------------------------------------------

   create sequence  "BI_FIN_REP"."DME_DATA_ADJ_LOG_SEQ_ID"  minvalue 1 maxvalue 999999999999999 increment by 1 start with 1 cache 20 noorder  nocycle  nokeep  noscale  global ;

GRANT SELECT ON DME_DATA_ADJUSTMENT_LOG TO BI_FIN_init

create synonym DME_DATA_ADJUSTMENT_LOG for BI_FIN_REP.DME_DATA_ADJUSTMENT_LOG
