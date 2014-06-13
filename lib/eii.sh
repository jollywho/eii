#!/bin/bash
source functions.sh
source options.sh
#━━━━━━━━━━━━━━━━━━━━━━━━━(Main)━━━━━━━━━━━━━━━━━━━━━━━━━━━━
run "$@"

if [ -z $option ]; then
  exit
elif [ $option == "-s" ]; then
  set -f

  # generate tables if none supplied
  if [ -z "$tables" ]; then
    table_data
  fi

  for table in ${tables[@]}
  do
    s_filter=$(echo ${filters[@]} | tr " " ",")
    s_column=$(echo ${columns[@]} | tr " " ",")
    s_value=$(echo -e ${values[@]})

    # if filter but no columns, set names to filter
    if [ -n "$s_filter" ] && [ -z "$s_column" ]; then
      s_name=$(echo ${s_filter[@]})
    # if column, set names to it
    elif [ -n "$s_column" ]; then
      s_name=$(echo ${s_column[@]})
    else
      fields=$(sql_fields $table)
      s_name=$(echo ${fields[@]})
    fi

    # generate filter segment of the sql
    if [ -n "$s_value" ]; then
      if [ -z "$s_filter" ]; then
        s_filter=$(gen_filter_loose or "$s_name" "$s_value")
      else
        s_filter=$(gen_filter_strict or "$s_name" "$s_value")
      fi
    fi

    # default selector when passed through all
    # conditions above without column being set
    if [ -z $s_column ]; then s_column="*"; fi

    exec_sql $(sql_select "$s_column" $table "$s_filter")
  done
fi
