#!/usr/bin/env bash
SCRIPT_PATH="$(
    cd "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)/"
cd "$SCRIPT_PATH" || exit
source config

dump() {
    BACKUP_DIR=$1
    KUBECONFIG=$2
    while read -r namespace; do
        echo "scanning namespace '${namespace}'"
        mkdir -p "${BACKUP_DIR}/${namespace}"
        while read -r resource; do
            echo "  scanning resource '${resource}'"
            mkdir -p "${BACKUP_DIR}/${namespace}/${resource}"
            while read -r item; do
                echo "    exporting item '${item}'"
                kubectl --kubeconfig ${KUBECONFIG} get "$resource" -n "$namespace" "$item" -o yaml >"${BACKUP_DIR}/${namespace}/${resource}/$item.yaml"
            done < <(kubectl --kubeconfig ${KUBECONFIG} get "$resource" -n "$namespace" 2>&1 | tail -n +2 | awk '{print $1}')
        done < <(kubectl --kubeconfig ${KUBECONFIG} api-resources --namespaced=true 2>/dev/null | tail -n +2 | awk '{print $1}')
    done < <(kubectl --kubeconfig ${KUBECONFIG} get namespaces | tail -n +2 | awk '{print $1}')
}
dump ${HOME}/mesh_backup $MESH_CONFIG
dump ${HOME}/kube_backup $ACK_CONFIG
