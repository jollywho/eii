run_insert()
{
  # exit if no values supplied
  if [ -z "$s_value" ]; then
    exit
  fi

   fields=$(sql_fields $table)
   s_name=$(echo ${fields[@]})
}

sql_insert()
{
   echo "INSERT INTO $1 VALUES ( $2 );"
}
