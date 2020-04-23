#!/usr/bin/bash

trap '' 2
export LANG=en_US.UTF-8
export KUBECONFIG=/kubeconfig

unset LINES COLUMNS
DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=0
WIDTH=0
NC='\033[0m'
BOLD='\033[1m'
LOG=/log
echo -ne "$BOLD# ">$LOG

display_info() {
  dialog --title "$1" \
    --no-collapse \
    --msgbox "$2" $HEIGHT $WIDTH
}

run_master() {
  echo -e "$1$NC" >>$LOG
  eval $1 >>$LOG 2>&1
  echo -ne "$BOLD# ">>$LOG
}

menu_top() {
  while true; do
    exec 3>&1
    selection=$(dialog \
      --title "Menu" \
      --clear \
      --cancel-label "Exit" \
      --menu "" $HEIGHT $WIDTH 4 \
      "1" "Failover" \
      2>&1 1>&3)
    exit_status=$?
    exec 3>&-
    case $exit_status in
      $DIALOG_CANCEL)
        clear
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
        menu_failover
        ;;
    esac
  done
}

menu_failover() {
  while true; do
    exec 3>&1
    selection=$(dialog \
      --title "Failover" \
      --clear \
      --cancel-label "Exit" \
      --menu "" $HEIGHT $WIDTH 4 \
      "1" "PostgreSQL" \
      "2" "MySQL" \
      2>&1 1>&3)
    exit_status=$?
    exec 3>&-
    case $exit_status in
      $DIALOG_CANCEL)
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
        test_failover_postgres
        ;;
      2 )
        test_failover_mysql
        ;;
    esac
  done
}

create_demo_panes() {
  tmux split-window -d -h "tail -s 0.1 -f $LOG"
  tmux split-window -d
}

destroy_demo_panes() {
  tmux kill-pane -t 1
  tmux kill-pane -t 1
}

test_failover_postgres() {
  create_demo_panes
  display_info "Deploy PostgreSQL" "First, we will deploy PostgreSQL"
  run_master "kubectl apply -f /assets/deploy_postgres.yml"
  run_master "kubectl wait pod -lapp=postgres --for=condition=ready --timeout=120s"
  display_info "Get pods" "Now, let's look at the pods to see where PostgreSQL was provisioned"
  run_master "kubectl get pods -lapp=postgres -o wide"
  node=$(kubectl get pods -lapp=postgres -A -o=custom-columns='DATA:spec.nodeName' --no-headers)
  display_info "Cordon node" "Next, we will cordon the node"
  run_master "kubectl cordon $node"
  display_info "Delete pod" "Now, we can delete the pod and watch it scheduled on another node"
  run_master "kubectl delete pod -lapp=postgres"
  run_master "kubectl wait pod -lapp=postgres --for=condition=ready --timeout=120s"
  display_info "Get pods" "Look at the pods again to see where it has been scheduled"
  run_master "kubectl get pods -lapp=postgres -o wide"
  display_info "Uncordon node" "Uncordon the node"
  run_master "kubectl uncordon $node"
  display_info "Delete PostgreSQL" "Finally, delete the PostgreSQL deployment"
  run_master "kubectl delete -f /assets/deploy_postgres.yml"
  destroy_demo_panes
}

test_failover_mysql() {
  create_demo_panes
  display_info "Deploy MySQL" "First, we will deploy MySQL"
  run_master "kubectl apply -f /assets/deploy_mysql.yml"
  run_master "kubectl wait pod -lapp=mysql --for=condition=ready --timeout=120s"
  display_info "Get pods" "Now, let's look at the pods to see where MySQL was provisioned"
  run_master "kubectl get pods -lapp=mysql -o wide"
  node=$(kubectl get pods -lapp=mysql -A -o=custom-columns='DATA:spec.nodeName' --no-headers)
  display_info "Cordon node" "Next, we will cordon the node"
  run_master "kubectl cordon $node"
  display_info "Delete pod" "Now, we can delete the pod and watch it scheduled on another node"
  run_master "kubectl delete pod -lapp=mysql"
  run_master "kubectl wait pod -lapp=mysql --for=condition=ready --timeout=120s"
  display_info "Get pods" "Look at the pods again to see where it has been scheduled"
  run_master "kubectl get pods -lapp=mysql -o wide"
  display_info "Uncordon node" "Uncordon the node"
  run_master "kubectl uncordon $node"
  display_info "Delete MySQL" "Finally, delete the MySQL deployment"
  run_master "kubectl delete -f /assets/deploy_mysql.yml"
  destroy_demo_panes
}

menu_top

tmux kill-server
