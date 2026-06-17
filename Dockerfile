FROM alpine:3.23
LABEL author="JamesClonk <jamesclonk@jamesclonk.ch>"

ARG KIRO_VERSION=1.28.3
ARG FIXUID_VERSION=0.6.0

RUN apk upgrade --no-cache && \
    apk add --no-cache ca-certificates go curl bash unzip jq git gcompat

RUN addgroup -g 501 kiro && \
    adduser -u 501 -G kiro -h /home/kiro -s /bin/bash -D kiro

RUN USER=kiro && \
    GROUP=kiro && \
    curl -SsL "https://github.com/boxboat/fixuid/releases/download/v${FIXUID_VERSION}/fixuid-${FIXUID_VERSION}-linux-amd64.tar.gz" | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: ${USER}\ngroup: ${GROUP}\n" > /etc/fixuid/config.yml

USER kiro:kiro

RUN curl -fsSL -o /tmp/kirocli.zip \
    "https://prod.download.cli.kiro.dev/stable/${KIRO_VERSION}/kirocli-x86_64-linux-musl.zip" && \
    cd /tmp && unzip kirocli.zip && cd kirocli && KIRO_CLI_SKIP_SETUP=1 bash install.sh && \
    rm -rf /tmp/kirocli*

ENV PATH="/home/kiro/.local/bin:${PATH}"
ENV PATH="/home/kiro/bin:${PATH}"
VOLUME /home/kiro/.kiro
VOLUME /home/kiro/project
WORKDIR /home/kiro/project

ENTRYPOINT ["fixuid"]
