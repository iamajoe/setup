#!/usr/bin/env bash

usage="Usage: /bin/bash run.sh <service> [params]\n"
usage="${usage}\n | PARAMS                        |"
usage="${usage}\n |===============================|"
usage="${usage}\n | <target> <ssh-user> [ip_addr] |"
usage="${usage}\n"

# check if the .env file exists, then load it
ENV_FILE=".env"
if [[ -f "$ENV_FILE" ]]; then
  echo "Loading environment variables from $ENV_FILE..."
  set -o allexport  # Enable auto-export
  source "$ENV_FILE"
  set +o allexport  # Disable auto-export
else
  echo "Env file not found"
fi

######################################
# set the variables 
#
SERVICE="${SERVICE:-$1}"
USERNAME="${USERNAME:-$2}"
USER_EMAIL="${USER_EMAIL:-""}"
USER_FULL_NAME="${USER_FULL_NAME:-""}"

PLAYBOOK_FOLDER="${PLAYBOOK_FOLDER:-"./playbooks"}"

SSH_SRC_DIR="${SSH_SRC_DIR:-$HOME/.ssh}"
INVENTORY_PATH="${INVENTORY_PATH:-./inventory/hosts}"
INVENTORY="${INVENTORY:-"-i $INVENTORY_PATH"}"
TARGET="${TARGET:-all}"
SUBSET="${SUBSET:-""}"
IP_ADDR="${IP_ADDR:-$3}"

######################################

# do we have enough?
if [[ -z "$SERVICE" || "$SERVICE" == "help" ]]; then
  echo "\n$usage"
  exit
fi

# has the user passed in a subset ip address?
if [[ -n "$IP_ADDR" ]]; then
  INVENTORY_PATH="./inventory/tmphosts";
  SUBSET="$IP_ADDR";
  TARGET="$SERVICE";

  echo -e "[$TARGET]\n$SUBSET" > $INVENTORY_PATH;
  INVENTORY="-i $INVENTORY_PATH -l $SUBSET";
fi

# deploy...
echo "Deploying $SERVICE to $USERNAME:$SUBSET...";
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook $PLAYBOOK_FOLDER/$SERVICE.yml --user $USERNAME --ask-pass --ask-become-pass $INVENTORY -e="ssh_src_dir=$SSH_SRC_DIR target=$TARGET git_user_email=$USER_EMAIL git_user_fullname=$USER_FULL_NAME"

# cleanup tmps
if [[ -n "$IP_ADDR" ]]; then
  rm -rf $INVENTORY_PATH;
fi

echo ""
echo "Done."
