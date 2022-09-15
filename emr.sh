#!/bin/bash

# ----------------------------------------    Query Cluster Info Operations   ---------------------------------------- #

listServices() {
    printHeading "SERVICES LIST"
    for masterNode in $(getEmrClusterNodes); do
        echo "SERVICES ON: [ $masterNode ]"
        ssh -o StrictHostKeyChecking=no -i $SSH_KEY -T hadoop@$masterNode sudo systemctl | grep hadoop
    done
}

# An emr cluster has only one master instance group
getMasterInstanceGroupId() {
    if [ "$EMR_CLUSTER_ID" = "" ]; then
        echo "ERROR!! --emr-cluster-id is not provided, it is required to solve emr cluster info."
        exit 1
    fi
    if [ "$MASTER_INSTANCE_GROUP_ID" = "" ]; then
        MASTER_INSTANCE_GROUP_ID=$(aws emr describe-cluster --region $REGION --cluster-id $EMR_CLUSTER_ID | \
            jq -r '.Cluster.InstanceGroups[] | select(.InstanceGroupType == "MASTER") | .Id' | tr -s ' ')
    fi
    echo $MASTER_INSTANCE_GROUP_ID
}

# slave instance groups is core + task groups, may return multiple values!
# be careful, return string is just word-split (iterable) literal, not an array!
getSlaveInstanceGroupIds() {
    if [ "$EMR_CLUSTER_ID" = "" ]; then
        echo "ERROR!! --emr-cluster-id is not provided, it is required to solve emr cluster info."
        exit 1
    fi
    if [ "$SLAVE_INSTANCE_GROUP_IDS" = "" ]; then
        SLAVE_INSTANCE_GROUP_IDS=$(aws emr describe-cluster --region $REGION --cluster-id $EMR_CLUSTER_ID | \
            jq -r '.Cluster.InstanceGroups[] | select((.InstanceGroupType == "CORE") or (.InstanceGroupType == "SLAVE")) | .Id' | tr -s ' ')
    fi
    echo $SLAVE_INSTANCE_GROUP_IDS
}

getNodes() {
    instanceGroupIds="$1"
    # be careful, instanceGroupIds is word-split (iterable) literal, don't quote with “”
    for instanceGroupId in ${instanceGroupIds}; do
        # convert to an array
        nodes+=($(aws emr list-instances --region $REGION --cluster-id $EMR_CLUSTER_ID | \
            jq -r --arg instanceGroupId "$instanceGroupId" '.Instances[] | select(.InstanceGroupId == $instanceGroupId) | .PrivateDnsName' | tr -s ' '))
    done
    echo "${nodes[@]}"
}

getEmrMasterNodes() {
    if [[ "${EMR_MASTER_NODES[*]}" = "" ]]; then
        masterInstanceGroupId=$(getMasterInstanceGroupId)
        EMR_MASTER_NODES=($(getNodes "$masterInstanceGroupId"))
    fi
    echo "${EMR_MASTER_NODES[@]}"
}

getEmrSlaveNodes() {
    if [[ "${EMR_SLAVE_NODES[*]}" = "" ]]; then
        slaveInstanceGroupIds=$(getSlaveInstanceGroupIds)
        EMR_SLAVE_NODES=($(getNodes "$slaveInstanceGroupIds"))
    fi
    echo "${EMR_SLAVE_NODES[@]}"
}

getEmrClusterNodes() {
    if [[ "${EMR_CLUSTER_NODES[*]}" = "" ]]; then
        EMR_CLUSTER_NODES=($(getEmrMasterNodes) $(getEmrSlaveNodes))
    fi
    echo "${EMR_CLUSTER_NODES[@]}"
}

getEmrZkQuorum() {
    if [[ "$EMR_ZK_QUORUM" = "" ]]; then
        # EMR_ZK_QUORUM looks like 'node1,node2,node3'
        EMR_ZK_QUORUM=$(getEmrMasterNodes | sed -E 's/[[:blank:]]+/,/g')
    fi
    echo "$EMR_ZK_QUORUM"
}

getEmrHdfsUrl() {
    if [[ "$EMR_HDFS_URL" = "" ]]; then
        # add hdfs:// prefix and :8020 postfix, EMR_HDFS_URL looks like
        # hdfs://node1:8020,hdfs://node2:8020,hdfs://node3:8020
        EMR_HDFS_URL=$(getEmrZkQuorum | sed -E 's/([^,]+)/hdfs:\/\/\1:8020/g')
    fi
    echo "$EMR_HDFS_URL"
}

getEmrFirstMasterNode() {
    if [[ "$EMR_FIRST_MASTER_NODE" = "" ]]; then
        # NOTE: ranger hive plugin will use hiveserver2 address, for single master node EMR cluster,
        # it is master node, for multi masters EMR cluster, all 3 master nodes will install hiverserver2
        # usually, there should be a virtual IP play hiverserver2 role, but EMR has no such config.
        # here, we pick first master node as hiveserver2
        EMR_FIRST_MASTER_NODE=$(getEmrClusterNodes | cut -d ' ' -f 1)
    fi
    echo "$EMR_FIRST_MASTER_NODE"
}

printEmrClusterNodes() {
    echo "Master Nodes:"
    for node in $(getEmrMasterNodes); do
        echo $node
    done
    echo "Slave Nodes:"
    for node in $(getEmrSlaveNodes); do
        echo $node
    done
}

# -----------------------------------------    EMR Cluster Util Operations   ----------------------------------------- #

getEmrLatestClusterId() {
    latestCreationTime=$(aws emr list-clusters --region $REGION | jq -r '.Clusters[].Status.Timeline.CreationDateTime' | sort -r | head -n 1)
    aws emr list-clusters --active | jq -r --arg  latestCreationTime "$latestCreationTime" '.Clusters[] | select (.Status.Timeline.CreationDateTime == $latestCreationTime) | .Id'
}

getEmrClusterStatus() {
    aws emr describe-cluster --region $REGION --cluster-id $EMR_CLUSTER_ID | jq -r '.Cluster.Status.State'
}

getClusterIps() {
    # all nodes
    aws emr list-instances --region $REGION --cluster-id j-TO4FE32NLGPF | jq -r .Instances[].PrivateDnsName
    # master instance group id
    aws emr describe-cluster --region $REGION --cluster-id j-TO4FE32NLGPF | jq -r '.Cluster.InstanceGroups[] | select(.InstanceGroupType == "MASTER") | .Id'

    # all master node
    aws emr list-instances --region $REGION --cluster-id j-TO4FE32NLGPF | jq -r '.Instances[] | select(.InstanceGroupId == "ig-3RBRQ0UXGP2YL") | .PrivateDnsName'
}

findLogErrors() {
    accountId=$(aws sts get-caller-identity --query Account --output text)
    region=$(aws configure get region)
    rm -rf /tmp/$EMR_CLUSTER_ID
    aws s3 cp --recursive s3://aws-logs-${accountId}-${region}/elasticmapreduce/$EMR_CLUSTER_ID /tmp/$EMR_CLUSTER_ID >& /dev/null
    # try zgrep to replace gzip and grep!
    gzip -d -r /tmp/$EMR_CLUSTER_ID >& /dev/null
    grep --color=always -r --exclude="*.yaml" -i -E 'error|failed|exception' /tmp/$EMR_CLUSTER_ID
}
