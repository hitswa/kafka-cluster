# Use Alpine Linux as base image
FROM alpine:latest

# Install necessary packages
RUN apk update && \
    apk add openjdk17 wget tar bash

# Set environment variables
ENV JAVA_HOME /usr/lib/jvm/java-17-openjdk
ENV PATH $PATH:$JAVA_HOME/bin
ENV SCALA_VERSION=2.12
ENV KAFKA_VERSION=3.6.0
ENV ZOOKEEPER_VERSION=3.8.3
ENV KAFKA_HOME=/opt/kafka
ENV ZOOKEEPER_HOME=/opt/zookeeper

# Download and extract ZooKeeper
RUN wget -q https://downloads.apache.org/zookeeper/zookeeper-$ZOOKEEPER_VERSION/apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz && \
    wget -q https://downloads.apache.org/zookeeper/zookeeper-$ZOOKEEPER_VERSION/apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz.sha512

# Validate the downloaded file's checksum
RUN EXPECTED_CHECKSUM=$(cat apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz.sha512 | awk '{print $1}') && \
    ACTUAL_CHECKSUM=$(sha512sum apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz | awk '{print $1}') && \
    if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then \
        echo "Error: Checksum does not match. Zookeeper file may be corrupted."; \
        exit 1; \
    fi

# Download and extract Kafka
RUN wget -q https://downloads.apache.org/kafka/$KAFKA_VERSION/kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz && \
    wget -q https://downloads.apache.org/kafka/$KAFKA_VERSION/kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz.sha512

# Validate the downloaded file's checksum
# RUN EXPECTED_CHECKSUM=$(cat kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz.sha512 | awk '{print $1}') && \
#     ACTUAL_CHECKSUM=$(sha512sum kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz | awk '{print $1}') && \
#     if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]; then \
#         echo "Error: Checksum does not match. Kafka file may be corrupted."; \
#         exit 1; \
#     fi

# Extract and move files
RUN tar -xzf apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz -C /opt && \
    mv /opt/apache-zookeeper-$ZOOKEEPER_VERSION-bin $ZOOKEEPER_HOME && \
    cp /opt/zookeeper/conf/zoo_sample.cfg /opt/zookeeper/conf/zoo.cfg

RUN tar -xzf kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz -C /opt && \
    mv /opt/kafka_$SCALA_VERSION-$KAFKA_VERSION $KAFKA_HOME

# Expose necessary ports
EXPOSE 2181 9092

# Start ZooKeeper and Kafka
CMD ["/bin/bash", "-c", "/opt/zookeeper/bin/zkServer.sh start-foreground && /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties"]
