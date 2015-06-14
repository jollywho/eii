cmd()
{
  case "$1" in
    select)
      option="-s"
      ;;
    insert)
      option="-i"
      ;;
    update)
      option="-u"
      ;;
    delete)
      option="-d"
      ;;
    list|ls)
      option="-l"
      ;;
    colshow|cl)
      option="-cl"
      ;;
  esac
}

tables()
{
  t=$(echo "${@:2}" | cut -d "-" -f1)
  if [ -n "${t}" ]; then
    read_s_args tables "${t}"
  fi
}

opts()
{
  while (($#)); do
    case "$1" in
      -h|--help)
        usage
        exit
        ;;
#━━━━━━━━━━━━━━━━━━━━━━━(Selectors)━━━━━━━━━━━━━━━━━━━━━━━━━
      -c|--column)
        read_s_args columns ${@:2}
        ;;
      -f|--filter)
        read_s_args filters ${@:2}
        ;;
      -n|--values)
        read_s_args newvalues "${@:2}"
        ;;
      -v|--values)
        read_s_args values "${@:2}"
        ;;
#━━━━━━━━━━━━━━━━━━━━━━━(Misc)━━━━━━━━━━━━━━━━━━━━━━━━━
      -db|--database)
        db="${@:2:1}"
        shift
        ;;
      -x|--exact)
        USEXACT=true
        ;;
      -r|--rowid)
        USEROW=true
        ;;
      -a|--asknope)
        USEASK=true
        ;;
      -tn|--tablename)
        USETNAME=true
        ;;
    esac
    shift
  done
}
