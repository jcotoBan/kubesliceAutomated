#!/bin/bash
set -e
trap "cleanup $? $LINENO" EXIT

## Linode/SSH security settings
#<UDF name="user_name" label="The limited sudo user to be created for the Linode" default="">
#<UDF name="password" label="The password for the limited sudo user" example="an0th3r_s3cure_p4ssw0rd" default="">
#<UDF name="disable_root" label="Disable root access over SSH?" oneOf="Yes,No" default="No">
#<UDF name="pubkey" label="The SSH Public Key that will be used to access the Linode (Recommended)" default="">

##Controller kubernetes cluster
#<UDF name="controller_cluster_label" label="Controller cluster label">
#<UDF name="controller_cluster_dc" Label="The datacenter for your Controller cluster" oneOf="ap-west,ca-central,ap-southeast,us-iad,us-ord,fr-par,us-sea,br-gru,nl-ams,se-sto,in-maa,jp-osa,it-mil,us-mia,id-cgk,us-lax,us-central,us-west,us-southeast,us-east,eu-west,ap-south,eu-central" default="us-sea">
#<UDF name="controller_cluster_version" label="Controller kubernetes version" oneOf="1.26,1.27" default="1.27">
#<UDF name="controller_cluster_node_plan" Label="The plan for your Controller nodes" oneOf="g6-dedicated-2,g6-dedicated-4,g6-dedicated-8,g6-dedicated-16,g6-dedicated-32,g6-dedicated-48,g6-dedicated-50,g6-dedicated-56,g6-dedicated-64" default="g6-dedicated-8">
#<UDF name="controller_cluster_nodes" label="Number of nodes for Controller cluster">


##Worker kubernetes cluster
#<UDF name="worker_cluster_label" label="Worker cluster label">
#<UDF name="worker_cluster_dc" Label="The datacenter for your Worker cluster" oneOf="ap-west,ca-central,ap-southeast,us-iad,us-ord,fr-par,us-sea,br-gru,nl-ams,se-sto,in-maa,jp-osa,it-mil,us-mia,id-cgk,us-lax,us-central,us-west,us-southeast,us-east,eu-west,ap-south,eu-central" default="us-sea" />
#<UDF name="worker_cluster_version" label="Worker kubernetes version" oneOf="1.26,1.27" default="1.27">
#<UDF name="worker_cluster_node_plan" Label="The plan for your Worker nodes" oneOf="g6-dedicated-2,g6-dedicated-4,g6-dedicated-8,g6-dedicated-16,g6-dedicated-32,g6-dedicated-48,g6-dedicated-50,g6-dedicated-56,g6-dedicated-64" default="g6-dedicated-8">
#<UDF name="worker_cluster_nodes" label="Number of nodes for Worker cluster">

## Kubeslice project
#<UDF name="kubeslice_project" label="Kubeslice project name">


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
  
  local group_vars="/tmp/kubesliceAutomated/ansible/group_vars/linode/vars"
  
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

  #LKE vars

  if [[ -n ${CONTROLLER_CLUSTER_LABEL} ]]; then
    echo "controller_cluster_label: ${CONTROLLER_CLUSTER_LABEL}" >> ${group_vars};
  fi

  if [[ -n ${CONTROLLER_CLUSTER_DC} ]]; then
    echo "controller_cluster_dc: ${CONTROLLER_CLUSTER_DC}" >> ${group_vars};
  fi

  if [[ -n ${CONTROLLER_CLUSTER_VERSION} ]]; then
    echo "controller_cluster_version: ${CONTROLLER_CLUSTER_VERSION}" >> ${group_vars};
  fi

  if [[ -n ${CONTROLLER_CLUSTER_NODE_PLAN} ]]; then
    echo "controller_cluster_node_plan: ${CONTROLLER_CLUSTER_NODE_PLAN}" >> ${group_vars};
  fi

  if [[ -n ${CONTROLLER_CLUSTER_NODES} ]]; then
    echo "controller_cluster_nodes: ${CONTROLLER_CLUSTER_NODES}" >> ${group_vars};
  fi


  if [[ -n ${WORKER_CLUSTER_LABEL} ]]; then
    echo "Worker_cluster_label: ${WORKER_CLUSTER_LABEL}" >> ${group_vars};
  fi

  if [[ -n ${WORKER_CLUSTER_DC} ]]; then
    echo "Worker_cluster_dc: ${WORKER_CLUSTER_DC}" >> ${group_vars};
  fi

  if [[ -n ${WORKER_CLUSTER_VERSION} ]]; then
    echo "Worker_cluster_version: ${WORKER_CLUSTER_VERSION}" >> ${group_vars};
  fi

  if [[ -n ${WORKER_CLUSTER_NODE_PLAN} ]]; then
    echo "worker_cluster_node_plan: ${WORKER_CLUSTER_NODE_PLAN}" >> ${group_vars};
  fi

  if [[ -n ${WORKER_CLUSTER_NODES} ]]; then
    echo "Worker_cluster_nodes: ${WORKER_CLUSTER_NODES}" >> ${group_vars};
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
