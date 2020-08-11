#
# github-actions-builder
#
FROM ekgf/debian-awscli:0.0.7

USER root

RUN sops_version=3.6.0 && \
    sops_url=https://github.com/mozilla/sops/releases/download/v${sops_version}/sops-v${sops_version}.linux && \
    apt-get update && \
    apt-get install -y curl gnupg && \
    curl -qsL --url ${sops_url} -o /usr/local/bin/sops && \
    chmod +x /usr/local/bin/sops

WORKDIR /
ENTRYPOINT [ "/bin/bash" ]
