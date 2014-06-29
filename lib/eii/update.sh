run_update()
{
  # exit if filter or value not supplied
  if
    [ -z "$s_newvalue" ] ||
    [ -z "$s_column" ] ||
    [ -z "$s_filter" ] ||
    [ -z "$s_value" ]; then
    echo "Update requires -c, -n, -f, and -v"
    exit
  fi
  records=$(run_select)
  echo "$records"
  ((num=$(echo "$records" | wc -l)-1))
  if [ $num -eq 0 ]; then
    return
  fi
  gen_updates
  gen_updates_filters

  read -r -p "$num record(s) will be updated. Continue [y/N]? " choice

  case $choice in
    [yY][eE][sS]|[yY])
    exec_sql $(sql_update $table "$s_updates" "$s_filter")
    ;;
  esac
}

gen_updates()
{
  # generate filter segment of the sql
  if [ -n "$s_newvalue" ]; then
    s_updates=$(filter_strict and "$s_column" "$s_newvalue")
  fi
}

gen_update_filters()
{
  # generate filter segment of the sql
  if [ -n "$s_value" ]; then
    s_filter=$(filter_strict and "$s_filter" "$s_value")
  fi
}

sql_update()
{
  echo "UPDATE $1 SET $2 WHERE $3;"
}
