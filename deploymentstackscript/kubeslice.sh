#!/bin/bash
set -e
trap "cleanup $? $LINENO" EXIT

## Linode/SSH security settings
#<UDF name="user_name" label="The limited sudo user to be created for the Linode" default="">
#<UDF name="password" label="The password for the limited sudo user" example="an0th3r_s3cure_p4ssw0rd" default="">
#<UDF name="disable_root" label="Disable root access over SSH?" oneOf="Yes,No" default="No">
#<UDF name="pubkey" label="The SSH Public Key that will be used to access the Linode (Recommended)" default="">

## Kubeslice image secret
#<UDF name="license_username" label="Kubeslice image secret username">
#<UDF name="license_password" label="Kubeslice image secret password">
#<UDF name="license_email" label="Kubeslice image secret email">

## Kubeslice controller setup
#<UDF name="license_type" label="Kubeslice License Type" oneOf="kubeslice-trial-license,kubeslice-vcpu-license" default="kubeslice-trial-license">
#<UDF name="license_mode" label="Kubeslice License Mode" oneOf="auto,manual" default="auto">
#<UDF name="license_custom_username" label="Kubeslice License custom user name">


# git repo
export GIT_REPO="https://github.com/jcotoBan/kubesliceAutomated.git"

# enable logging
exec > >(tee /dev/ttyS0 /var/log/stackscript.log) 2>&1

function cleanup {
  if [ -d "${WORK_DIR}" ]; then
    rm -rf ${WORK_DIR}
  fi
}

function udf {
  
  local group_vars="${WORK_DIR}/${MARKETPLACE_APP}/group_vars/linode/vars"
  
  if [[ -n ${USER_NAME} ]]; then
    echo "username: ${USER_NAME}" >> ${group_vars};
  else echo "No username entered";
  fi

  if [ "$DISABLE_ROOT" = "Yes" ]; then
    echo "disable_root: yes" >> ${group_vars};
  else echo "Leaving root login enabled";
  fi

  if [[ -n ${PASSWORD} ]]; then
    echo "password: ${PASSWORD}" >> ${group_vars};
  else echo "No password entered";
  fi

  if [[ -n ${PUBKEY} ]]; then
    echo "pubkey: ${PUBKEY}" >> ${group_vars};
  else echo "No pubkey entered";
  fi

  # Kubeslice vars

  if [[ -n ${LICENSE_USERNAME} ]]; then
    echo "license_username: ${LICENSE_USERNAME}" >> ${group_vars};
  fi

  if [[ -n ${LICENSE_PASSWORD} ]]; then
    echo "license_password: ${LICENSE_PASSWORD}" >> ${group_vars};
  fi

  if [[ -n ${LICENSE_EMAIL} ]]; then
    echo "license_email: ${LICENSE_EMAIL}" >> ${group_vars};
  fi

  if [[ -n ${LICENSE_TYPE} ]]; then
    echo "license_type: ${LICENSE_EMAIL}" >> ${group_vars};
  fi

  if [[ -n ${LICENSE_MODE} ]]; then
    echo "license_mode: ${LICENSE_MODE}" >> ${group_vars};
  fi

  if [[ -n ${LICENSE_CUSTOM_USERNAME} ]]; then
    echo "license_custom_username: ${LICENSE_CUSTOM_USERNAME}" >> ${group_vars};
  fi
  
}

function run {
  # install dependancies
  apt-get update
  apt-get install -y git python3 python3-pip

  # clone repo and set up ansible environment
  git -C /tmp clone ${GIT_REPO}
  # for a single testing branch
  # git -C /tmp clone --single-branch --branch ${BRANCH} ${GIT_REPO}

  # venv
  cd /tmp/kubesliceAutomated/ansible
  pip3 install virtualenv
  python3 -m virtualenv env
  source env/bin/activate
  pip install pip --upgrade
  pip install -r requirements.txt
  ansible-galaxy install -r collections.yml

  # populate group_vars
  udf
  # run playbooks
  for playbook in site.yml; do ansible-playbook -vvvv $playbook; done
  
}

function installation_complete {
  echo "Installation Complete"
}
# main
run && installation_complete
cleanup
