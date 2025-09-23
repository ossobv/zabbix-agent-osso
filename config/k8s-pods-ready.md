<!-- [This file is part of the zabbix-agent-osso package] -->

# k8s-pods-ready

This script monitors the readiness of the containers in pods, configured by
annotations on a namespace.

You can monitor all pods or just a part of the pods in the namespace.

To monitor all pods in a namespace:
```
kubectl annotate ns target ossobv/zabbix-agent-osso.k8s-pods-ready='{}'
```

To monitor a subset based on the beginning of the pod name:
```
kubectl annotate ns target ossobv/zabbix-agent-osso.k8s-pods-ready='{"startswith":["deployment1","deployment2"]}'
```

You can set as many prefixes to match as wanted, they will show up as separate
triggers and items in zabbix. 

Note that when monitoring all pods we insert an 'ANY' into the zabbix
startswith field for compatibility. 