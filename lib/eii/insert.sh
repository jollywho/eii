db=../../bin/eib.db
touch $db

exec_sql()
{
  sqlite3 --batch $db "$*"
}

gen_vals()
{
  for i in {1..50}
  do
    exec_sql "INSERT INTO $1 VALUES (null,2,3,4,5);"
  done
}

gen_vals book
gen_vals anime
gen_vals movie
