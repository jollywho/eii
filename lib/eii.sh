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
  if [ -z $tables ];
  then
    echo wa
  fi

  #todo: loop tables

  if [ -z "$filters" ] && [ -n "$values" ]
  then
    table_data
    m=$(echo "${tables[1]}")
    fields=$(eval echo "$"$m"")

#fixme: concat_sql can't take an array without breaking
#       the third parameter. fix by sending values as csv
#       and parse it from within function

    filters=$(concat_sql $fields ${values[@]} or)
  fi
  if [ -z $columns ]; then columns="*"; fi

  exec_sql $(sql_select $columns ${tables[1]} "$filters")
fi
