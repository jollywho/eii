
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
  local column=$(echo $1 | tr "," " ")
  local ch=$3
  local count=0

  if [ ${#1} -ne ${#2} ]
  then
    local rep=$(for i in ${column[@]};do echo "$2,";done;)
    local values=($(echo $rep | tr "," " "))
  else
    local values=$(echo $2 | tr "," " ")
  fi

  for s in ${column[@]}
  do
    local sql+=" $s = '${values[$count]}' $ch"
    ((count++))
  done
  echo $sql | sed 's/or$//g'
}

exec_sql()
{
  echo $@
  local db=../bin/eib.db
  touch $db
  local res=$(sqlite3 --batch $db "$*")
  echo "$(echo "$res")"
}

query_sql()
{
  local db=../bin/eib.db
  touch $db
  echo "$(sqlite3 --batch $db "$*")"
}

sql_tables()
{
  local sql="SELECT name FROM sqlite_master WHERE type = 'table';"
  local vars="$(query_sql "$sql")"
  echo "$vars"
}

table_data()
{
  local res=$(sql_tables)
  tables=($res)
  local x=($res)
  for t in "${x[@]}"
  do
    local m=$(sql_fields "$t")
    eval "$t=($m)"
  done
}

sql_fields()
{
  local sql="PRAGMA table_info($1);"
  local res="$(query_sql "$sql")"
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
    local sql="INSERT INTO master VALUES
    ( null, '$1', '$2', '$3', '$ver');"
  }
