#!/usr/bin/env bash

usage="Usage: /bin/bash run.sh <service> [params]\n"
usage="${usage}\n | SERVICE              | PARAMS                                                 |"
usage="${usage}\n | =====================|======================================================= |"
usage="${usage}\n | dev                  | <user> <user name> <user email>            |"
usage="${usage}\n"

if [ -z "$(echo $1 | grep -o "dev")" ] || [ $1 = "help" ]; then
  echo "\n$usage"
  exit
fi

echo "Deploying $1..."

if [ $1 = "dev" ]; then
  ansible-galaxy install abdennour.golang
  ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook ./playbooks/dev.yml --user $2 --ask-pass --ask-become-pass -i ./inventory/hosts --extra-vars="USER_NAME=$3 USER_EMAIL=$4"
fi

echo ""
echo "Done."
