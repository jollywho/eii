run_insert()
{
  # exit if no values supplied
  if [ -z "$s_value" ]; then
    exit
  fi

  # count # of fields
  fields=$(sql_fields $table)
  s_name=$(echo ${fields[@]})
  count=$(echo $s_name | tr -cd , | wc -c)
  c_count=$((count+1))

  v_count=($s_value)
  v_count=${#v_count[@]}

  # if enough values supplied for existing fields
  if [ $c_count -eq $v_count ]; then
    echo ok
  fi
}

sql_insert()
{
   echo "INSERT INTO $1 VALUES ( $2 );"
}
