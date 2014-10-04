run_delete()
{
  # exit if filter or value not supplied
  if [ -z "$s_filter" ] || [ -z "$s_value" ]; then
    echo "Delete requires -f and -v"
    exit
  fi

  tmp="${s_column}"
  s_column="*"
  records=$(run_select)
  s_column="${tmp}"

  [ $usetname ] && tname_os=-1
  ((num=$(echo "${records}" | wc -l)${tname_os}))
  if [ $num -eq 0 ]; then
    return
  fi
  echo "$records"
  gen_del_filters
  read -r -p "$num record(s) will be deleted. Continue [y/N]? " choice

  case $choice in
    [yY][eE][sS]|[yY])
    exec_sql $(sql_delete $table "$s_filter")
    ;;
  esac
}

gen_del_filters()
{
  # generate filter segment of the sql
  if [ -n "$s_value" ]; then
    s_filter=$(filter_strict or "$s_filter" "$s_value")
  fi
}

sql_delete()
{
  tbl=$1
  shift
  criteria=$@
  echo "DELETE FROM $tbl WHERE $criteria;"
}
