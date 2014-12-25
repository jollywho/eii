run()
{
  #━━━━━━━━━━━━━━━━━━━━━━━━(Options)━━━━━━━━━━━━━━━━━━━━━━━━━━
  while (($#)); do
    case "$1" in
      -h|--help)
        usage
        exit
        ;;
      -s|--select)
        option="-s"
        ;;
      -i|--insert)
        option="-i"
        ;;
      -u|--update)
        option="-u"
        ;;
      -d|--delete)
        option="-d"
        ;;
      -l|--list)
        echo "||||||||||||"
        ;;
#━━━━━━━━━━━━━━━━━━━━━━━(Selectors)━━━━━━━━━━━━━━━━━━━━━━━━━
      -t|--table)
        read_s_args tables ${@:2}
        ;;
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
