<!-- [This file is part of the zabbix-agent-osso package] -->

# k8s-galera

The k8s galera monitoring script monitors galera clusters setup with the mariadb operator for kubernetes.
The script gets its status information from the mariadb cluster CRD inside your kubernetes cluster.

For more information about the mariadb kubernetes operator, visit the [project homepage](https://github.com/mariadb-operator/mariadb-operator).

Before setting up galera monitoring make sure your hosts have the following packages installed:

- `jq`
- `kubectl`

To setup galera monitoring perform the following steps:

1. Add the following label to any namespace containing a galera cluster:
   `ossobv/zabbix-agent-osso.k8s-galera=true`

2. Add the `Template k8s-galera.xml` template to your hosts in the zabbix interface.
