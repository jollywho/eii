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
  while (($#)) && [[ $2 != -* ]] && [[ $2 != '' ]]
  do
      if [ $var = "tables" ]; then
        tables+=("$2")
      elif [ $var = "columns" ]; then
        columns+=("$2")
      elif [ $var = "filters" ]; then
        filters+=("$2")
      elif [ $var = "values" ]; then
        x=$(printf "'%s'" "$2")
        values+=("$x")
      fi
    shift
  done
}

concat_sql()
{
  local oper=$1
  local columns=$(echo $2 | tr "," " ")
  local count=0
  eval local values=($3)

  # -f does not 1:1 filter:value
  for name in ${columns[@]}
  do
    for ea in "${values[@]}"
    do
      local sql+=" $name = '$ea' $oper"
    done
    ((count++))
  done

  str=$(printf 's/%s$//g' $oper)
  echo $sql | sed $str
}

exec_sql()
{
  local db=../bin/eib.db
  touch $db
  local res=$(sqlite3 --batch $db "$*")
  if [ -n "$res" ]
  then
    echo $table
    echo "$(echo "$res")"
  fi
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

conta()
{
  echo $@
  for i in "echo ${@:2} | cut -d ',' - f2"
  do
    echo $i
  done
}
