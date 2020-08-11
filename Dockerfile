#
# github-actions-builder
#
FROM ekgf/debian-awscli:0.0.7

USER root
WORKDIR /
ENTRYPOINT [ "/bin/bash" ]
