run_delete()
{
  # exit if filter or value not supplied
  if [ -z "$s_filter" ] || [ -z "$s_value" ]; then
    exit
  fi
  records=$(run_select)
  echo "$records"
  num=$(echo "$records" | wc -l)
  read -r -p "$num record(s) will be deleted. Continue [y/N]? " choice
  echo $choice
  #exec_sql $(sql_select "$s_column" $table "$s_filter")
}

gen_filters()
{
  # generate filter segment of the sql
  if [ -n "$s_value" ]; then
    s_filter=$(filter_strict or "$s_filter" "$s_value")
  fi
}
