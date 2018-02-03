all: apply plan

apply:
	@terraform apply -var-file ../../vars.json

plan:
	@terraform plan -var-file ../../vars.json

destroy:
	@terraform destroy -var-file ../../vars.json
