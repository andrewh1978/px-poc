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
  result=$(eval $2)
  dialog --title "$1" \
    --no-collapse \
    --msgbox "$result" $HEIGHT $WIDTH
}

display_info() {
  dialog --title "$1" \
    --no-collapse \
    --msgbox "$2" $HEIGHT $WIDTH
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

test_failover_postgres() {
  tmux split-window -d -l 20 "kubectl get nodes -w"
  tmux split-window -d -t 1 -h "kubectl get pods -w -o wide"
  display_info "Deploy PostgreSQL" "First, we will deploy PostgreSQL"
  display_result "Deploy PostgreSQL" "kubectl apply -f /assets/deploy_postgres.yml"
  kubectl wait pod -lapp=postgres --for=condition=ready --timeout=120s
  display_info "Get pods" "Now, let's look at the pods to see where PostgreSQL was provisioned"
  display_result "Get pods" "kubectl get pods -lapp=postgres -o wide"
  node=$(kubectl get pods -lapp=postgres -A -o=custom-columns='DATA:spec.nodeName' --no-headers)
  display_info "Cordon node" "Next, we will cordon the node"
  display_result "Cordon node" "kubectl cordon $node"
  display_info "Delete pod" "Now, we can delete the pod and watch it scheduled on another node"
  display_result "Delete pod" "kubectl delete pod -lapp=postgres"
  kubectl wait pod -lapp=postgres --for=condition=ready --timeout=120s
  display_info "Get pods" "Look at the pods again to see where it has been scheduled"
  display_result "Get pods" "kubectl get pods -lapp=postgres -o wide"
  display_info "Uncordon node" "Uncordon the node"
  display_result "Uncordon node" "kubectl uncordon $node"
  display_info "Delete PostgreSQL" "Finally, delete the PostgreSQL deployment"
  display_result "Delete PostgreSQL" "kubectl delete -f /assets/deploy_postgres.yml"
  tmux kill-pane -t 1
  tmux kill-pane -t 1
}

test_failover_mysql() {
  tmux split-window -d -l 20 "kubectl get nodes -w"
  tmux split-window -d -t 1 -h "kubectl get pods -w -o wide"
  display_info "Deploy MySQL" "First, we will deploy MySQL"
  display_result "Deploy MySQL" "kubectl apply -f /assets/deploy_mysql.yml"
  kubectl wait pod -lapp=mysql --for=condition=ready --timeout=120s
  display_info "Get pods" "Now, let's look at the pods to see where MySQL was provisioned"
  display_result "Get pods" "kubectl get pods -lapp=mysql -o wide"
  node=$(kubectl get pods -lapp=mysql -A -o=custom-columns='DATA:spec.nodeName' --no-headers)
  display_info "Cordon node" "Next, we will cordon the node"
  display_result "Cordon node" "kubectl cordon $node"
  display_info "Delete pod" "Now, we can delete the pod and watch it scheduled on another node"
  display_result "Delete pod" "kubectl delete pod -lapp=mysql"
  kubectl wait pod -lapp=mysql --for=condition=ready --timeout=120s
  display_info "Get pods" "Look at the pods again to see where it has been scheduled"
  display_result "Get pods" "kubectl get pods -lapp=mysql -o wide"
  display_info "Uncordon node" "Uncordon the node"
  display_result "Uncordon node" "kubectl uncordon $node"
  display_info "Delete MySQL" "Finally, delete the MySQL deployment"
  display_result "Delete MySQL" "kubectl delete -f /assets/deploy_mysql.yml"
  tmux kill-pane -t 1
  tmux kill-pane -t 1
}

menu_top

tmux kill-server
