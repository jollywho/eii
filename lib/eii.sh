#!/bin/bash
source functions.sh
source options.sh
source select.sh
source insert.sh
#━━━━━━━━━━━━━━━━━━━━━━━━━(Main)━━━━━━━━━━━━━━━━━━━━━━━━━━━━
run "$@"

#Disable file name generation using metacharacters
set -f

# exit if no option set
if [ -z $option ]; then
  exit
fi
# generate tables if none supplied
if [ -z "$tables" ]; then
  table_data
fi

for table in ${tables[@]}
do
  s_filter=$(echo ${filters[@]} | tr " " ",")
  s_column=$(echo ${columns[@]} | tr " " ",")
  s_value=$(echo -e ${values[@]})

  if [ $option == "-s" ]; then
    run_select
  elif [ $option == "-i" ]; then
    # eii -i -t book -v j j j
    # field names for table
    # compare column with values
    run_insert
  elif [ $option == "-u" ]; then
    echo
  elif [ $option == "-d" ]; then
    # eii -d -t book | -c name | -v name_02
    # need filters and values; exit without
    echo
  fi
done
