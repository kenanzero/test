create or replace 
procedure restore_manual_adjustment (p_rule_id number)is
  l_sql_string varchar2(3000);
begin
  for i in (
  select 'update ' || table_name  || ' set ' || column_name || ' = ''' || original_value || ''' where datum_izvjestaja= to_date('''||to_char(as_of_date,'dd.mm.yyyy')||''', ''dd.mm.yyyy'')' || ' and rowid = ''' || row_id ||'''' as upd_str
          from dme_data_adjustment_log 
          where rule_param_type_id = p_rule_id
          and nvl(restored_flag,0) = 0 ) 
  loop
    l_sql_string := i.upd_str;
    execute immediate l_sql_string; 
  end loop;
  update dme_data_adjustment_log
  set restored_flag=-1
  WHERE rule_param_type_id = p_rule_id;
  commit; 
exception
  when others then 
  rollback;
  --dbms_output.put_line(l_sql_string);
  raise;
end restore_manual_adjustment;