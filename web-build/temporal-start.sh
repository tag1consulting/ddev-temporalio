#!/usr/bin/env bash
#ddev-generated
#ddev-silent-no-warn

/usr/local/bin/temporal server start-dev --ui-ip 0.0.0.0 &
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
