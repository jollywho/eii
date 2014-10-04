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
  c_count=$((count-1))

  v_count=($s_value)
  v_count=${#v_count[@]}

  str_vals=($s_value)

  # if USEROW option
  if [ $USEROW ]; then
    prepa+=${str_vals[0]}
    str_vals=("${str_vals[@]:1}")
  else
    prepa+='null'
  fi

  # if one required field supplied;
  # add null or the supplied value
  # for the number of columns in the table
  if [ $v_count -gt 0 ]; then
    for i in $(seq 0 $c_count);
    do
      tmp=${str_vals[$i]}
      if [ -z $tmp ]; then
        msg+=" null"
      else
        msg+=" $tmp"
      fi
    done
    s_value=$(echo "$msg" | tr ' ' ',' )
    exec_sql $(sql_insert $table "$prepa" "$s_value")
  else
    echo "not enough values supplied"
  fi
}

sql_insert()
{
  echo "INSERT INTO $1 VALUES ( $2 $3 );"
}
