create or replace 
trigger dme_data_adjustment_params_tg
before update on dme_data_adjustment_params
for each row
begin
    :new.mod_user := SYS_CONTEXT ('USERENV', 'OS_USER');
end;