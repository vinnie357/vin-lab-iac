.PHONY: build shell test run

export CONTAINER_IMAGE = "vin-lab-ansible"
export DIR = $(shell pwd)

default: build test shell

dev: build shell

build:
	@echo "building"
	@docker build  -t ${CONTAINER_IMAGE} .

shell:
	@echo " run docker container"
	@docker run --rm -it \
	--volume ${DIR}/context:/etc/ansible/context \
	--volume ${DIR}/roles:/etc/ansible/roles \
	--volume ${DIR}/playbooks:/etc/ansible/playbooks \
	--volume ${DIR}/scripts:/etc/ansible/scripts \
	--volume ${DIR}/collections:/etc/ansible/collections \
	--volume ${DIR}/hosts:/etc/ansible/hosts \
	--volume ${DIR}/host_vars:/etc/ansible/host_vars \
	-v ${SSH_KEY_DIR}/${SSH_KEY_NAME}:/root/.ssh/${SSH_KEY_NAME}:ro \
	-e SSH_KEY_NAME=${SSH_KEY_NAME} \
	-e ANSIBLE_VAULT_PASSWORD=${ANSIBLE_VAULT_PASSWORD} \
	vin-lab-ansible \
	bash -c ". scripts/.ssh_key.sh && bash"

shell2:
	@echo " run docker container"
	@docker run --rm -it \
	--volume ${DIR}:/ansible \
	-e ANSIBLE_VAULT_PASSWORD=${ANSIBLE_VAULT_PASSWORD} \
	${CONTAINER_IMAGE}

run:
	@echo " run docker container"
	@docker run --rm -it \
	--volume ${DIR}/ova:/ova \
	-e ANSIBLE_VAULT_PASSWORD=${ANSIBLE_VAULT_PASSWORD} \
	vin-lab-ansible \
	bash -c "ansible-playbook playbooks/deploy.yaml --vault-password-file scripts/.vault_pass.sh --extra-vars "@context/${ARGS}""

# mount --volume ${DIR}/ova:/ova



test: test1 test2 test3


test1:
	@echo "python test"
	@docker run --rm -it vin-lab-ansible \
	bash -c "python --version"
test2:
	@echo "ansible test"
	@docker run --rm -it vin-lab-ansible \
	bash -c "ansible --version"
test3:
	@echo "ansible playbook test"
	@docker run --rm -e ANSIBLE_VAULT_PASSWORD=${ANSIBLE_VAULT_PASSWORD} -it vin-lab-ansible \
	ansible-playbook --vault-password-file scripts/.vault_pass.sh playbooks/test.yaml
