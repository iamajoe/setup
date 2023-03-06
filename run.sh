#!/usr/bin/env bash

usage="Usage: /bin/bash run.sh <service> [params]\n"
usage="${usage}\n | SERVICE              | PARAMS                                                 |"
usage="${usage}\n | =====================|======================================================= |"
usage="${usage}\n | dev                  | <linux|mac> <user> <user name> <user email>            |"
usage="${usage}\n"

if [ -z "$(echo $1 | grep -o "dev")" ] || [ $1 = "help" ]; then
  echo "\n$usage"
  exit
fi

echo "Deploying $1..."

if [ $1 = "dev" ]; then
  ansible-galaxy install abdennour.golang

  if [ $2 = "linux" ]; then
      ansible-playbook ./playbooks/devlinux.yml --user $3 --ask-pass --ask-become-pass -i ./inventory/hosts --extra-vars="USER_NAME=$4 USER_EMAIL=$5"
  elif [ $2 = "mac" ]; then
      ansible-playbook ./playbooks/devmac.yml --user $3 --ask-pass --ask-become-pass -i ./inventory/hosts --extra-vars="USER_NAME=$4 USER_EMAIL=$5"
  fi
fi

echo ""
echo "Done."
