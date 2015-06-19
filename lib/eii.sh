#!/usr/bin/bash
EII=${BASH_SOURCE[0]}
CONFILE=$HOME/.eii/eii.conf
declare -A dbs
#━━━━━━━━━━━━━━━━━━━━━━━(Functions)━━━━━━━━━━━━━━━━━━━━━━━━━
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
    elif [ $var = "newvalues" ]; then
      # simple way to handle spaces in quotes
      x=$(printf "'%s'" "$2")
      newvalues+=("$x")
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
    if [ $USEXACT ]; then
      local sql+=" $name ='${values[$c]}' $oper"
    else
      local sql+=" $name like '%${values[$c]}%' $oper"
    fi
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
      if [ $USEXACT ]; then
        local sql+=" $name = '$value' $oper"
      else
        local sql+=" $name like '%$value%' $oper"
      fi
      # [WHERE] name = 'value' operator
    done
  done

  # remove trailing operator
  str=$(printf 's/%s$//g' $oper)
  echo $sql | sed $str
}

do_sql()
{
  touch $db
  sql="$*"
  local res=$(do_query "$sql")

  if [ ${USEHEADER} ]; then
    head=$(do_query_header "$sql" | head -n1)
    echo "$head"
  fi

  if [ -n "$res" ]; then
    echo "$res"
  fi
}

exec_sql()
{
  if [ ${USEHEADER} ]; then
    res=$(do_sql "$*" | column -t -s '|' -o ' | ')
  else
    res=$(do_sql "$*")
  fi

  if [ ${USECOLOROFF} ]; then
    echo "$res"
  else
    format "$res"
  fi
}

format()
{
  while read -r line; do
    if [ $i ]; then
      col='\033[32;40m'
      unset i
    elif [ ! $i ]; then
      col='\e[31m'
      i=1;
    fi
    echo -e "${col}$line\e[0m"
  done <<< "$*"
}

query_sql()
{
  touch $db
  do_query "$*"
}

do_query_header()
{
  echo "$(sqlite3 --header --batch $db "$* LIMIT 1")"
}

do_query()
{
  echo "$(sqlite3 --batch $db "$*")"
}

sql_tables()
{
  local sql="SELECT name FROM sqlite_master WHERE type = 'table'"
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
  local sql="PRAGMA table_info($1)"
  local res="$(query_sql "$sql")"
  echo "$res" | cut -d '|' -f2 | tr '\n' ',' | sed 's/,$//g'
}

#━━━━━━━━━━━━━━━━━━━━━━━(Conf)━━━━━━━━━━━━━━━━━━━━━━━━━
conf()
{
  IFS=" "
  while read -r line;  do
    set -- $line
    case $1 in
      database)
        # hash if valid file
        if [ -f `eval echo $3` ]; then
          dbs+=([$2]=`eval echo $3`)
        fi
        ;;
      default)
        # test if key in array
        test ${dbs[$2]+_} && db=${dbs[$2]}
        ;;
    esac
  done < $CONFILE
}

switch_db()
{
  # test if key in array
  if [ ${dbs[$1]+_} ]; then
    # set and replace in conf
    db=$1
    sed -i "s/^default.*$/default $db/" $CONFILE
  fi
}

cmd()
{
  case "$1" in
    select)
      option="-s"
      ;;
    insert)
      option="-i"
      ;;
    update)
      option="-u"
      ;;
    delete)
      option="-d"
      ;;
    list|ls)
      option="-l"
      ;;
    showcol|shc)
      option="-cl"
      ;;
    showdb|shdb)
      option="-dl"
      ;;
    switch-to)
      option="-chdb"
      ;;
  esac
}

tables()
{
  t=$(echo "${@:2}" | cut -d "-" -f1)
  if [ -n "${t}" ]; then
    read_s_args tables "${t}"
  fi
}

opts()
{
  while (($#)); do
    case "$1" in
#━━━━━━━━━━━━━━━━━━━━━━━(Selectors)━━━━━━━━━━━━━━━━━━━━━━━━━
      -c|--column)
        read_s_args columns ${@:2}
        ;;
      -f|--filter)
        read_s_args filters ${@:2}
        ;;
      --set)
        read_s_args columns "${@:2}"
        ;;
      --to)
        read_s_args newvalues "${@:2}"
        ;;
      -v|--value)
        read_s_args values "${@:2}"
        ;;
#━━━━━━━━━━━━━━━━━━━━━━━(Misc)━━━━━━━━━━━━━━━━━━━━━━━━━
      -db|--database)
        db="${@:2:1}"
        shift
        ;;
      -h|--header)
        USEHEADER=true
        ;;
      -co|--coloroff)
        USECOLOROFF=true
        ;;
      -x|--exact)
        USEXACT=true
        ;;
      -r|--rowid)
        USEROW=true
        ;;
      -a|--asknope)
        USEASK=true
        ;;
      -tn|--tablename)
        USETNAME=true
        ;;
    esac
    shift
  done
}

run_select()
{
  gen_sel_names
  gen_sel_filters

  # default selector when passed through all
  # conditions above without column being set
  if [ -z $s_column ]; then s_column="*"; fi

  [ $USETNAME ] && echo $table
  exec_sql $(sql_select "$s_column" $table "$s_filter") | less
}

gen_sel_names()
{
  # if filter but no columns, set names to filter
  if [ -n "$s_filter" ] && [ -z "$s_column" ]; then
    s_name=$(echo ${s_filter[@]})
  # if column but no filter, set names to column
  elif [ -n "$s_column" ] && [ -z "$s_filter" ]; then
    s_name=$(echo ${s_column[@]})
  # if column and filter, set names to column
  elif [ -n "$s_column" ] && [ -n "$s_filter" ]; then
    s_name=$(echo ${s_column[@]})
  # default names to whatever is in the table
  else
    fields=$(sql_fields $table)
    s_name=$(echo ${fields[@]})
  fi
}

gen_sel_filters()
{
  # generate filter segment of the sql
  if [ -n "$s_value" ]; then
    if [ -n "$s_value" ] && [ -n "$s_filter" ]; then
      s_filter=$(filter_loose or "$s_filter" "$s_value")
    elif [ -z "$s_filter" ]; then
      s_filter=$(filter_loose or "$s_name" "$s_value")
    else
      s_filter=$(filter_strict or "$s_name" "$s_value")
    fi
  fi
}

sql_select()
{
  if [ -z "$3" ]
  then
    echo "SELECT $1 FROM $2"
  else
    echo "SELECT $1 FROM $2 WHERE $3"
  fi
}

run_insert()
{
  # exit if no values supplied
  if [ -z "$s_value" ]; then
    exit
  fi

  # count # of fields
  fields=$(sql_fields $table)
  s_name=$(echo ${fields[@]})
  count=$(echo $s_name | tr -cd , | wc -c)
  c_count=$((count-1))

  v_count=($s_value)
  v_count=${#v_count[@]}

  str_vals=($s_value)

  # if USEROW option
  if [ $USEROW ]; then
    prepa+=${str_vals[0]}
    str_vals=("${str_vals[@]:1}")
  else
    prepa+='null'
  fi

  # if one required field supplied;
  # add null or the supplied value
  # for the number of columns in the table
  if [ $v_count -gt 0 ]; then
    for i in $(seq 0 $c_count);
    do
      tmp=${str_vals[$i]}
      if [ -z $tmp ]; then
        msg+=" null"
      else
        msg+=" $tmp"
      fi
    done
    s_value=$(echo "$msg" | tr ' ' ',' )
    exec_sql $(sql_insert $table "$prepa" "$s_value")
  else
    echo "not enough values supplied"
  fi
}

sql_insert()
{
  echo "INSERT INTO $1 VALUES ( $2 $3 )"
}

run_delete()
{
  # exit if filter or value not supplied
  if [ -z "$s_filter" ] || [ -z "$s_value" ]; then
    echo "Delete requires -f and -v"
    exit
  fi

  tmp="${s_column}"
  s_column="*"
  records=$(run_select)
  s_column="${tmp}"

  [ $USETNAME ] && tname_os=-1
  ((num=$(echo "${records}" | wc -l)${tname_os}))
  if [ $num -eq 0 ]; then
    return
  fi

  gen_sel_filters

  echo "$records" | less

  if [ ! $USEASK ]; then
    read -r -p "$num record(s) will be deleted. Continue [y/N]? " choice
  else
    choice="Y"
  fi

  case $choice in
    [yY][eE][sS]|[yY])
      exec_sql $(sql_delete $table "$s_filter")
    ;;
  esac
}

gen_del_filters()
{
  # generate filter segment of the sql
  if [ -n "$s_value" ]; then
    s_filter=$(filter_strict or "$s_filter" "$s_value")
  fi
}

sql_delete()
{
  tbl=$1
  shift
  criteria=$@
  echo "DELETE FROM $tbl WHERE $criteria"
}

run_update()
{
  # exit if filter or value not supplied
  if
    [ -z "$s_newvalue" ] ||
    [ -z "$s_filter" ] ||
    [ -z "$s_value" ]; then
    echo "Update requires filter ..., set ..., to ..."
    exit
  fi

  tmp="${s_column}"
  s_column="*"
  records=$(run_select)
  s_column="${tmp}"

  [ $USETNAME ] && tname_os=-1
  ((num=$(echo "${records}" | wc -l)${tname_os}))
  if [ $num -eq 0 ]; then
    echo "update will affect ${num} records."
    return
  fi

  gen_updates
  gen_update_filters

  echo "$records" | less
  if [ ! $USEASK ]; then
    read -r -p "$num record(s) will be updated. Continue [y/N]? " choice
  else
    choice="Y"
  fi

  case $choice in
    [yY][eE][sS]|[yY])
      exec_sql $(sql_update $table "$s_updates" "$s_filter")
      ;;
  esac
}

gen_updates()
{
  # generate filter segment of the sql
  if [ -n "$s_newvalue" ]; then
    # store USEXACT state
    use=$USEXACT
    USEXACT=true
    s_updates=$(filter_strict and "$s_column" "$s_newvalue")
    # restore state
    USEXACT=$use
  fi
}

gen_update_filters()
{
  # generate filter segment of the sql
  if [ -n "$s_value" ]; then
    s_filter=$(filter_strict and "$s_filter" "$s_value")
  fi
}

sql_update()
{
  echo "UPDATE $1 SET $2 WHERE $3"
}

#━━━━━━━━━━━━━━━━━━━━━━━━━(Main)━━━━━━━━━━━━━━━━━━━━━━━━━━━━
conf
if [ -z $db ]; then
  echo "error loading database"
  exit
fi
cmd "$1"
opts "$@"
tables "$@"

# Disable file name generation using metacharacters
set -f

# exit if no option set
if [ -z $option ]; then
  exit
fi
# generate tables if none supplied
if [ -z "$tables" ]; then
  table_data
fi
# show table list if requested
if [ "$option" == "-l" ]; then
  exec_sql $(echo ".tables")
elif [ "$option" == "-dl" ]; then
  echo "${!dbs[@]}"
elif [ "$option" == "-chdb" ]; then
  switch_db "$tables"
elif [ "$option" == "-cl" ]; then
  echo $(sql_fields "$tables" | tr ',' ' ')
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
