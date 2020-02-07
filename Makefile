.PHONY: build test run shell gcp

export DIR = $(shell pwd)
export WORK_DIR = $(shell dirname ${DIR})
export CONTAINER_IMAGE = 'vin-lab-super-netops'

default: build test

dev: build shell

run: build test init plan apply

build:
	docker build -t ${CONTAINER_IMAGE} .

gcp:
	@echo "gcp ${WORK_DIR}"
	@docker run --rm -it \
	--volume ${DIR}:/workspace \
	--volume ${DIR}/ansible/context:/workspace/ansible/context \
	--volume ${DIR}/ansible/roles:/workspace/ansible/roles \
	--volume ${DIR}/ansible/playbooks:/workspace/ansible/playbooks \
	--volume ${DIR}/ansible/scripts:/workspace/ansible/scripts \
	--volume ${DIR}/ansible/collections:/workspace/ansible/collections \
	--volume ${DIR}/ansible/hosts:/workspace/ansible/hosts \
	--volume ${DIR}/ansible/host_vars:/workspace/ansible/host_vars \
	-v ${SSH_KEY_DIR}/${SSH_KEY_NAME}.pub:/root/.ssh/${SSH_KEY_NAME}.pub:ro \
	-v ${SSH_KEY_DIR}/${SSH_KEY_NAME}:/root/.ssh/${SSH_KEY_NAME}:ro \
	-v ${DIR}/creds/gcp:/creds/gcp:ro \
	-e SSH_KEY_NAME=${SSH_KEY_NAME} \
	-e ANSIBLE_VAULT_PASSWORD=${ANSIBLE_VAULT_PASSWORD} \
	-e ARM_CLIENT_ID=${ARM_CLIENT_ID} \
	-e ARM_CLIENT_SECRET=${ARM_CLIENT_SECRET} \
	-e ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID} \
	-e ARM_TENANT_ID=${ARM_TENANT_ID} \
	-e GCP_SA_FILE=${GCP_SA_FILE} \
	-e GCP_PROJECT_ID=${GCP_PROJECT_ID} \
	-e GCP_REGION=${GCP_REGION} \
	${CONTAINER_IMAGE} \
	bash -c "terraform init --target module.gcp;terraform plan --target module.gcp;terraform apply --target module.gcp --auto-approve;"


shell:
	@echo "shell ${WORK_DIR}"
	@docker run --rm -it \
	--volume ${DIR}:/workspace \
	--volume ${DIR}/ansible/context:/workspace/ansible/context \
	--volume ${DIR}/ansible/roles:/workspace/ansible/roles \
	--volume ${DIR}/ansible/playbooks:/workspace/ansible/playbooks \
	--volume ${DIR}/ansible/scripts:/workspace/ansible/scripts \
	--volume ${DIR}/ansible/collections:/workspace/ansible/collections \
	--volume ${DIR}/ansible/hosts:/workspace/ansible/hosts \
	--volume ${DIR}/ansible/host_vars:/workspace/ansible/host_vars \
	-v ${SSH_KEY_DIR}/${SSH_KEY_NAME}.pub:/root/.ssh/${SSH_KEY_NAME}.pub:ro \
	-v ${SSH_KEY_DIR}/${SSH_KEY_NAME}:/root/.ssh/${SSH_KEY_NAME}:ro \
	-v ${DIR}/creds/gcp:/creds/gcp:ro \
	-e SSH_KEY_NAME=${SSH_KEY_NAME} \
	-e ANSIBLE_VAULT_PASSWORD=${ANSIBLE_VAULT_PASSWORD} \
	-e ARM_CLIENT_ID=${ARM_CLIENT_ID} \
	-e ARM_CLIENT_SECRET=${ARM_CLIENT_SECRET} \
	-e ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID} \
	-e ARM_TENANT_ID=${ARM_TENANT_ID} \
	-e GCP_SA_FILE=${GCP_SA_FILE} \
	-e GCP_PROJECT_ID=${GCP_PROJECT_ID} \
	-e GCP_REGION=${GCP_REGION} \
	${CONTAINER_IMAGE} \
	bash -c ". ../ansible/scripts/.ssh_key.sh && bash"

test: test1 test2 test3 test4

test1:
	@echo "python test"
	@docker run --rm -it \
	${CONTAINER_IMAGE} \
	bash -c "python --version"
test2:
	@echo "ansible test"
	@docker run --rm -it \
	${CONTAINER_IMAGE} \
	bash -c "ansible --version"
test3:
	@echo "terraform test"
	@docker run --rm -it \
	--volume ${DIR}:/workspace \
	${CONTAINER_IMAGE} \
	bash -c "terraform --version "
test4:
	@echo "terraform + ansible test"
	@docker run --rm -it \
	--volume ${DIR}:/workspace \
	${CONTAINER_IMAGE} \
	bash -c "terraform apply --target module.test --auto-approve"