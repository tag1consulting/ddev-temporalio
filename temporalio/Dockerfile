#ddev-generated

FROM temporalio/admin-tools AS admin-tools

FROM temporalio/server

COPY --from=admin-tools /usr/local/bin/temporal /usr/local/bin/
COPY --from=admin-tools /usr/local/bin/temporal-sql-tool /usr/local/bin/
COPY --from=admin-tools /etc/temporal/schema /etc/temporal/schema
COPY ./temporalio/scripts/ /scripts/
COPY ./temporalio/entrypoint.sh /

USER root
RUN apk add --no-cache mariadb-client mariadb-connector-c
USER temporal

ENTRYPOINT ["/entrypoint.sh"]
