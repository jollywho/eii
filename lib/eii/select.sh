db=../../bin/eib.db
res=$(
  sqlite3 $db << EOF
  SELECT count(*) FROM master;
EOF
)
echo $res
