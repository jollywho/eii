db=../bin/eib.db
res=$(
  sqlite3 $db << EOF
  SELECT count(*) FROM books;
EOF
)
echo $res
