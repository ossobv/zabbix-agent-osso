<!-- [This file is part of the zabbix-agent-osso package] -->

# k8s-redis

The k8s redis monitoring works by running a script as a sidecar.
This script writes all statuses available in the container to a configmap.
These confimaps are automatically discovered by the zabbix-agent.

To use the redis monitoring you have to do the following steps:

1. Label the namespaces to be monitored with
   `ossobv/zabbix-agent-osso.k8s-redis=true`.

2. Create an Ubuntu sidecar in all redis pods to be monitored.

3. Give this sidecar a serviceaccount to create configmaps.

    - You have to manually create the configmaps the first time;
    - the serviceaccount needs only patch permissions, and can be limited
      to only the monitored namespaces.

4. Mount the script (below) to the sidecar, and make it run in a loop.

    - The script expects a REDIS_INFO_PORT environment variable.

5. Load the template and enable the template for the hosts:

    - The hosts should have kubectl and access to the cluster and namespaces.

Script:

```sh
umask 0077
sed -e 's/^/Authorization: Bearer /' /var/run/secrets/kubernetes.io/serviceaccount/token >/tmp/auth
CA_CERT=/var/run/secrets/kubernetes.io/serviceaccount/ca.crt
while :; do
    STATUS=$(echo info | nc localhost ${REDIS_INFO_PORT} -w1 |
             tr -d '\r' | sed -ne '
                /^[^#]/s/^\([^:]*\):\(.*\)/"\1": "\2",/p
                1i{
                $a"zzz":"zzz"}
             ' | tr -d '\n' | sed -e 's/\\//g;s/"/\\"/g')
    PAYLOAD='[{"op":"replace","path":"/data/status","value":"'"${STATUS}"'"}]'
    curl --request PATCH --cacert ${CA_CERT} \
        --header @/tmp/auth --header "Content-Type: application/json-patch+json" \
        --data "${PAYLOAD}" \
        https://kubernetes.default.svc:443/api/v1/namespaces/${POD_NAMESPACE}/configmaps/status-${POD_NAME}
    sleep 30
done
```
