#!/usr/bin/env bash
## #ddev-generated
set -euo pipefail

NAME=$(awk '/^name:/{print $2}' config.yaml)
TLD=$(awk '/^project_tld:/{print $2}' config.yaml)
TLD=${TLD:-ddev.site}
HOST="temporalio-ui.$NAME.$TLD"

docker run --rm -v $(pwd):/data -u $(id -u):$(id -g) chx1975/ddev-install-additional-hostname "temporalio-ui.$NAME"

sed "s/NAME_REPLACE_THIS/$NAME/" traefik/config/temporalio-ui.yaml > traefik/config/temporalio-ui.tmp
sed "s/HOST_REPLACE_THIS/$HOST/" traefik/config/temporalio-ui.tmp > traefik/config/temporalio-ui.yaml
rm traefik/config/temporalio-ui.tmp
