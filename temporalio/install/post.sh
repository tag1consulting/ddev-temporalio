#!/usr/bin/env bash
set -euo pipefail

NAME=$(awk '/^name:/{print $2}' config.yaml)
TLD=$(awk '/^project_tld:/{print $2}' config.yaml)
TLD=${TLD:-ddev.site}
HOST="temporalio-ui.$NAME.$TLD"

sed "s/NAME_REPLACE_THIS/$NAME/" traefik/config/temporalio-ui.yaml > traefik/config/temporalio-ui.tmp
sed "s/HOST_REPLACE_THIS/$HOST/" traefik/config/temporalio-ui.tmp > traefik/config/temporalio-ui.yaml
rm traefik/config/temporalio-ui.tmp
perl -pi -e "s/NAME_REPLACE_THIS/$NAME/" config.temporalio.yaml
