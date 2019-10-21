.PHONY: build test apply init plan destroy

export TF_DIR = $(shell pwd)
export CONTAINER_IMAGE = "vin-lab-terraform"

default: build test

dev: build shell

run: build test init plan apply

shell:
	@echo "tf shell"
	@docker run --rm -it \
	--volume ${TF_DIR}:/workspace \
	vin-lab-terraform \

apply:
	@#terraform apply --auto-approve -var "bigiq_host=${BIGIQ_HOST}" -var "bigiq_user=${BIGIQ_USERNAMENAME}" -var "bigiq_password=${BIGIQ_PASSWORD}"
	@echo "apply"
	@docker run --rm -it \
	--volume ${TF_DIR}/vsphere:/workspace \
	vin-lab-terraform \
	sh -c "terraform apply --auto-approve"

init:
	@#terraform init
	@echo "init"
	@docker run --rm -it \
	--volume ${TF_DIR}/vsphere:/workspace \
	vin-lab-terraform \
	sh -c "terraform init"

plan:
	@#terraform plan -var "bigiq_host=${BIGIQ_HOST}" -var "bigiq_user=${BIGIQ_USERNAMENAME}" -var "bigiq_password=${BIGIQ_PASSWORD}"
	@echo "plan"
	@docker run --rm -it \
	--volume ${TF_DIR}/vsphere:/workspace \
	vin-lab-terraform \
	sh -c "terraform plan"

destroy:
	@#terraform destroy --auto-approve
	@echo "destroy"
	@docker run --rm -it \
	--volume ${TF_DIR}/vsphere:/workspace \
	vin-lab-terraform \
	sh -c "terraform destroy --auto-approve"

build:
	docker build -t ${CONTAINER_IMAGE} .

test: test1

test1:
	@echo "terraform install"
	@docker run --rm -it \
	--volume ${TF_DIR}:/workspace \
	-e ARM_CLIENT_ID=${ARM_CLIENT_ID} \
	-e ARM_CLIENT_SECRET=${ARM_CLIENT_SECRET} \
	-e ARM_SUBSCRIPTION_ID=${ARM_SUBSCRIPTION_ID} \
	-e ARM_TENANT_ID=${ARM_TENANT_ID} \
	vin-lab-terraform \
	sh -c "terraform --version "
