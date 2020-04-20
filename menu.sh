#!/usr/bin/bash

trap '' 2
export LANG=en_US.UTF-8
export KUBECONFIG=/kubeconfig

unset LINES COLUMNS
DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=0
WIDTH=0

display_result() {
  dialog --title "$1" \
    --no-collapse \
    --msgbox "$result" 0 0
}

menu_top() {
  while true; do
    exec 3>&1
    selection=$(dialog \
      --title "Menu" \
      --clear \
      --cancel-label "Exit" \
      --menu "" $HEIGHT $WIDTH 4 \
      "1" "Deploy application" \
      2>&1 1>&3)
    exit_status=$?
    exec 3>&-
    case $exit_status in
      $DIALOG_CANCEL)
        clear
        echo "Program terminated."
        break
        ;;
      $DIALOG_ESC)
        clear
        echo "Program aborted." >&2
        break
        ;;
    esac
    case $selection in
      0 )
        clear
        echo "Program terminated."
        ;;
      1 )
        menu_deploy
        break
        ;;
    esac
  done
}

menu_deploy() {
  while true; do
    exec 3>&1
    selection=$(dialog \
      --title "Deploy application" \
      --clear \
      --cancel-label "Exit" \
      --menu "" $HEIGHT $WIDTH 4 \
      "1" "MySQL" \
      "2" "PostgreSQL" \
      2>&1 1>&3)
    exit_status=$?
    exec 3>&-
    case $exit_status in
      $DIALOG_CANCEL)
        clear
        echo "Program terminated."
        break
        ;;
      $DIALOG_ESC)
        clear
        echo "Program aborted." >&2
        break
        ;;
    esac
    case $selection in
      0 )
        clear
        echo "Program terminated."
        ;;
      1 )
        result=$(kubectl apply -f /assets/deploy_mysql.yml)
        display_result "Deploy MySQL"
        ;;
      2 )
        result=$(kubectl apply -f /assets/deploy_postgres.yml)
        display_result "Deploy PostgreSQL"
        ;;
    esac
  done
}

menu_top

tmux kill-server
