#!/usr/bin/env bash
set -euo pipefail

DOCKER_IMAGE_NAME="localhost/kiro-jail"
AWS_CONFIG_LOCATION="${HOME}/.aws_identity_provider"
KIRO_CONFIG_LOCATION="${HOME}/.kiro"

echo "== Reading config... =="
if [[ -f "${AWS_CONFIG_LOCATION}" ]]; then
	source "${AWS_CONFIG_LOCATION}"
	echo "Config loaded from ${AWS_CONFIG_LOCATION}"
else
	echo "Using defaults - see README to customize"
fi

AWS_IDENTITY_PROVIDER_URL=${AWS_IDENTITY_PROVIDER_URL:-https://your-value.awsapps.com/start}
AWS_REGION=${AWS_REGION:-eu-central-1}
CONTAINER_NAME="kiro-$(basename $(pwd))"
KIRO_UID=$(id -u)
KIRO_GID=$(id -g)

# build the image if not found locally
if ! podman images | grep "${DOCKER_IMAGE_NAME}" >/dev/null; then
	echo "== Image ${DOCKER_IMAGE_NAME} not found locally, building it... =="
	podman build . -t "${DOCKER_IMAGE_NAME}"
fi

# create config dir if not existing
mkdir -p "${KIRO_CONFIG_LOCATION}"

echo "== Starting container... =="
podman run -it --rm \
	-v "${KIRO_CONFIG_LOCATION}:/home/kiro/.kiro:rw,Z" \
	-v "$(pwd):/home/kiro/project:rw,Z" \
	-w /home/kiro/project \
	-u "${KIRO_UID}:${KIRO_GID}" --userns keep-id \
	--name "${CONTAINER_NAME}" \
	"${DOCKER_IMAGE_NAME}" /bin/bash \
	-c "kiro-cli login --identity-provider ${AWS_IDENTITY_PROVIDER_URL} --region ${AWS_REGION} --use-device-flow; kiro-cli"

echo "== Goodbye! =="
