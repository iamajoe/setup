#!/usr/bin/env bash

usage="Usage: /bin/bash run.sh <service> [params]\n"
usage="${usage}\n | SERVICE              | PARAMS     |"
usage="${usage}\n | =====================|=========== |"
usage="${usage}\n | dev                  | <ssh-user> |"
usage="${usage}\n | donkey               | <ssh-user> |"
usage="${usage}\n"

if [ $1 = "help" ]; then
  echo "\n$usage"
  exit
fi

echo "Deploying $1..."

if [ $1 = "dev" ]; then
  ansible-galaxy install abdennour.golang
  ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook ./playbooks/dev.yml --user $2 --ask-pass --ask-become-pass -i ./inventory/hosts
fi

if [ $1 = "donkey" ]; then
  ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook ./playbooks/donkey.yml --user $2 --ask-pass --ask-become-pass -i ./inventory/hosts
fi

echo ""
echo "Done."
