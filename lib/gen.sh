gen_names()
{
    # if filter but no columns, set names to filter
    if [ -n "$s_filter" ] && [ -z "$s_column" ]; then
      s_name=$(echo ${s_filter[@]})
    # if column but no filter, set names to column
    elif [ -n "$s_column" ] && [ -z "$s_filter" ]; then
      s_name=$(echo ${s_column[@]})
    # default names to whatever is in the table
    else
      fields=$(sql_fields $table)
      s_name=$(echo ${fields[@]})
    fi
}

gen_filters()
{
  # generate filter segment of the sql
  if [ -n "$s_value" ]; then
    if [ -z "$s_filter" ]; then
      s_filter=$(filter_loose or "$s_name" "$s_value")
    else
      s_filter=$(filter_strict or "$s_name" "$s_value")
    fi
  fi
}