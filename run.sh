#!/usr/bin/env bash

usage="Usage: /bin/bash run.sh [sshsetup|deploy] [params]\n"
usage="${usage}\n | TASK                 | PARAMS           |"
usage="${usage}\n | =====================|================= |"
usage="${usage}\n | sshsetup             | <ssh-src-folder> |"
usage="${usage}\n | deploy               |                  |"
usage="${usage}\n"

if [ "$1" = "help" ] || { [ "$1" != "deploy" ] && [ "$1" != "sshsetup" ]; }; then
  echo "\n$usage"
  exit
fi

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
MACHINE_NAME="${MACHINE_NAME:-""}"
MACHINE_USERNAME="${MACHINE_USERNAME:-""}"
MACHINE_IP_ADDR="${MACHINE_IP_ADDR:-""}"
USER_EMAIL="${USER_EMAIL:-""}"
USER_FULL_NAME="${USER_FULL_NAME:-""}"
EXTRA_VARIABLES="${EXTRA_VARIABLES:-""}"

PLAYBOOKS="${PLAYBOOKS:-""}"

GRUB_RESOLUTION="${GRUB_RESOLUTION:-1920x1080}"
INVENTORY_PATH="${INVENTORY_PATH:-./inventory/hosts}"
INVENTORY_TARGET="${INVENTORY_TARGET:-all}"

# computed variables
ANSIBLE_ARGS="${ANSIBLE_ARGS:-"-i $INVENTORY_PATH"}"

######################################

if [[ -z "$MACHINE_USERNAME" ]]; then
  echo "Error: MACHINE_USERNAME environment variable is not set."
  exit 1
fi

# has the user passed in a subset ip address?
TMP_HOSTS="./tmp_hosts"
if [[ -n "$MACHINE_IP_ADDR" ]]; then
  INVENTORY_PATH=$TMP_HOSTS;
  INVENTORY_TARGET="$MACHINE_NAME";
  echo "[$INVENTORY_TARGET]" > $TMP_HOSTS;
  echo "$MACHINE_IP_ADDR ansible_user=$MACHINE_USERNAME" >> $TMP_HOSTS;
fi

########################################
# DEPLOY

ANSIBLE_ARGS="-i $INVENTORY_PATH";
if [[ -n "$MACHINE_IP_ADDR" ]]; then
  ANSIBLE_ARGS="$ANSIBLE_ARGS -l $MACHINE_IP_ADDR";
fi
ANSIBLE_ARGS="$ANSIBLE_ARGS --user \"$MACHINE_USERNAME\" --ask-pass --ask-become-pass"
ANSIBLE_ARGS="$ANSIBLE_ARGS -T 60" # ssh is taking too long, augmenting timeout 

if [ "$1" = "sshsetup" ]; then
  echo "Setting ssh $INVENTORY_TARGET to $MACHINE_USERNAME:$MACHINE_IP_ADDR...";

  if [[ -z "$2" ]]; then
    echo "Error: ssh source dir is not set."
    exit 1
  fi

  ANSIBLE_VARIABLES=$(jq -nc \
    --arg ssh_src_dir "$2" \
    --arg target "$INVENTORY_TARGET" \
    '{ssh_src_dir: $ssh_src_dir, target: $target }')
  ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook "./playbooks/sshsetup.yml" $ANSIBLE_ARGS -e="$ANSIBLE_VARIABLES" # -vvvv

  echo "Run on the machine before proceeding with deploys:"
  echo '  eval `keychain --agents ssh --eval id_rsa`; eval $(ssh-agent); ssh-add'
elif [ "$1" = "deploy" ]; then
  echo "Deploying $INVENTORY_TARGET to $MACHINE_USERNAME:$MACHINE_IP_ADDR...";

  if [[ -z "$PLAYBOOKS" ]]; then
    echo "Error: PLAYBOOKS environment variable is not set."
    exit 1
  fi

  # prepare the playbook that runs all the others
  TMP_OUTPUT_PLAYBOOK="./tmp_playbook.yml"
  echo "" > "$TMP_OUTPUT_PLAYBOOK";
  PLAYBOOKS_ARRAY=($PLAYBOOKS) # convert (space-separated list) into an array
  for PLAYBOOK in "${PLAYBOOKS_ARRAY[@]}"; do
      echo "- import_playbook: \"$PLAYBOOK\"" >> "$TMP_OUTPUT_PLAYBOOK"
  done

  ANSIBLE_VARIABLES=$(jq -nc \
    --arg target "$INVENTORY_TARGET" \
    --arg git_user_email "$USER_EMAIL" \
    --arg git_user_fullname "$USER_FULL_NAME" \
    --arg grub_resolution "$GRUB_RESOLUTION" \
    '{target: $target, git_user_email:$git_user_email, git_user_fullname: $git_user_fullname, grub_resolution: $grub_resolution }')
  ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook "$TMP_OUTPUT_PLAYBOOK" $ANSIBLE_ARGS -e="$ANSIBLE_VARIABLES" # -vvvv
  # TODO: use for full verbose -> -vvvv
fi

# cleanup tmps
rm -rf $TMP_HOSTS;
rm -rf $TMP_OUTPUT_PLAYBOOK;

echo ""
echo "Done."
