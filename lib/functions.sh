#━━━━━━━━━━━━━━━━━━━━━━━(Functions)━━━━━━━━━━━━━━━━━━━━━━━━━
usage() { cat usage; }

read_s_args()
{
  if [ -z "$2" ]
  then
    echo "$1: argument required."
    exit
  fi

  # argument type
  local var="$1"

  # while arguments remain or new option or blank
  while (($#)) && [[ $2 != -* ]] && [[ $2 != '' ]]
  do
    if [ $var = "tables" ]; then
      tables+=("$2")
    elif [ $var = "columns" ]; then
      columns+=("$2")
    elif [ $var = "filters" ]; then
      filters+=("$2")
    elif [ $var = "values" ]; then
      # simple way to handle spaces in quotes
      x=$(printf "'%s'" "$2")
      values+=("$x")
    fi
    shift
  done
}

filter_strict()
{
  local oper=$1
  local names=$(echo $2 | tr "," " ")
  eval local values=($3)
  local c=0

  # for each name in names list create sql string
  # with the aligning value in the values list
  for name in ${names[@]}
  do
      # [WHERE] name = 'value' operator
      local sql+=" $name = '${values[$c]}' $oper"
      ((c++))
  done

  # remove trailing operator
  str=$(printf 's/%s$//g' $oper)
  echo $sql | sed $str
}

filter_loose()
{
  local oper=$1
  local names=$(echo $2 | tr "," " ")
  eval local values=($3)

  # for each name in names list, create sql string
  # with every value in the values list
  for name in ${names[@]}
  do
    for value in "${values[@]}"
    do
      # [WHERE] name = 'value' operator
      local sql+=" $name = '$value' $oper"
    done
  done

  # remove trailing operator
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
}

sql_fields()
{
  local sql="PRAGMA table_info($1);"
  local res="$(query_sql "$sql")"
  echo "$res" | cut -d '|' -f2 | tr '\n' ',' | sed 's/,$//g'
}
