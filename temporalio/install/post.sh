#!/usr/bin/env bash
set -euo pipefail

NAME=$(awk '/^name:/{print $2}' config.yaml) \
  perl -pi -e 's#NAME_REPLACE_THIS#$ENV{NAME}#' config.temporalio.yaml
TEMPORALIO_ROADRUNNER_IMAGE=$(awk '/^temporalio_roadrunner_image:/{print $2}' config.temporalio.user.yaml) \
  perl -pi -e 's#TEMPORALIO_ROADRUNNER_IMAGE_REPLACE_THIS#$ENV{TEMPORALIO_ROADRUNNER_IMAGE}#' web-build/Dockerfile.temporalio
