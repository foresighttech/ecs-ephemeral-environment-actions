#!/bin/bash
TERRAFORM_INIT_ARGS="-backend-config=bucket=nowwith-terraform-state \
      -backend-config=dynamodb_table=terraform-lock \
      -backend-config=key=ephemeral-environments/${EPHEMERAL_ENVIRONMENT_NAME}.tfstate"

TERRAFORM_APPLY_ARGS="-var='task_definition=$(jq @json < task-definition.json)' \
      -var=desired_count=1 \
      -var=domain_name=nowwithdev.com \
      -var=service_port=3000
      -var=organization_name=nowwith \
      -var=service_name=${EPHEMERAL_ENVIRONMENT_NAME} \
      -var=workload_config_path=org-tf-config/dev \
      -var=default_role_arn=arn:aws:iam::408527110522:role/LandingZoneAccess \
      -var=workload_role_arn=arn:aws:iam::408527110522:role/LandingZoneAccess \
      -var=shared_role_arn=arn:aws:iam::884890157659:role/LandingZoneAccess \
      -var=log_archive_role_arn=arn:aws:iam::689305174806:role/LandingZoneAccess \
      -var=backend_state_bucket=nowwith-terraform-state"

docker build -t ephemeral-environment-action \
    --build-arg TERRAFORM_REPO_PUBLIC_KEY="$(cat ./id_rsa.pub)" \
    --build-arg TERRAFORM_REPO_PRIVATE_KEY="$(cat ./id_rsa)" \
    --build-arg TERRAFORM_REPO_GIT_URI="git@github.com:nowwith-ventures/nowwith-infra.git" \
    ..

docker run \
    -e TERRAFORM_WORKING_DIRECTORY=workload-resources/ephemeral-service \
    -e TERRAFORM_COMMAND=apply \
    -e EPHEMERAL_ENVIRONMENT_NAME=test-env \
    -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
    -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
    -e AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN \
    -e ADDITIONAL_TERRAFORM_INIT_ARGS="$TERRAFORM_INIT_ARGS" \
    -e ADDITIONAL_TERRAFORM_APPLY_ARGS="$TERRAFORM_APPLY_ARGS" \
    ephemeral-environment-action