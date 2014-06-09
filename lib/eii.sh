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

  if [ -z "$tables" ];
  then
    echo gen tables
    table_data
  fi

   table_data
  #todo: loop tables

  filters=$(echo ${filters[@]} | tr " " ",")
  columns=$(echo ${columns[@]} | tr " " ",")

  # has no columns && has values
  if [ -z "$columns" ] && [ -n "$values" ]
  then
    # generate columns for table
    columns=$(eval echo "$"$m"" | tr " " ",")
    m=$(echo "${tables[1]}") #single table for debug
    concat_sql or $columns $values}
    #filters=$(concat_sql ${fields[@]} ${values[@]} or)
  fi

  # has filters
  if [ -n "$filters" ]
  then
    # has no columns
    if [ -n "$columns" ]
    then
      columns=$(echo ${filters[@]} | tr " " ",")
    fi
  fi

  # if nothing above set columns, use wildchar
  if [ -z $columns ]; then columns="*"; fi

  exec_sql $(sql_select $columns ${tables[1]} "$filters")
fi
