<!-- [This file is part of the zabbix-agent-osso package] -->

# k8s-pods-ready

this script monitors the readiness of the containers in pods, configured by labels on a namespace

to enable this for a namespace label the namespace with:
`ossobv/zabbix-agent-osso.k8s-pods-ready=true`

to setup for what pods the script should check the container statuses use the following label:
`ossobv/zabbix-agent-osso.k8s-pods-ready-startswith=natsomatch`

in this example it matches all pods with names that start with `natsomatch`
