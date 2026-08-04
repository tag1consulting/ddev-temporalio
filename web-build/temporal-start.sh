#!/usr/bin/env bash
#ddev-generated
#ddev-silent-no-warn

temporal_db_dir="/mnt/ddev-global-cache/temporalio"
temporal_version="$(/usr/local/bin/temporal --version | awk '{print $3}')"
mkdir -p "${temporal_db_dir}"

/usr/local/bin/temporal server start-dev --ui-ip 0.0.0.0 \
  --db-filename "${temporal_db_dir}/${DDEV_PROJECT}-${temporal_version}.db" &
while true; do
    if [[ -f "./.rr.yaml" ]]; then
        install_path="."
    else
        line="$(composer show drupal/temporal --path 2>/dev/null)"
        install_path="${line#drupal/temporal }"
    fi
    if [[ -n "$install_path" ]] && drush list 2>/dev/null | grep -q temporal:worker; then
        exec /usr/local/bin/rr serve -c "$install_path/.rr.yaml"
    fi
    sleep 2
done
