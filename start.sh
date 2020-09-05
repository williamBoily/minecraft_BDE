#!/bin/bash

#exit script on any error
set -e



#TODO check arguments
# -n, world name
# -b, use backup

# TRUE is the lenght of $1 is zero

case "$1" in
"live")
    SERVER_DIR="/home/$(whoami)/minecraft_server/bedrock"
    ;;
"dev")
    SERVER_DIR="/home/$(whoami)/minecraft_server_DEV/bedrock"
    ;;
*)
    echo "Error: missing mode"
    echo "start.sh <live|dev> <world-name> [path of the world backup to use]"
    exit
    ;;
esac

if [ -z "$2" ]; then
    echo "Error: missing world name"
    echo "start.sh <live|dev> <world-name> [path of the world backup to use]"
    exit
fi
WORLD_NAME=$2

if [ -n "$3" ]; then
    [ ! -d $3 ] && echo "Error: $3 is not a valid directory" && exit
    echo "Backup found..."
    world_backup=$3  
fi

if [ ! -d "$SERVER_DIR" ]; then
    mkdir -p "$SERVER_DIR"
fi

WORLD_DIR=$SERVER_DIR/worlds/"$WORLD_NAME"_data

if [ -n "$world_backup" ]; then
    if [ -d "$WORLD_DIR" ]; then
        echo "Warning: world $WORLD_NAME already exist."
        echo "Do you want to OVERWRITE this world with $world_backup?"
        read -p "This action will delete the current world. [y/N]:" input
        [ "$input" != "y" ] && echo "Cancelling world creation" && exit 
        echo "Deleting current world: $WORLD_NAME"
        rm -r -f "$WORLD_DIR"
    fi
    echo "Copying backup"
    mkdir -p "$WORLD_DIR"
    cp -r $world_backup/* "$WORLD_DIR"
fi

if [ ! -d "$WORLD_DIR" ]; then
    mkdir -p "$WORLD_DIR"
fi



echo "Starting world $WORLD_NAME" 
# TODO use docker-compose or push the image to the repo
# --user $(id -u):$(id -g) set the user in the container as the one running the script.
#   this allow the container to create files as the user and not root on the host via the volumes.
# now, code assume the docker image exist
docker run -d -it -p 19132:19132/udp --name minecraft_bds_$WORLD_NAME \
    -v "$WORLD_DIR/$WORLD_NAME:/opt/minecraft/worlds/$WORLD_NAME" \
    -v "$WORLD_DIR:/opt/minecraft/world_data" \
    wboily/minecraft_bds
