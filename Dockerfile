FROM ubuntu:16.04
LABEL maintainer="Betacloud Solutions GmbH (https://www.betacloud-solutions.de)"

ARG VERSION
ENV VERSION ${VERSION:-luminous}

ENV DEBIAN_FRONTEND noninteractive

ENV USER_ID ${USER_ID:-45000}
ENV GROUP_ID ${GROUP_ID:-45000}

USER root

ADD files/run.sh /run.sh

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y \
        apt-transport-https \
        software-properties-common \
        wget \
    && wget -q -O- https://download.ceph.com/keys/release.asc | apt-key add - \
    && apt-add-repository "deb https://download.ceph.com/debian-$VERSION/ xenial main" \
    && apt-get update \
    && apt-get install -y \
        ceph \
        fio \
        vim \
    && groupadd -g $GROUP_ID dragon \
    && useradd -g dragon -u $USER_ID -m -d /home/dragon dragon \
    && apt-get clean \
    && mkdir /configuration \
    && rm -rf \
      /var/lib/apt/lists/* \
      /var/tmp/*

USER dragon

VOLUME ["/etc/ceph"]

ENTRYPOINT ["/run.sh"]
