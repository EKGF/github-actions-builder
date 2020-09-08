# Base Image - github-actions-builder

github-actions-builder is based on [debian-awscli](https://github.com/EKGF/debian-awscli)
and adds the following components to that:

- Mozilla SOPS
- Docker (to be used as a client)

This image can be used in Github Actions workflows to build the components of an EKG platform.
