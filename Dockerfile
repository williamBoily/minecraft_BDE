FROM ubuntu:18.04

ENV download_url=https://minecraft.azureedge.net/bin-linux/
ENV minecraft_zip=bedrock-server-1.14.60.5.zip 
ENV MINECRAFT_DIR=/opt/minecraft

RUN apt-get update \
    && apt-get install -y \
    unzip \
    curl \
    && rm -rf /var/lib/iapt/lists/*

# Download minecraft BDS(bedrock dedicated server) from official website
RUN curl ${download_url}${minecraft_zip} --output /tmp/minecraft_bds.zip && \
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


