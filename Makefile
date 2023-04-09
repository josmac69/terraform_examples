# Define the Terraform Docker image and the working directory inside the container
DOCKER_IMAGE := hashicorp/terraform:latest
WORK_DIR := /app

# Define the minikube profile to use
MINIKUBE_PROFILE := minikube

# Define the local directory that contains the Terraform files
TERRAFORM_DIR := $(shell pwd)/terraform
EXAMPLE ?= example

# Define a helper function to run Terraform commands in the Docker container
define terraform
	docker run --rm -it \
		--network host \
		-v $$HOME/.kube:/root/.kube \
		-v $$HOME/.minikube:$$HOME/.minikube \
		-v $$HOME/.terraform.d:/root/.terraform.d \
		-e KUBECONFIG=/root/.kube/config \
		-e TF_LOG=INFO \
		-v $(TERRAFORM_DIR)/$(EXAMPLE):$(WORK_DIR) \
		-w $(WORK_DIR) \
		$(DOCKER_IMAGE) $(1)
endef

#		-e CA_CERT=/root/.minikube/ca.crt \
		-e CLIENT_CERT=/root/.minikube/profiles/minikube/client.crt \
		-e CLIENT_KEY=/root/.minikube/profiles/minikube/client.key \


# Define the default target to run Terraform init in the container
.PHONY: init
init:
	@$(call terraform, init)

# Define additional targets to run other Terraform commands in the container
.PHONY: plan
plan:
	@$(call terraform, plan)

.PHONY: apply
apply:
	@$(call terraform, apply)

.PHONY: destroy
destroy:
	@$(call terraform, destroy)

# Define the default target to start the minikube cluster
.PHONY: minikube-start \
	minikube-stop \
	minikube-list \
	clean

minikube-start:
	minikube start --profile $(MINIKUBE_PROFILE)

# Define a target to stop the minikube cluster
minikube-stop:
	minikube stop --profile $(MINIKUBE_PROFILE)
	minikube delete --profile $(MINIKUBE_PROFILE)

minikube-list:
	kubectl get pods --all-namespaces
	minikube profile list
	kubectl config use-context minikube
	kubectl version --output=json

# Target for stopping all running Docker containers
clean:
	docker rm -f $$(docker ps -aq)
