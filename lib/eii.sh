#!/bin/bash

#━━━━━━━━━━━━━━━━━━━━━━━(Functions)━━━━━━━━━━━━━━━━━━━━━━━━━
usage() { cat usage; }

read_s_args()
{
  if [ -z "$2" ]
  then
    echo $1: argument required.
    exit
  fi
  local var="$1"
  while (($#)) && [[ $2 != -* ]]
  do
    eval "$var+=("$2")"
    shift
  done
}

exec_sql()
{
  db=../bin/eib.db
  touch $db
  res=$(sqlite3 --batch $db "$*")
  echo "$(echo "$res")"
}

query_sql()
{
  db=../bin/eib.db
  touch $db
  echo "$(sqlite3 --batch $db "$*")"
}

sql_tables()
{
  sql="SELECT name FROM sqlite_master
    WHERE type = 'table';"
  pool=' ' read -a res <<< $(query_sql "$sql")
  echo ${res[@]}
}

table_data()
{
  res=$(sql_tables)
  x=($res)
  for t in "${x[@]}"
  do
    m=$(sql_fields "$t")
    eval "$t=($m)"
  done
}

sql_fields()
{
  sql="PRAGMA table_info($1);"
  res="$(query_sql "$sql")"
  echo "$res" | cut -d '|' -f2 | tr '\n' ',' | sed 's/,$//g'
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

sql_insert()
{
  if [ -z $4 ]; then ver='1'; else ver=$4; fi;
    sql="INSERT INTO master VALUES
    ( null, '$1', '$2', '$3', '$ver');"
}
#━━━━━━━━━━━━━━━━━━━━━━━━(Options)━━━━━━━━━━━━━━━━━━━━━━━━━━
while (($#)); do
  case "$1" in
    -h|--help)
      usage
      exit
      ;;
    -s|--select)
      option="-s"
      ;;
    -i|--insert)
      read_s_args ${@}
      if [ ${#sargs[@]} -eq 4 -o 5 ]
      then
        reader ${sargs[@]:1}
        sql_insert ${sargs[@]:1}
        exec_sql $sql
      else
        echo "wrong number of args.
        Expecting [4||5], got ${#sargs[@]}."
        usage
      fi
      ;;
    -u|--update)
      arg=${OPTARG}
      echo $arg
      ;;
    -d|--delete)
      arg=${OPTARG}
      echo $arg
      ;;
    -l|--list)
      echo "||||||||||||"
      ;;
#━━━━━━━━━━━━━━━━━━━━━━━(Selectors)━━━━━━━━━━━━━━━━━━━━━━━━━
    -t|--table)
      read_s_args tables ${@:2}
      ;;
    -c|--column)
      read_s_args columns ${@:2}
      ;;
    -f|--filter)
      read_s_args filters ${@:2}
      ;;
    -v|--values)
      read_s_args values ${@:2}
      ;;
  esac
  shift
done
#━━━━━━━━━━━━━━━━━━━━━━━━━(Main)━━━━━━━━━━━━━━━━━━━━━━━━━━━━

concat_sql()
{
  column=$(echo $1 | tr "," " ")
  ch=$3
  count=0

  if [ ${#1} -ne ${#2} ]
  then
    rep=$(for i in ${column[@]};do echo "$2,";done;)
    values=($(echo $rep | tr "," " "))
  else
    values=$(echo $2 | tr "," " ")
  fi

  for s in ${column[@]}
  do
    sql+=" $s = ${values[$count]} $ch"
    ((count++))
  done
  echo $sql | sed 's/or$//g'
}

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

  if [ -z "$filters" ] && [ -n "$values" ]
  then
    table_data
    m=$(echo "${tables[1]}")
    fields=$(eval echo "$"$m"")
    filters=$(concat_sql $fields ${values[@]} or)
  fi
  if [ -z $columns ]; then columns="*"; fi

  #todo: loop tables
  sql_select $columns ${tables[1]} "$filters"
  exec_sql $(sql_select $columns ${tables[1]} $filters)
  #exec_sql $(sql_select $columns ${tables[0]} $filters $values)
fi
