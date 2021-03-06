FROM ubuntu:16.04

ARG IMPLY_VERSION
RUN apt-get update && apt-get install -y cron wget postgresql-client && apt-get clean

RUN wget https://static.imply.io/release/imply-$IMPLY_VERSION.tar.gz && \
    tar -xzf /imply-$IMPLY_VERSION.tar.gz && \
    rm /imply-$IMPLY_VERSION.tar.gz && \
    mv imply-$IMPLY_VERSION /root

# Prepare OS
COPY setup-os.sh /root
COPY nodesource-pubkey /root/nodesource-pubkey
RUN /root/setup-os.sh

EXPOSE 1527 2181 8081 8082 8083 8090 8091 8100 8101 8102 8103 8104 8105 8106 8107 8108 8109 8110 8200 9095

WORKDIR /root/imply-$IMPLY_VERSION

# this is for scan query on druid 0.10.1, remove when updating to 0.11.x (> 2.4.x)
RUN cd /root/imply-$IMPLY_VERSION/dist/druid && \
  java \
    -cp "lib/*" \
    -Ddruid.extensions.directory="extensions" \
    -Ddruid.extensions.hadoopDependenciesDir="hadoop-dependencies" \
    io.druid.cli.Main tools pull-deps \
    --no-default-hadoop \
    -c "io.druid.extensions.contrib:scan-query:0.10.1" && \
 chown -R 501:staff extensions

CMD ["bin/supervise", "-c", "conf/supervise/quickstart.conf"]
