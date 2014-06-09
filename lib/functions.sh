
#━━━━━━━━━━━━━━━━━━━━━━━(Functions)━━━━━━━━━━━━━━━━━━━━━━━━━
usage() { cat usage; }

read_s_args()
{
  if [ -z "$2" ]
  then
    echo "$1: argument required."
    exit
  fi
  local var="$1"
  while (($#)) && [[ $2 != -* ]]
  do
    eval "$var+=("$2")"
    shift
  done
}

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
    sql+=" $s = '${values[$count]}' $ch"
    ((count++))
  done
  echo $sql | sed 's/or$//g'
}

exec_sql()
{
  echo $@
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
