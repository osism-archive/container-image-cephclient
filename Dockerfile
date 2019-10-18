FROM ubuntu:18.04
LABEL maintainer="Betacloud Solutions GmbH (https://www.betacloud-solutions.de)"

ARG VERSION
ENV VERSION ${VERSION:-mimic}

ENV DEBIAN_FRONTEND noninteractive

ENV USER_ID ${USER_ID:-45000}
ENV GROUP_ID ${GROUP_ID:-45000}

USER root

COPY files/run.sh /run.sh

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        apt-transport-https \
        gpg-agent \
        software-properties-common \
        wget \
    && wget -q -O- https://download.ceph.com/keys/release.asc | apt-key add - \
    && apt-add-repository "deb https://download.ceph.com/debian-$VERSION/ bionic main" \
    && apt-get update \
    && apt-get install --no-install-recommends -y \
        ceph \
        dumb-init \
        fio \
        vim \
    && groupadd -g $GROUP_ID dragon \
    && useradd -g dragon -u $USER_ID -m -d /home/dragon dragon \
    && apt-get clean \
    && apt-get purge -y lib*-dev \
    && apt-get autoremove -y \
    && mkdir /configuration \
    && rm -rf \
      /var/lib/apt/lists/* \
      /var/tmp/*

USER dragon

VOLUME ["/etc/ceph"]

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/run.sh"]
