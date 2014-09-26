db=eii.db
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
  name TEXT UNIQUE,
  episodecount TEXT,
  date TEXT,
  type TEXT,
  writer TEXT,
  version TEXT
);

CREATE TABLE file (
  master_id INTEGER NOT NULL,
  filename TEXT NOT NULL,
  episode TEXT,
  subs TEXT,
  checksum TEXT,
  FOREIGN KEY (master_id) REFERENCES master(id),
  PRIMARY KEY (master_id, episode)
  );
"

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
