db=../../bin/eib.db
touch $db

exec_sql()
{
  echo $@
  sqlite3 --batch $db "$*"
}

gen_vals()
{
  for i in $(seq 1 $2)
  do
    exec_sql "INSERT INTO $1 VALUES (null,'"name_$i"','"$i"',4,5);"
  done
}

gen_vals book 5
gen_vals anime 10
gen_vals movie 3
gen_vals tv 7
