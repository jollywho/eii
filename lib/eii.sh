#!/bin/bash
source functions.sh
source options.sh

#━━━━━━━━━━━━━━━━━━━━━━━━━(Main)━━━━━━━━━━━━━━━━━━━━━━━━━━━━

run $@

if [ -z $option ]
then
  exit
elif [ $option == "-s" ]
then

  echo _____run_____
  set -f

  # generate tables if none supplied
  if [ -z "$tables" ];
  then
    table_data
  fi

  for table in ${tables[@]}
  do
    s_filter=$(echo ${filters[@]} | tr " " ",")
    s_column=$(echo ${columns[@]} | tr " " ",")
    s_value=$(echo ${values[@]})

    if [ -z "$s_filter" ] && [ -z "$s_column" ]
    then
      # generate columns for table
      eval "$table=$(sql_fields $table)"
      s_column=$(eval echo "$"$table"" | tr " " ",")
    fi

    # use columns as filter
    if [ -n "$s_filter" ] && [ -z "$s_column" ]
    then
      s_column=$(echo ${s_filter[@]})
    fi

    if [ -n "$s_value" ]
    then
      if [ -z "$s_filter" ]
      then
        s_filter=$(concat_sql or $s_column $s_value)
      else
        s_filter=$(concat_sql and $s_column $s_value)
      fi
    fi

    if [ -z $s_column ]; then columns="*"; fi

    exec_sql $(sql_select "$s_column" $table "$s_filter")
  done
fi
