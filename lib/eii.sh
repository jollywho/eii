#!/bin/bash

usage()
{
  echo "usage: $0 [-s <table> <title> <year> <author>]" 1>&2;
  echo
  echo "  s : select all matching entries"
  echo "  u : update all matching entries"
  echo "  d : delete all matching entries"
  echo "  i : insert new entries"
  echo "  l : list tables"
  exit 1;
}

title=
year=
author=

count=

reader()
{
  ary=($@)
  title=${ary[0]}
  year=${ary[1]}
  author=${ary[2]}
}

read_s_args()
{
  while (($#)) && [[ $1 != -* ]]
  do
    ((count++))
    sargs+=("$1")
    shift
  done
}

exec_sql()
{
  db=../bin/eib.db
  dbrc=eiirc
  touch $db
  res=$(sqlite3 --init $dbrc --batch $db "$*")
  echo "$res" | less -R
}

query_sql()
{
  db=../bin/eib.db
  touch $db
  res=$(sqlite3 --batch $db "$*")
}

sql_tables()
{
  sql="SELECT name FROM sqlite_master
  WHERE type = 'table';"
  query_sql "$sql"
  sql_fields "$res"
}

sql_fields()
{
  sql="PRAGMA table_info($1);"
  query_sql "$sql"
  fields=$(echo "$res" | cut -d '|' -f2)
}

sql_select()
{
  sql="SELECT * FROM $1 WHERE $2 = $3;"
  echo "$sql"
}

sql_insert()
{
  if [ -z $4 ]; then ver='1'; else ver=$4; fi;
    sql="INSERT INTO master VALUES
    ( null, '$1', '$2', '$3', '$ver');"
  }

  if [ -z $1 ]
  then
    usage
  fi

  count=

  while (($#)); do
    case "$1" in
      -h)
          usage
          ;;
      -s)
          read_s_args ${@}
          sql_select ${@:2}
          exec_sql "$sql"
          ;;
      -i)
          read_s_args ${@:2}
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
      -u)
        arg=${OPTARG}
        echo $arg
        ;;
      -d)
        arg=${OPTARG}
        echo $arg
        ;;
      -l)
        echo "||||||||||||"
        ;;
      :)
        echo argument required
        usage
        ;;
      \?)
        echo invalid option
        usage
        ;;
    esac
    shift
    for i in $count
    do
      shift
    done
  done
