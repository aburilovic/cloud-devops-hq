#!/usr/bin/env bash
# Author: Manuel Bernal Llinares <mbdebian@gmail.com>
BASEDIR=$(dirname "$0")
source "${BASEDIR}"/tinylogger.bash

# Set the logging level
LOGGER_LVL=debug

# Environment configuration
MONGODB_BOOTSTRAP_FOLDER_TMP=${MONGODB_BOOTSTRAP_FOLDER_TMP:="tmp"}
# Replicas
MONGODB_BOOTSTRAP_N_REPLICAS=${MONGODB_BOOTSTRAP_N_REPLICAS:="3"}
# Destination Kubernetes cluster coordinates
MONGODB_BOOTSTRAP_KUBERNETES_CLUSTER_NAME=${MONGODB_BOOTSTRAP_KUBERNETES_CLUSTER_NAME:=`kubectl config current-context`}
MONGODB_BOOTSTRAP_KUBERNETES_CLUSTER_REGION=${MONGODB_BOOTSTRAP_KUBERNETES_CLUSTER_REGION:=`gcloud container clusters list --filter=${MONGODB_BOOTSTRAP_KUBERNETES_CLUSTER_NAME} --format=yaml | grep "zone:" | cut -f2 -d' '`}
# Some behavioral checks
FLAG_DUMP_ADMIN_CREDENTIALS=0
if [ -z ${MONGODB_BOOTSTRAP_MONGODB_ADMIN_USERNAME+x} ]; then
    FLAG_DUMP_ADMIN_CREDENTIALS=1
fi
# File for dumping admin credentials
MONGODB_BOOTSTRAP_FILE_MONGODB_ADMIN_CREDENTIALS=${MONGODB_BOOTSTRAP_FILE_MONGODB_ADMIN_CREDENTIALS:="${MONGODB_BOOTSTRAP_KUBERNETES_CLUSTER_NAME}-mongodb-admin-credentials.yml"}
# MongoDB admin credentials
MONGODB_BOOTSTRAP_MONGODB_ADMIN_USERNAME=${MONGODB_BOOTSTRAP_MONGODB_ADMIN_USERNAME:="mongadmin"}
MONGODB_BOOTSTRAP_MONGODB_ADMIN_PASSWORD=${MONGODB_BOOTSTRAP_MONGODB_ADMIN_PASSWORD:=`uuidgen`}
# MongoDB Kubernetes definition file
MONGODB_BOOTSTRAP_FILE_KUBERNETES_DEFINITION=${MONGODB_BOOTSTRAP_FILE_KUBERNETES_DEFINITION:="kubernetes/services/mongodb.yml"}
MONGODB_BOOTSTRAP_FILE_KUBERNETES_STORAGE_CLASS=${MONGODB_BOOTSTRAP_FILE_KUBERNETES_STORAGE_CLASS:="kubernetes/storage/gce-ssd-storageclass.yml"}
MONGODB_BOOTSTRAP_FILE_KUBERNETES_STORAGE_VOLUME_TEMPLATE=${MONGODB_BOOTSTRAP_FILE_KUBERNETES_STORAGE_VOLUME_TEMPLATE:="kubernetes/storage/mongodb_volume_template.yml"}
MONGODB_BOOTSTRAP_KUBERNETES_STORAGE_CLASS_NAME=${MONGODB_BOOTSTRAP_KUBERNETES_STORAGE_CLASS_NAME:=`yq -r .metadata.name ${MONGODB_BOOTSTRAP_FILE_KUBERNETES_STORAGE_CLASS}`}
MONGODB_BOOTSTRAP_KUBERNETES_STORAGE_VOLUME_SIZE=${MONGODB_BOOTSTRAP_KUBERNETES_STORAGE_VOLUME_SIZE:=100Gi}

# Helpers
function info() {
    tlog info "[DEVOPS] Temporary Folder: ${MONGODB_BOOTSTRAP_FOLDER_TMP}"
    tlog info "[DEVOPS] Replicas: ${MONGODB_BOOTSTRAP_N_REPLICAS}"
    tlog info "[DEVOPS] Kubernetes Cluster: ${MONGODB_BOOTSTRAP_KUBERNETES_CLUSTER_NAME}"
    tlog info "[DEVOPS] Kubernetes Region: ${MONGODB_BOOTSTRAP_KUBERNETES_CLUSTER_REGION}"
    if [ "$FLAG_DUMP_ADMIN_CREDENTIALS" == 1 ]; then
        tlog info "[DEVOPS] Admin Credentials file: ${MONGODB_BOOTSTRAP_FILE_MONGODB_ADMIN_CREDENTIALS}"
    fi
    tlog info "[DEVOPS] MongoDB kubernetes definition at ${MONGODB_BOOTSTRAP_FILE_KUBERNETES_DEFINITION}"
    tlog info "[DEVOPS] Kubernetes Storage Class Definition at ${MONGODB_BOOTSTRAP_FILE_KUBERNETES_STORAGE_CLASS}"
    tlog info "[DEVOPS] Kubernetes Storage Class name '${MONGODB_BOOTSTRAP_KUBERNETES_STORAGE_CLASS_NAME}'"
    tlog info "[DEVOPS] Kubernetes MongoDB Storage Volumes Template at ${MONGODB_BOOTSTRAP_FILE_KUBERNETES_STORAGE_VOLUME_TEMPLATE}"
    tlog info "[DEVOPS] Kubernetes MongoDB Storage Volumes capacity, ${MONGODB_BOOTSTRAP_KUBERNETES_STORAGE_VOLUME_SIZE}"
}

# Steps
function dump_admin_credentials() {
    if [ "$FLAG_DUMP_ADMIN_CREDENTIALS" == 1 ]; then
        tlog info "Dumping Administrator credentials to $MONGODB_BOOTSTRAP_FILE_MONGODB_ADMIN_CREDENTIALS"
        echo "username: $MONGODB_BOOTSTRAP_MONGODB_ADMIN_USERNAME" > $MONGODB_BOOTSTRAP_FILE_MONGODB_ADMIN_CREDENTIALS
        echo "password: $MONGODB_BOOTSTRAP_MONGODB_ADMIN_PASSWORD" >> $MONGODB_BOOTSTRAP_FILE_MONGODB_ADMIN_CREDENTIALS
    fi
}

function setup_storage_class() {
    tlog info "[${MONGODB_BOOTSTRAP_KUBERNETES_CLUSTER_NAME}] Setting up Storage class '${MONGODB_BOOTSTRAP_KUBERNETES_STORAGE_CLASS_NAME}'"
    # TODO actually do it
    #kubectl apply -f "${MONGODB_BOOTSTRAP_FILE_KUBERNETES_STORAGE_CLASS}"
}

function create_persistent_disks() {
    VOLUME_NAME_PREFIX='mongodb-data-volume'
    for i in $(seq 1 $MONGODB_BOOTSTRAP_N_REPLICAS); do
        DISK_NAME="${MONGODB_BOOTSTRAP_KUBERNETES_CLUSTER_NAME}-mongodb-disk-$i"
        tlog info "[CLOUD] Creating Persistent Disk #$i - $DISK_NAME"
    done
}


# --- START ---
tlog info "[ [START]--- MongoDB Backend Bootstrap ---[START] ]"
# Print out a description of what's gonna happen
info
# Dump admin credentials
dump_admin_credentials
# TODO - Setup the Storage Class
setup_storage_class
# TODO - Create Persistent Disks
create_persistent_disks
# TODO - Create Secrets for MondoDB communication
# TODO - Launch StatefulSet
# TODO - Init the MongoDB cluster
# TODO - Setup the admin user
