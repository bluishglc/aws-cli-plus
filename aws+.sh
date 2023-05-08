#!/bin/bash

export APP_HOME="$(
    cd "$(dirname $(readlink -nf "$0"))"
    pwd -P
)"

export AWS_PAGER=""

source "$APP_HOME/ec2.sh"
source "$APP_HOME/emr.sh"
source "$APP_HOME/mysql.sh"
source "$APP_HOME/utils.sh"

printUsage() {
    echo "Params Errors!!"
}

parseArgs() {
    if [ $# -eq 0 ]; then
        printUsage
        exit 0
    fi
    optString="region:,ssh-key:,access-key-id:,secret-access-key:,emr-cluster-id:,mysql-root-password:"
    # IMPORTANT!! -o option can not be omitted, even there are no any short options!
    # otherwise, parsing will go wrong!
    OPTS=$(getopt -o "" -l "$optString" -- "$@")
    exitCode=$?
    if [ $exitCode -ne 0 ]; then
        echo ""
        printUsage
        exit 1
    fi
    eval set -- "$OPTS"
    while true; do
        case "$1" in
            --region)
                REGION="${2}"
                shift 2
                ;;
            --ssh-key)
                SSH_KEY="$2"
                # chmod in case its mod is not 600
                chmod 600 $SSH_KEY
                shift 2
                ;;
            --access-key-id)
                ACCESS_KEY_ID="${2}"
                shift 2
                ;;
            --secret-access-key)
                SECRET_ACCESS_KEY="${2}"
                shift 2
                ;;
            --emr-cluster-id)
                EMR_CLUSTER_ID="${2}"
                shift 2
                ;;
            --mysql-root-password)
                MYSQL_ROOT_PASSWORD="${2}"
                shift 2
                ;;
            --) # No more arguments
                shift
                break
                ;;
            *)
                echo ""
                echo "Invalid option $1." >&2
                printUsage
                exit 1
                ;;
        esac
    done
    shift $((OPTIND-1))
}

# ----------------------------------------------    Scripts Entrance    ---------------------------------------------- #

SERVICE="$1"
shift
ACTION="$1"
shift
parseArgs "$@"

case $SERVICE in
    ec2)
        case $ACTION in
            init)
                initEc2
            ;;
            *)
                printUsage
            ;;
        esac
    ;;
    emr)
        case $ACTION in
            list-apps)
                listApps
            ;;
            list-services)
                listServices
            ;;
            list-packages)
                listPackages
            ;;
            find-log-errors)
                findLogErrors
            ;;
            *)
                printUsage
            ;;
        esac
    ;;
    mysql)
        case $ACTION in
            install)
                installMySqlIfNotExists
            ;;
            *)
                printUsage
            ;;
        esac
    ;;
    help)
        printUsage
        ;;
    *)
        printUsage
        ;;
esac

