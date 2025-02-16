#!/usr/bin/env bash

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

PLAYBOOKS="${PLAYBOOKS:-""}"

GRUB_RESOLUTION="${GRUB_RESOLUTION:-1920x1080}"
SSH_SRC_DIR="${SSH_SRC_DIR:-""}"
INVENTORY_PATH="${INVENTORY_PATH:-./inventory/hosts}"
INVENTORY_TARGET="${INVENTORY_TARGET:-all}"

# computed variables
ANSIBLE_ARGS="${ANSIBLE_ARGS:-"-i $INVENTORY_PATH"}"

######################################

if [[ -z "$MACHINE_USERNAME" ]]; then
  echo "Error: MACHINE_USERNAME environment variable is not set."
  exit 1
fi
if [[ -z "$PLAYBOOKS" ]]; then
  echo "Error: PLAYBOOKS environment variable is not set."
  exit 1
fi

# has the user passed in a subset ip address?
TMP_HOSTS="./custom/tmp_hosts"
if [[ -n "$MACHINE_IP_ADDR" ]]; then
  INVENTORY_PATH=$TMP_HOSTS;
  INVENTORY_TARGET="$MACHINE_NAME";
  ANSIBLE_ARGS="-i $INVENTORY_PATH -l $MACHINE_IP_ADDR";

  echo "[$INVENTORY_TARGET]" > $TMP_HOSTS;
  echo "$MACHINE_IP_ADDR" >> $TMP_HOSTS;
fi

# prepare the playbook that runs all the others
TMP_OUTPUT_PLAYBOOK="./custom/tmp_playbook.yml"
echo "" > "$TMP_OUTPUT_PLAYBOOK";
PLAYBOOKS_ARRAY=($PLAYBOOKS) # convert (space-separated list) into an array
for PLAYBOOK in "${PLAYBOOKS_ARRAY[@]}"; do
    echo "- import_playbook: \"../$PLAYBOOK\"" >> "$TMP_OUTPUT_PLAYBOOK"
done

# deploy...
echo "Deploying $INVENTORY_TARGET to $USERNAME:$MACHINE_IP_ADDR...";
# for PLAYBOOK in "${PLAYBOOKS_ARRAY[@]}"; do
#   ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook "$PLAYBOOK" \
#       --user "$MACHINE_USERNAME" --ask-pass --ask-become-pass $ANSIBLE_ARGS -T 60 \
#       -e="ssh_src_dir=$SSH_SRC_DIR target=$INVENTORY_TARGET git_user_email=$USER_EMAIL git_user_fullname=$USER_FULL_NAME grub_resolution=$GRUB_RESOLUTION"
# done
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook "$TMP_OUTPUT_PLAYBOOK" \
    --user "$MACHINE_USERNAME" --ask-pass --ask-become-pass $ANSIBLE_ARGS -T 60 \
    -e="ssh_src_dir=$SSH_SRC_DIR target=$INVENTORY_TARGET git_user_email=$USER_EMAIL git_user_fullname=$USER_FULL_NAME grub_resolution=$GRUB_RESOLUTION"

# cleanup tmps
rm -rf $TMP_HOSTS;
rm -rf $TMP_OUTPUT_PLAYBOOK;

echo ""
echo "Done."
