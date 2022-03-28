#!/bin/sh
terraform -chdir=./terraform/${TERRAFORM_WORKING_DIRECTORY} init \
    ${ADDITIONAL_TERRAFORM_INIT_ARGS}
terraform -chdir=./terraform/${TERRAFORM_WORKING_DIRECTORY} ${TERRAFORM_COMMAND} \
    -var=ephemeral_environment_name=${EPHEMERAL_ENVIRONMENT_NAME} \
    ${ADDITIONAL_TERRAFORM_APPLY_ARGS}