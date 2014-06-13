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

gen_filter_strict()
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

gen_filter_loose()
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
    if [ "$i" -eq "$1" ]; then
      echo "Found"
    else
      echo "Not Found"
    fi
  done
}
