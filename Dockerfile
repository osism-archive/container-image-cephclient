FROM ubuntu:18.04

ARG VERSION=mimic

ENV DEBIAN_FRONTEND noninteractive

ENV USER_ID ${USER_ID:-45000}
ENV GROUP_ID ${GROUP_ID:-45000}

USER root

COPY files/run.sh /run.sh

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        apt-transport-https \
        bash-completion \
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
    && apt-get autoremove -y \
    && mkdir /configuration \
    && rm -rf \
      /var/lib/apt/lists/* \
      /var/tmp/*

USER dragon

VOLUME ["/etc/ceph"]

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/run.sh"]

LABEL "org.opencontainers.image.documentation"="https://docs.osism.io" \
      "org.opencontainers.image.licenses"="ASL 2.0" \
      "org.opencontainers.image.source"="https://github.com/osism/docker-cephclient" \
      "org.opencontainers.image.url"="https://www.osism.de" \
      "org.opencontainers.image.vendor"="Betacloud Solutions GmbH"
