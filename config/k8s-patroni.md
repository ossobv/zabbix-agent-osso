<!-- [This file is part of the zabbix-agent-osso package] -->

# k8s-patroni

The k8s patroni monitoring works by running a script as a sidecar, or in a cronjob.
This script writes all statuses available in the container to a configmap.
These configmaps are then automatically discovered by the zabbix-agent.

To setup patroni monitoring you have to follow these steps:

1. Label the namespaces to be monitored with:
   `ossobv/zabbix-agent-osso.k8s-patroni=true`.

2. Create an Ubuntu sidecar in all patroni pods that you want to monitor, or add the script to a cronjob.

    If you use the script in a cronjob we advise using `run-one` and `timeout`:

    ```cron
    * * * * * postgres run-one timeout 1m envdir /tmp/scripts/postgres-status.sh
    ```

3. Give this sidecar a serviceaccount that can create configmaps.

    - You have to manually create the configmaps the first time:
      `kubectl create cm status-<status_name> --from-literal status=null`
    - The serviceaccount only needs patch permissions, and can be limited
      to only the monitored namespaces.

4. Mount the following script to the sidecar, and make it run every 30 seconds.

    ```sh
    #!/bin/bash
    umask 0077
    ROLE=$(curl -s http://localhost:8008 | jq -r .role)
    # there is only one master, use this to prevent double status checks.
    if test $ROLE == "master"; then
        CA_CERT="/var/run/secrets/kubernetes.io/serviceaccount/ca.crt";
        sed -e 's/^/Authorization: Bearer /' /var/run/secrets/kubernetes.io/serviceaccount/token >/tmp/auth
        CLUSTER_STATUS=$(curl localhost:8008/cluster)
        curl localhost:8008/config > /tmp/patroni-config.json
        PATRONI_ARCHIVE_ENABLED="$(jq -r '.postgresql.parameters.archive_mode == "on"' /tmp/patroni-config.json)"
        PATRONI_ARCHIVE_COMMAND_SET="$(jq -r '.postgresql.parameters.archive_command != null' /tmp/patroni-config.json)"

        WALG_LAST_BACKUP="$(envdir /etc/wal-g.d/env wal-g backup-list --json 2> /dev/null | jq '.[-1] // {}' -c)"
        WALG_TIMELINE="$(envdir /etc/wal-g.d/env wal-g wal-verify timeline --json 2>/dev/null)"
        WALG_INTEGRITY="$(envdir /etc/wal-g.d/env wal-g wal-verify integrity --json 2>/dev/null)"

        REQUEST_JSON="$(echo "{\"cluster_status\": ${CLUSTER_STATUS}, \"patroni_archive_enabled\": ${PATRONI_ARCHIVE_ENABLED}, \"patroni_archive_command_set\": ${PATRONI_ARCHIVE_COMMAND_SET}, \"walg_last_backup\": ${WALG_LAST_BACKUP}, \"walg_timeline\": ${WALG_TIMELINE}, \"walg_integrity\": ${WALG_INTEGRITY}}" | jq -c .)"

        PAYLOAD="[{\"op\" : \"replace\", \"path\" : \"/data/status\", \"value\" : \"${REQUEST_JSON//\"/\\\"}\" }]"
        curl --cacert ${CA_CERT} --header @/tmp/auth --header "Content-Type: application/json-patch+json" --request PATCH --data "${PAYLOAD}" \
        https://kubernetes.default.svc:443/api/v1/namespaces/${POD_NAMESPACE}/configmaps/status-${STATUS_NAME}

        echo "status updated"
    else
        echo "Not eligable, I am replica"
    fi
    ```

5. Load the template and enable the template for the hosts:

    - The hosts should have `kubectl` installed and have access to the cluster and its namespaces.

    - For the wal-g environment variables in cron you can use a mounted secret/configmap at `/etc/wal-g.d/env`,
      here you also define `POD_NAMESPACE` and `STATUS_NAME`.
    - Patroni is accessed trough `localhost`, because the cli needs multiple environment variables,
      which we don't want to define in an extra configmap (it's a rest api anyways).
