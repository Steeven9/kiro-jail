# kiro-jail

[![License](https://img.shields.io/github/license/steeven9/kiro-jail)](/LICENSE)
[![Pipeline](https://github.com/steeven9/kiro-jail/actions/workflows/docker-image.yml/badge.svg)](https://github.com/steeven9/kiro-jail/actions/workflows/docker-image.yml)

kiro-cli container image &amp; runner script

## Setup

1. Make sure you have [Podman](https://podman.io) and [jq](https://jqlang.org) installed
1. Populate `~/.aws_identity_provider` with the appropriate variables
    - `AWS_IDENTITY_PROVIDER_URL` which should be defined from your org
    - `AWS_REGION` if you want to override the default one (eu-central-1)

## Usage

```bash
./kiro-jail.sh
```

## Docs

Official Kiro CLI: <https://kiro.dev/docs/cli>

Fixuid: <https://github.com/boxboat/fixuid>
