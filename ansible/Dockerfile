# final image
FROM alpine:latest
#ansible
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
# python paths
RUN if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi

# ansible config
COPY ansible.cfg /etc/ansible/ansible.cfg
COPY hosts /etc/ansible/hosts

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

#env vars
ENV ANSIBLE_GATHERING smart
ENV ANSIBLE_HOST_KEY_CHECKING false
ENV ANSIBLE_RETRY_FILES_ENABLED false
ENV ANSIBLE_ROLES_PATH /etc/ansible/roles/
ENV ANSIBLE_SSH_PIPELINING True
# ENV PYTHONPATH /ansible/lib
# ENV PATH /ansible/bin:$PATH
ENV ANSIBLE_LIBRARY /ansible/library

# files/playbooks
COPY . /etc/ansible

WORKDIR /etc/ansible

RUN chmod 700 $PWD
