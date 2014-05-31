db=../../bin/eib.db
touch $db

exec_sql()
{
  sqlite3 --batch $db "$*"
}

sql_drop="
DROP TABLE books;"

sql_create="
CREATE TABLE master (
  id INTEGER PRIMARY KEY,
  name TEXT,
  author TEXT,
  year TEXT,
  version TEXT
);"

sql_insert="
INSERT INTO master VALUES ( null, $2, $3, $4, $5 );"

if [ "$1" = "-n" ]
then
  echo new
  exec_sql "$sql_drop"
elif [ "$1" = "-i" ]
then
  echo insert
  exec_sql "$sql_insert"
fi
