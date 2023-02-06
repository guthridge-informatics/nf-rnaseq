FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update --fix-missing && \
   apt install --no-install-recommends -y \
      curl \
      openjdk-11-jdk \
      openjdk-11-jre \
      perl && \
   apt-get clean && \
   rm -rf /tmp/downloaded_packages/* && \
   rm -rf /var/lib/apt/lists/*

WORKDIR /opt

RUN curl -L https://downloads.sourceforge.net/project/bbmap/BBMap_38.96.tar.gz -o BBMap.tar.gz && \
    tar xzf BBMap.tar.gz && \
    mv bbmap /usr/local && \
    rm -rf BBMap.tar.gz

ENV PATH="/usr/local/bbmap:${PATH}"

CMD ["bash", "bbduk.sh"]