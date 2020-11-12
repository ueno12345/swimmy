#!/bin/bash

#This script only works under below conditions
# 1. finish to install and set up sheetq
# 2. environmental variable is written to "swimmy/.env"
# 3. Docker is installed

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
}

function main(){
    if ! user_is_member_of_dockergroup; then
        echo "You have to be member of docker group"
        exit 1
    fi

    cd "$(dirname "$0")"

    case "$1" in
        start)
            start
        ;;
        stop)
            stop
        ;;
        status)
            status
        ;;
        help)
            usage
        ;;
        *)
            echo "Invalid option" >&2
            usage >&2
            exit 1
        ;;
    esac
    return 0
}

function user_is_member_of_dockergroup(){
    res=$(groups | grep -c -e docker -e root)
    if [ $res = 0 ]; then
        return 1
    fi
    return 0
}

function start(){
    if is_container_running swimmy; then
        echo "swimmy has already started"
    else
        echo -n "try to start swimmy..."
        docker run -d --name swimmy \
            -v $PWD/.env:/root/swimmy/.env \
            -v $HOME/.config/sheetq/:/root/.config/sheetq \
            swimmy >/dev/null
        if [ $? = 0 ]; then
            echo "done."
        else
            exit 1
        fi
    fi
}

function stop(){
    if is_container_running swimmy; then
        echo -n "try to stop swimmy..."
        docker stop swimmy >/dev/null
        docker rm swimmy >/dev/null
        if [ $? = 0 ]; then
            echo "done."
        else
            exit 1
        fi
    else
        echo "swimmy is not running"
    fi
}

function status(){
    if is_container_running swimmy; then
        echo "running"
    else
        echo "stop"
    fi
}

function is_container_running(){
    res=$(docker ps -a --format "table {{.Names}}" |grep -cx "$1")
    if [ $res = 0 ]; then
        return 1
    else
        return 0
    fi
}

main "$1"
