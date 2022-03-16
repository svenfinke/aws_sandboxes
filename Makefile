include .env
export

.DEFAULT_GOAL=plan

init:
	@cd terraform &&\
	terraform init --var 'state_bucket=${STATE_BUCKET}'

plan:
	@cd terraform &&\
	terraform plan

apply:
	@cd terraform &&\
	terraform apply -auto-approve

create_bucket:
	aws s3api create-bucket --bucket ${STATE_BUCKET} --region eu-central-1 --create-bucket-configuration LocationConstraint=eu-central-1