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
	echo "No config file found in ${AWS_CONFIG_LOCATION}, using defaults. See README to customize"
fi

# those two are set in the AWS_CONFIG_LOCATION file
AWS_IDENTITY_PROVIDER_URL=${AWS_IDENTITY_PROVIDER_URL:-https://your-value.awsapps.com/start}
AWS_REGION=${AWS_REGION:-eu-central-1}

CONTAINER_NAME="kiro-$(basename "$(pwd)")"
KIRO_UID=$(id -u)
KIRO_GID=$(id -g)

# start podman machine if not already running
if [[ "$(podman machine inspect | jq '.[0].State')" != "\"running\"" ]]; then
	echo "== Starting podman machine... =="
	podman machine start
fi

# build the image if not found locally
if ! podman image exists "${DOCKER_IMAGE_NAME}"; then
	echo "== Image ${DOCKER_IMAGE_NAME} not found locally, building it... =="
	podman build . -t "${DOCKER_IMAGE_NAME}" -f "$(dirname "$0")/Dockerfile"
fi

# create config dir if not existing
mkdir -p "${KIRO_CONFIG_LOCATION}/settings"

# set up global ignore file - https://kiro.dev/docs/editor/kiroignore
if ! [[ -f "${KIRO_CONFIG_LOCATION}/settings/kiroignore" ]]; then
	echo "== Applying global .kiroignore settings... =="
	echo '.env*
.git/
*.pem
*.key
' >"${KIRO_CONFIG_LOCATION}/settings/kiroignore"
fi

echo "== Starting container... =="
podman run -it --rm \
	-v "${KIRO_CONFIG_LOCATION}:/home/kiro/.kiro:rw,Z" \
	-v "$(pwd):/home/kiro/project:rw,Z" \
	-w /home/kiro/project \
	-u "${KIRO_UID}:${KIRO_GID}" --userns keep-id \
	--name "${CONTAINER_NAME}" \
	"${DOCKER_IMAGE_NAME}" /bin/bash \
	-c "kiro-cli login --identity-provider '${AWS_IDENTITY_PROVIDER_URL}' --region '${AWS_REGION}' --use-device-flow; kiro-cli"

echo "== Goodbye! =="
