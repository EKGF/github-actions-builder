#
# debian-awscli is a lightweight base image that has bash, python3 and the AWS CLI on board (for S3 access)
#
# We switched from Alpine to Debian for this image due to these two articles:
# - https://pythonspeed.com/articles/base-image-python-docker-images/
# - https://pythonspeed.com/articles/alpine-docker-python/
#
# TODO: Make this a multi-stage dockerfile, we don't need the full C compiler and all that in the base image!
#
FROM python:3.8-slim-buster

ENV AWSCLI_VERSION="1.18.56"
ENV YQ_VERSION="3.3.0"

ENV PATH="/app/.local/bin:${PATH}"

#
# This hack is widely applied to avoid python printing issues in docker containers.
# See: https://github.com/Docker-Hub-frolvlad/docker-alpine-python3/pull/13
#
ENV PYTHONUNBUFFERED=1

#
# The two lines below are there to prevent a red line error to be shown about apt-utils not being installed
#
ARG DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]


RUN \
  whoami && \
  apt-get update && \
  apt-get install -y --no-install-recommends apt-utils 2> >( grep -v 'since apt-utils is not installed' >&2 ) && \
  apt-get install -y -qq less groff ca-certificates wget curl jq git rsync && \
  pip install --upgrade pip && \
  pip install awscli==$AWSCLI_VERSION  && \
  pip install rdflib  && \
  pip install git+https://github.com/rdflib/sparqlwrapper#egg=sparqlwrapper  && \
  pip install requests  && \
  pip install boto3  && \
  pip install pystardog  && \
  curl -L "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" -o /usr/bin/yq && \
  chmod +x /usr/bin/yq && \
  yq --version && \
  apt-get autoremove --purge -y git && \
  apt-get clean -y && \
  rm -rf /app/.cache >/dev/null 2>&1 || true && \
  mkdir -p /app/.aws

WORKDIR /app/

ENTRYPOINT [ "/usr/local/bin/aws" ]
