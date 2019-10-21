.PHONY: build ansible terraform


build:
	cd ./terraform/ && $(MAKE) build
	cd ./ansible/ && $(MAKE) build

ansibleShell:
	cd ./ansible/ && $(MAKE) shell
terraformShell:
	cd ./terraform/ && $(MAKE) shell

ansible:
	cd ./ansible/ && $(MAKE) run

terraform:
	cd ./terraform/ && $(MAKE) run

destroy:
	cd ./terraform/ && $(MAKE) destroy
