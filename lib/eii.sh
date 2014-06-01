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
  sargs+=("$1")
  shift
  done
}

if [ -z $1 ]
then
  usage
fi

while getopts ":s:i:u:d:l:h" o; do
    case "${o}" in
        h)
            usage
            ;;
        s)
            read_s_args ${@:2}
            if [ ${#sargs[@]} -eq 4 ]
            then
            reader ${sargs[@]:1}
            echo $title
            echo $year
            echo $author
          else
            echo wrong number of args. Expecting 4, got ${#sargs[@]}.
            usage
          fi
            ;;
        i)
            arg=${OPTARG}
            echo $arg
            ;;
        u)
            arg=${OPTARG}
            echo $arg
            ;;
        d)
            arg=${OPTARG}
            echo $arg
            ;;
        l)
            arg=${OPTARG}
            echo $arg
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
done
