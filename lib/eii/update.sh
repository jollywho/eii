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

  tmp="${s_column}"
  s_column="*"
  records=$(run_select)
  s_column="${tmp}"

  [ $usetname ] && tname_os=-1
  ((num=$(echo "${records}" | wc -l)${tname_os}))
  if [ $num -eq 0 ]; then
    echo "update will affect ${num} records."
    return
  fi
  gen_updates
  gen_update_filters

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
