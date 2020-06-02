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

ENV YQ_VERSION="3.3.0"

#
#   This image runs on kubernetes in Google Cloud and on OpenShift. Ideally we have one
#   strict setup with a non-root user in its own group but since OpenShift assigns the uid
#   for you we cannot assume that our top level process runs with our assigned uid.
#   What we do know however is that the Openshift assigned user id always has group 0 (the root group)
#   so we're using the user ekggroup in group root for all non-openshift deployments.
#
#   See also https://www.openshift.com/blog/jupyter-on-openshift-part-6-running-as-an-assigned-user-id
#   
ARG UID=2000
ENV HOME=/home/ekgprocess
RUN useradd --system --no-user-group --home-dir /home/ekgprocess --create-home --shell /bin/bash --uid ${UID} --gid 0 ekgprocess && \
    chgrp -Rf root /home/ekgprocess && chmod -Rf g+w /home/ekgprocess

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

USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils 2> >( grep -v 'since apt-utils is not installed' >&2 ) && \
    apt-get install -y -qq \
    	uuid-dev \
    	dirmngr \
    	gnupg \
    	less \
    	groff \
        ca-certificates \
		netbase \
        git \
    	wget \
    	curl \
		unzip \
    	jq \
    	rsync \
#       python3-gssapi \
#       krb5-user \
#		libkrb5-dev \
    	&& \
#   create /home/ekgprocess/.cache and own it as root to avoid red warning messages during docker build
    mkdir -p /home/ekgprocess/.cache && chown root /home/ekgprocess/.cache && \
    python3 -m pip install --upgrade pip && \
#   install wheel just to avoid all kinds of messages during docker build
    python3 -m pip install wheel && \
    python3 -m pip install rdflib && \
    python3 -m pip install git+https://github.com/rdflib/sparqlwrapper#egg=sparqlwrapper && \
    python3 -m pip install requests && \
    python3 -m pip install boto3 && \
    python3 -m pip install pystardog && \
    python3 -m pip install owlrl && \
    python3 -m pip install pandas && \
    python3 -m pip install stringcase && \
    python3 -m pip install unidecode && \
    python3 -m pip install humps && \
    python3 -m pip install xlrd && \
    python3 -m pip install ldap3 && \
#   python3 -m pip install gssapi && \
#   no more pip installs after this point so we can now remove the .cache directory
    rm -rf /home/ekgprocess/.cache && \
#
#   yq
#
    curl -L "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" -o /usr/bin/yq && \
    chmod +x /usr/bin/yq && \
    yq --version && \
#
#   Install awscli version 2 in /app/.local/bin (that's what the --user option does)
#
    mkdir -p /home/ekgprocess/awscli-download && cd /home/ekgprocess/awscli-download && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip -q "awscliv2.zip" && \
    rm -f "awscliv2.zip" && \
    ./aws/install && \
#   now clean up and delete awscli stuff we don't need in an image
    cd /home/ekgprocess && rm -rf awscli-download && \
    rm -rf /usr/local/aws-cli/v2/current/dist/awscli/examples && \
    rm -rf /usr/local/aws-cli/v2/current/dist/awscli/topics && \
    ( \
      set -x && \
      aws --version \
    ) && \
    apt-get clean -y && \
    rm -rf /app/.cache >/dev/null 2>&1 || true && \
#
#   just to be sure, everything we added to the home directory is owned by user ekgprocess
#   and group root (see openshift comments at the top of this dockerfile)
#
  	cd /home/ekgprocess && \
    chown -vR ekgprocess:root .

#
# 	now we leave the image to run as user ekgprocess from its home directory
#
USER ekgprocess
WORKDIR /home/ekgprocess
ENTRYPOINT [ "/usr/local/bin/aws" ]
