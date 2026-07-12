#!/usr/bin/env bash
set -euo pipefail

NAME=$(awk '/^name:/{print $2}' config.yaml)
perl -pi -e "s/NAME_REPLACE_THIS/$NAME/" config.temporalio.yaml
