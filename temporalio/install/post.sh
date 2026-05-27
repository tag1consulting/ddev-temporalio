#!/usr/bin/env bash
set -euo pipefail

NAME=$(awk '/^name:/{print $2}' config.yaml)
TLD=$(awk '/^project_tld:/{print $2}' config.yaml)
TLD=${TLD:-ddev.site}
HOST="temporalio-ui.$NAME.$TLD"

docker run --rm -v $(pwd):/data -u $(id -u):$(id -g) -e "HOST=temporalio-ui.$NAME" -e GRPC='php${DDEV_PHP_VERSION}-grpc' \
  ddev/ddev-utilities yq -i '
    ((.additional_hostnames | select([.[] | . != strenv(HOST)] | all)) += [strenv(HOST)]) | 
    ((.webimage_extra_packages | select([.[] | . != strenv(GRPC)] | all)) += [strenv(GRPC)]) | 
    .webimage_extra_packages style = "flow"' /data/config.yaml

sed "s/NAME_REPLACE_THIS/$NAME/" traefik/config/temporalio-ui.yaml > traefik/config/temporalio-ui.tmp
sed "s/HOST_REPLACE_THIS/$HOST/" traefik/config/temporalio-ui.tmp > traefik/config/temporalio-ui.yaml
rm traefik/config/temporalio-ui.tmp
