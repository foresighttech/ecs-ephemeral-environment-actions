FROM hashicorp/terraform:1.1.7 as terraform


FROM python:3.9-alpine3.14
ARG TERRAFORM_REPO_PUBLIC_KEY
ARG TERRAFORM_REPO_PRIVATE_KEY
ARG TERRAFORM_REPO_GIT_URI

# Install openssh and git
RUN apk update
RUN apk add openssh
RUN apk add git

# Authorize SSH Host
RUN mkdir -p /root/.ssh && \
    chmod 0700 /root/.ssh && \
    ssh-keyscan github.com > /root/.ssh/known_hosts

# Add the keys and set permissions
RUN echo "$TERRAFORM_REPO_PRIVATE_KEY" > /root/.ssh/id_rsa && \
    echo "$TERRAFORM_REPO_PUBLIC_KEY" > /root/.ssh/id_rsa.pub && \
    chmod 600 /root/.ssh/id_rsa && \
    chmod 600 /root/.ssh/id_rsa.pub
RUN cat /root/.ssh/id_rsa.pub
# Clone the terraform repository with ephemeral environment definition
COPY --from=terraform /bin/terraform /bin/terraform
RUN cat /root/.ssh/id_rsa.pub && echo "Cloning repository: $TERRAFORM_REPO_GIT_URI" && git clone --depth 1 $TERRAFORM_REPO_GIT_URI ./terraform
# Remove SSH keys
RUN rm -rf /root/.ssh/

# Add entrypoint
COPY entrypoint.sh ./entrypoint.sh
RUN chmod +x entrypoint.sh
ENV TERRAFORM_COMMAND apply
ENV DESIRED_COUNT 1
ENV TERRAFORM_WORKING_DIRECTORY='.'


ENTRYPOINT "./entrypoint.sh"