run_select()
{
  gen_names
  gen_filters

  # default selector when passed through all
  # conditions above without column being set
  if [ -z $s_column ]; then s_column="*"; fi

  if [ "$1" = "-t" ]; then echo $table; fi
  exec_sql $(sql_select "$s_column" $table "$s_filter")
}

gen_names()
{
  # if filter but no columns, set names to filter
  if [ -n "$s_filter" ] && [ -z "$s_column" ]; then
    s_name=$(echo ${s_filter[@]})
    # if column but no filter, set names to column
  elif [ -n "$s_column" ] && [ -z "$s_filter" ]; then
    s_name=$(echo ${s_column[@]})
    # default names to whatever is in the table
  else
    fields=$(sql_fields $table)
    s_name=$(echo ${fields[@]})
  fi
}

gen_filters()
{
  # generate filter segment of the sql
  if [ -n "$s_value" ]; then
    if [ -z "$s_filter" ]; then
      s_filter=$(filter_loose or "$s_name" "$s_value")
    else
      s_filter=$(filter_strict or "$s_name" "$s_value")
    fi
  fi
}

sql_select()
{
  if [ -z "$3" ]
  then
    echo "SELECT $1 FROM $2;"
  else
    echo "SELECT $1 FROM $2 WHERE $3;"
  fi
}
