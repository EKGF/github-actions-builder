#
# github-actions-builder
#
FROM ekgf/debian-awscli:0.0.12

USER root

ENV DEBIAN_FRONTEND noninteractive

RUN sops_version=3.6.0 && \
    sops_url=https://github.com/mozilla/sops/releases/download/v${sops_version}/sops-v${sops_version}.linux && \
    apt-get update && \
    apt-get install -y curl apt-transport-https ca-certificates curl gnupg2 software-properties-common && \
    curl -qsL --url ${sops_url} -o /usr/local/bin/sops && \
    chmod +x /usr/local/bin/sops &&  \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
    apt-get update && \
    apt-cache policy docker-ce && \
    apt-get install -y docker-ce


WORKDIR /
ENTRYPOINT [ "/bin/bash" ]
