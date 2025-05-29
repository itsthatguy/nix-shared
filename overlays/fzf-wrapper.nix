final: prev: {
  fzfWrapper = final.writeShellScriptBin "fzf" ''
    #!${final.stdenv.shell}
    # detect whether this is kubens vs kubectx vs anything else
    REAL_FZF=${final.fzf}/bin/fzf

    # upstream sets FZF_DEFAULT_COMMAND to SELF_CMD (path to kubens or kubectx)
    case "$FZF_DEFAULT_COMMAND" in
      *"/kubens")
        # only feed namespaces for kubens
        exec "$REAL_FZF" "$@" < <(kubectl get namespaces -o=jsonpath='{range .items[*].metadata.name}{@}{"\n"}{end}')
        ;;
      *)
        # all other calls behave normally
        exec "$REAL_FZF" "$@"
        ;;
    esac
  '';}
