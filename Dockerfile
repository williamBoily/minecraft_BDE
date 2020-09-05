FROM ubuntu:18.04

ARG BUILD_BDE_VERSION=latest

ENV VERSION=$BUILD_BDE_VERSION

ENV download_url=https://minecraft.azureedge.net/bin-linux/
ENV minecraft_zip=bedrock-server-1.14.60.5.zip 
ENV MINECRAFT_DIR=/opt/minecraft

RUN apt-get update \
    && apt-get install -y \
    unzip \
    curl \
    && rm -rf /var/lib/iapt/lists/*

# Download and extract the bedrock server
# cannot re-assign VERSION from a command result. VERSION must be use within the same RUN command
# https://stackoverflow.com/questions/34911622/dockerfile-set-env-to-result-of-command
RUN if [ "$BUILD_BDE_VERSION" = "latest" ] ; then \
        LATEST_VERSION=$( \
            curl -v --silent  https://www.minecraft.net/en-us/download/server/bedrock 2>&1 | \
            grep -o 'https://minecraft.azureedge.net/bin-linux/[^"]*' | \
            sed -E 's/.*bedrock-server-(.*)(\.zip.*)/\1/') && \
        export VERSION=$LATEST_VERSION; \
    fi && \
    echo "Using VERSION $VERSION"; \ 
    curl https://minecraft.azureedge.net/bin-linux/bedrock-server-${VERSION}.zip --output /tmp/minecraft_bds.zip && \
    mkdir /opt/minecraft && \
    unzip /tmp/minecraft_bds.zip -d /opt/minecraft && \
    rm /tmp/minecraft_bds.zip

# Create a config directory and link the files to the original source so we can mount the config directory from
# custom files on the host.
RUN mkdir ${MINECRAFT_DIR}/world_data
#RUN mkdir ${installation_directory}/world_data && \
#    mv ${installation_directory}/server.properties ${installation_directory}/config && \
#    mv ${installation_directory}/permissions.json ${installation_directory}/config && \
#    mv /opt/minecraft/whitelist.json ${installation_directory}/config && \
#    ln -s ${installation_directory}/config/server.properties ${installation_directory}/server.properties && \
#    ln -s ${installation_directory}/config/permissions.json ${installation_directory}/permissions.json && \
#    ln -s ${installation_directory}/config/whitelist.json ${installation_directory}/whitelist.json

COPY entrypoint.sh /opt/minecraft/

WORKDIR /opt/minecraft/


EXPOSE 19132/udp
EXPOSE 19133/udp

ENV LD_LIBRARY_PATH=.
ENTRYPOINT ["/opt/minecraft/entrypoint.sh"]
CMD ["/opt/minecraft/bedrock_server"]


