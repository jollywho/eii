db=../bin/eib.db

exec_sql()
{
  sqlite3 --batch $db "$*"
}

sql_drop="
DROP TABLE books;"

sql_create="
CREATE TABLE books (
  id INTEGER PRIMARY KEY,
  name TEXT,
  authors TEXT,
  year TEXT,
  edition TEXT
);
"

if [ "$1" = "-n" ]
then
  exec_sql "$sql_drop"
fi
exec_sql "$sql_create"
