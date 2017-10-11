#!/usr/bin/make -f

# pin to this account id
AWS_ACCOUNT:=284224159432
# account friendly name
AWS_ACCOUNT_NAME:=2.0

# fetch the current AWS account id
CURRENT_ACCOUNT:=$(shell aws iam get-user | jq -r .User.Arn | awk -F : '{print $$5;}')

all: help

help:
	@echo "Use the source!"

build-rpms:
	@echo "Building the RPMs"
	./bin/build-rpms.sh

place-rpms: build-rpms
	@echo throwing rpms into the local repo directory
	mkdir -p repo/centos/7/x86_64/
	find ./recipes -iname "*rpm" -type f | grep -v vendor | xargs -I {} cp {} repo/centos/7/x86_64/

sign-rpms: place-rpms
	@echo signing packages
	cd recipes/grindr-repo-main && $(MAKE) import_key
	rpm --addsign repo/centos/7/x86_64/*rpm

build-repo: sign-rpms
	@echo building repo locally
	cd repo/centos/7/x86_64 && createrepo .

upload-repo: build-repo
	@echo uploading the repo to s3
	cd repo && aws s3 sync . s3://rpm.grindr.io/ --delete
