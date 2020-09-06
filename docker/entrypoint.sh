#!/bin/bash

# Exit script on any error
set -e

# Reference https://github.com/seancheung/bedrock/blob/master/entrypoint.sh
config_files=("server.properties" "permissions.json" "whitelist.json" )

for f in "${config_files[@]}"; do
    # Rename defualt config files with suffix ".default"
    mv -f "$MINECRAFT_DIR/$f" "$MINECRAFT_DIR/$f.default"

    # If no custom config files exist, copy the default ones in the data directory
    if [ ! -f "$MINECRAFT_DIR/world_data/$f" ]; then
        cp "$MINECRAFT_DIR/$f.default" "$MINECRAFT_DIR/world_data/$f"
    fi

    # Link the config files with the ones that bedrock_server will read.
    ln -s $MINECRAFT_DIR/world_data/$f $MINECRAFT_DIR/$f
done

# The exec will replace the current process with the process resulting from executing its argument.
# $@ refer to the arguments list passed to this script.
# In our case, it is the "bedrocker_server" from the CMD in our Dockerfile
exec "$@"
