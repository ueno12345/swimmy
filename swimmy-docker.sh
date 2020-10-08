#!/bin/bash

#This script only works under below conditions
# 1. finish to install and set up sheetq
# 2. environmental variable is written to "swimmy/.env"
# 3. Docker is installed
# 4. can use Docker without 'sudo'
#  if you do not finish to set up 4, execute below command
#  $ sudo usermod -aG docker $USER

function usage(){
cat <<_EOT_
swimmy-docker.sh

Usage:
    $0 Option

Description:
    start and stop swimmy on container

Options:
    start     start swimmy on container
    stop      stop swimmy
    status    show swimmy's condition
    help      show this usage
_EOT_
return 0
}

function main(){
    cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    case $1 in
        "start")
            start
        ;;
        "stop")
            stop
        ;;
        "status")
            status
        ;;
        "help")
            usage
        ;;
        *)
            echo "Invalid option"
            usage
        ;;
    esac
    return 0
}

function start(){
    check_swimmy_condition
    if [ "$?" = "1" ]; then
        echo "swimmy has already started"
    else
        echo "try to start swimmy..."
        docker run -d --name swimmy \
            -v $PWD/.env:/root/swimmy/.env \
            -v $HOME/.config/sheetq/:/root/.config/sheetq \
            swimmy >/dev/null
        if [ "$?" = "0" ]; then
            echo "done."
        else
            echo "failed to start swimmy"
        fi
    fi
    return 0
}

function stop(){
    check_swimmy_condition
    if [ "$?" = "1" ]; then
        echo "try to stop swimmy..."
        docker stop swimmy >/dev/null
        docker rm swimmy >/dev/null
        if [ "$?" = "0" ]; then
            echo "done."
        else
            echo "failed to stop swimmy"
        fi
    else
        echo "swimmy is not running"
    fi
    return 0
}

function status(){
    check_swimmy_condition
    if [ "$?" = "1" ]; then
        echo "running"
    else
        echo "stop"
    fi
    return 0
}

function check_swimmy_condition(){
    res=$(docker ps -a --format "table {{.Names}}" |grep -cx swimmy)
    if [ "$res" = "1" ]; then
        return 1
    else
        return 0
    fi
}

main $1
