# Setup build arguments with default versions
ARG TERRAFORM_VERSION=0.12.20
ARG ANSIBLE_VERSION=latest
ARG PYTHON_VERSION=3.8

# terraform image
FROM alpine:latest as terraform
ARG TERRAFORM_VERSION
COPY /terraform/hashicorp.asc hashicorp.asc
RUN set -ex \
&& apk --update add curl unzip gnupg \
&&  curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS \
&& curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
&& curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig \
&& gpg --import hashicorp.asc \
&& gpg --verify terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig terraform_${TERRAFORM_VERSION}_SHA256SUMS \
&& grep terraform_${TERRAFORM_VERSION}_linux_amd64.zip terraform_${TERRAFORM_VERSION}_SHA256SUMS | sha256sum -c - \
&& unzip -j terraform_${TERRAFORM_VERSION}_linux_amd64.zip
# ansible image
FROM alpine:latest as ansible
ARG PYTHON_VERSION
RUN set -ex \
 && apk --update add rpm python3 openssl ca-certificates openssh-client bash jq git libxml2 libxslt-dev libxml2-dev \
 && apk --update add --virtual build-dependencies python3-dev libffi-dev openssl-dev build-base \
 && pip3 install --upgrade pip pycrypto cffi \
 && pip3 install ansible \
 && pip3 install jinja2==2.10.1 \
 && pip3 install netaddr==0.7.19 \
 && pip3 install pbr==5.2.0 \
 && pip3 install hvac==0.8.2 \
 && pip3 install jmespath==0.9.4 \
 && pip3 install ruamel.yaml==0.15.96 \
 && pip3 install f5-sdk \
 && pip3 install bigsuds \
 && pip3 install objectpath \
 && pip3 install packaging \
 && pip3 install boto3 botocore \
 && pip3 install awscli --upgrade \
 && pip3 install pyvmomi \
 && pip3 install --upgrade git+https://github.com/vmware/vsphere-automation-sdk-python.git \
 && pip3 install requests google-auth \
 && apk del build-dependencies \
 && rm -rf /var/cache/apk/* \
 && mkdir -p /etc/ansible
COPY /ansible/ansible.cfg /etc/ansible/ansible.cfg
COPY /ansible/hosts /etc/ansible/hosts
# add roles
RUN set -ex \
        && ansible-galaxy install f5devcentral.f5app_services_package \
        && ansible-galaxy install f5devcentral.bigip_onboard \
        && ansible-galaxy install f5devcentral.bigip_ha_cluster \
        && ansible-galaxy install geerlingguy.repo-epel \
        && ansible-galaxy install geerlingguy.git \
        && ansible-galaxy install geerlingguy.ansible \
        && ansible-galaxy install geerlingguy.docker \
        && ansible-galaxy install geerlingguy.pip \
        && ansible-galaxy install geerlingguy.nodejs \
        && ansible-galaxy install geerlingguy.awx \
        && ansible-galaxy install geerlingguy.nfs \
        && ansible-galaxy collection install geerlingguy.k8s \
        && ansible-galaxy install gantsign.helm \
        && ansible-galaxy install nginxinc.nginx \
        && ansible-galaxy install f5devcentral.atc_deploy

#final image
FROM alpine:latest
ARG PYTHON_VERSION

#env vars
ENV ANSIBLE_GATHERING smart
ENV ANSIBLE_HOST_KEY_CHECKING false
ENV ANSIBLE_RETRY_FILES_ENABLED false
ENV ANSIBLE_ROLES_PATH /etc/ansible/roles/
ENV ANSIBLE_SSH_PIPELINING True
# ENV PYTHONPATH /ansible/lib
# ENV PATH /ansible/bin:$PATH
ENV ANSIBLE_LIBRARY /ansible/library

# dependencies

# This hack is widely applied to avoid python printing issues in docker containers.
# See: https://github.com/Docker-Hub-frolvlad/docker-alpine-python3/pull/13
ENV PYTHONUNBUFFERED=1

RUN echo "**** install Python ****" && \
    apk add --no-cache python3 && \
    if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
    \
    echo "**** install pip ****" && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --no-cache --upgrade pip setuptools wheel && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi

RUN apk update && apk add bash curl jq \
&& rm -rf /var/cache/apk/*
COPY --from=terraform /terraform /usr/local/bin/terraform
COPY --from=ansible /etc/ansible /etc/ansible
COPY --from=ansible /usr/bin/ansible* /usr/local/bin/
COPY --from=ansible /usr/bin/ssh /usr/local/bin/ssh
COPY --from=ansible /usr/bin/ssh-* /usr/local/bin/
COPY --from=ansible /usr/lib/python3.8/site-packages/ /usr/lib/python3.8/site-packages/


WORKDIR /workspace/terraform
CMD ["bash"]