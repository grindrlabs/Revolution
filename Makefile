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

place-rpms:
	@echo throwing rpms into the local repo directory
	find ./recipes -iname "*rpm" -type f | grep -v vendor | xargs -I {} cp {} repo/centos/7/x86_64/

build-repo: place-rpms
	@echo building repo locally
	cd repo && createrepo .

upload-repo: build-repo
	@echo uploading the repo to s3
	cd repo && aws s3 sync . s3://rpm.grindr.io/
