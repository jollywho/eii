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
        arg=${OPTARG}
        echo $arg
        ;;
      -d|--delete)
        arg=${OPTARG}
        echo $arg
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
      -v|--values)
        read_s_args values "${@:2}"
        ;;
    esac
    shift
  done
}
