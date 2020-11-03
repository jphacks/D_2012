#!/usr/bin/env bash
set -o errexit

REPO_ROOT_DIR=$(dirname $0)

KO_DOCKER_REPO=gcr.io/jphacks2020/broadcaster ko publish github.com/jphacks/D_2012/backend/cmd/broadcaster
