.DEFAULT_GOAL=plan

init:
	@cd terraform &&\
	terraform init

plan:
	@cd terraform &&\
	terraform plan -out changes.tfstate

apply:
	@cd terraform &&\
	terraform apply -auto-approve "changes.tfstate" &&\
	rm changes.tfstate