<!-- [This file is part of the zabbix-agent-osso package] -->

# k8s-patroni

The k8s patroni monitoring works by running a script as a sidecar, or in a cronjob.
This script writes all statuses available in the container to a configmap.
These configmaps are then automatically discovered by the zabbix-agent.

To setup patroni monitoring you have to follow the following steps:

1. Label the namespaces to be monitored with:
   `ossobv/zabbix-agent-osso.k8s-patroni=true`.

2. Create an Ubuntu sidecar in all patroni pods that you want to monitor, or add the script to a cronjob.

    If you use the script in a cronjob we advise using `run-one` and `timeout`:

    ```cron
    * * * * * postgres run-one timeout 1m /tmp/scripts/postgres-status.sh
    ```
    
    Or when using the zalando postgres operator you can use the our custom sidecar image:   [Zalando-postgres-scraper](https://git.osso.nl/pub/docker/zalando-postgres-scraper).
    This image includes the script, and needs wal-g environment settings.
    See the project's README for an example.

3. Give this sidecar a serviceaccount that can create configmaps.
    - You have to manually create the configmaps the first time:
      `kubectl create cm status-<status_name> --from-literal status=null`
    - The serviceaccount only needs patch permissions, and can be limited
      to only the monitored namespaces.

4. Mount the postgres-status.sh script to the sidecar.
    The latest version of the script can be found [here](https://git.osso.nl/pub/docker/zalando-postgres-scraper/-/blob/master/postgres-status.sh)

5. The configmap should now be filled by the script. A truncated example of the json content:
    ```json
    {
      "cluster_status": {
        "members": [
          {
            "name": "acid-postgres-0",
            "role": "replica",
            "state": "streaming",
            "api_url": "http://1.2.3.4:8008/patroni",
            "host": "1.2.3.4",
            "port": 5432,
            "timeline": 10,
            "lag": 0
          } 
          ...
        ],
        "scope": "acid-postgres"
      },
      "patroni_archive_enabled": true,
      "patroni_archive_command_set": false,
      "walg_last_backup": {
        "backup_name": "base_0000000A00000007000000D1",
        "time": "2025-02-17T18:22:45.192Z",
        "wal_file_name": "0000000A00000007000000D1",
        "storage_name": "default"
      },
      "walg_timeline": {
        "timeline": {
          "status": "OK",
          "details": {
            "current_timeline_id": 10,
            "highest_storage_timeline_id": 10
          }
        }
      },
      "walg_integrity": {
        "integrity": {
          "status": "FAILURE",
          "details": [
            {
              "timeline_id": 1,
              "start_segment": "000000010000000000000009",
              "end_segment": "00000001000000000000003E",
              "segments_count": 54,
              "status": "MISSING_LOST"
            }
            ...
          ]
        }
      },
      "current_timestamp": 1739886583
    }
    ```

    - For more info on the wal-g output see the [docs](https://wal-g.readthedocs.io/PostgreSQL/)

6. Load the template and enable the template for the hosts:

    - The hosts should have `kubectl` installed and have access to the cluster and its namespaces.
    - For the wal-g environment variables in cron you can use a mounted secret/configmap at `/etc/wal-g.d/env`,
      here you also define `POD_NAMESPACE` and `STATUS_NAME`.
    - `STATUS_NAME` needs to start with either `postgres` or `citus`.
    - Patroni is accessed trough `localhost`, because the cli needs multiple environment variables,
      which we don't want to define in an extra configmap (it's a rest api anyways).
    - Some wal-g commands like `wal-g wal-verify timeline` need a connection to postgres to work,
    this can be setup with a socket or `PGHOST` env vars.
