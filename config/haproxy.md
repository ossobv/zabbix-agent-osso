<!-- [This file is part of the zabbix-agent-osso package] -->

# Haproxy

The haproxy script and template are a minimal monitoring solution for haproxy
servers to monitor that all backends are availible, and the server is not
running into its max connection (maxconn) setting.

The haproxy loadbalancer script works by getting all sockets like
`/var/run/haproxy/{CUSTOMER}/{INSTANCE}.stats`.

The stats socket should be enabled in the haproxy configs like:
```
stats socket /var/run/haproxy/{CUSTOMER}/{INSTANCE}.stats level admin
```
The script requires python3.

With the goal of keeping the items to a minimum, the zabbix template creates
items for only a subset of data points in the `haproxy get-all-data` output.

Backend availability and max connection thresholds can be tuned in the zabbix
triggers. The defaults are 100% of availability and max 80% connection
utilization.
