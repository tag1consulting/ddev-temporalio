#!/usr/bin/env bash
#ddev-generated
#ddev-silent-no-warn

while true; do
    line="$(composer show drupal/temporal --path 2>/dev/null)"
    install_path="${line#drupal/temporal }"
    if [[ -n "$install_path" ]] && drush list 2>/dev/null | grep -q temporal:worker; then
        exec /usr/local/bin/rr serve -c "$install_path/.rr.yaml"
    fi
    sleep 2
done
