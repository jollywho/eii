
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
  echo $@
  local oper=$1
  local columns=$(echo $2 | tr "," " ")
  local count=0

  if [ $oper = 'or' ] # no filter
  then
    # concat values with operator
    for ea in ${@:3}
    do
      str+="'$ea' or "
    done
    values=$(echo $str | sed 's/or$//g')
  else
    local values=$(echo ${@:3} | tr "," " ")
  fi

  for name in ${columns[@]}
  do
    local sql+=" $name = $values $oper"
    ((count++))
  done

  str=$(printf 's/%s$//g' $oper)
  echo $sql | sed $str
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
