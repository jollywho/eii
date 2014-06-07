db=../../bin/eib.db
touch $db

exec_sql()
{
  sqlite3 --batch $db "$*"
}

sql_drop="
DROP TABLE books;"

sql_create="
CREATE TABLE book (
  id INTEGER PRIMARY KEY,
  name TEXT,
  writer TEXT,
  date TEXT,
  version TEXT
);
CREATE TABLE movie (
  id INTEGER PRIMARY KEY,
  name TEXT,
  director TEXT,
  writer TEXT,
  date TEXT
);
CREATE TABLE anime (
  id INTEGER PRIMARY KEY,
  name TEXT,
  writer TEXT,
  date TEXT,
  episodes NUMBER
);
CREATE TABLE tv (
  id INTEGER PRIMARY KEY,
  name TEXT,
  writer TEXT,
  date TEXT,
  episodes NUMBER
);"

sql_insert="
INSERT INTO master VALUES ( null, $2, $3, $4, $5 );"
exec_sql "$sql_create"
if [ "$1" = "-n" ]
then
  echo new
  exec_sql "$sql_drop"
elif [ "$1" = "-i" ]
then
  echo insert
  exec_sql "$sql_insert"
fi
