#!/usr/bin/bash
EII=${BASH_SOURCE[0]}
EIIDIR=$(dirname ${EII})/eii

. ${EIIDIR}/functions.sh
. ${EIIDIR}/options.sh
. ${EIIDIR}/select.sh
. ${EIIDIR}/insert.sh
. ${EIIDIR}/delete.sh
. ${EIIDIR}/update.sh
#━━━━━━━━━━━━━━━━━━━━━━━━━(Main)━━━━━━━━━━━━━━━━━━━━━━━━━━━━
db="${EIIDIR}/../../bin/eii.db"
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
  s_newvalue=$(echo -e ${newvalues[@]})
  s_filter=$(echo ${filters[@]} | tr " " ",")
  s_column=$(echo ${columns[@]} | tr " " ",")
  s_value=$(echo -e ${values[@]})

  if [ $option == "-s" ]; then
    run_select
  elif [ $option == "-i" ]; then
    run_insert
  elif [ $option == "-u" ]; then
    run_update
  elif [ $option == "-d" ]; then
    run_delete
  fi
done
