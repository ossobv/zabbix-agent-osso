<!-- [This file is part of the zabbix-agent-osso package] -->

# k8s-galera

The k8s galera monitoring script monitors galera clusters in kubernetes.
It works with both the mariadb-operator and unmanaged statefulsets.

This setup depends on a sidecar that queries galera cluster info from a mysql connection (localhost or socket).
The sidecar sends the data to a configmap, so ZAO can read it without exec'ing into any pods.

You can find the sidecar [here](https://git.osso.nl/pub/docker/osso-sidecar-scraper), Galera support was added in v0.23.

For more information about the mariadb kubernetes operator, visit the [project homepage](https://github.com/mariadb-operator/mariadb-operator).

## Mariadb-operator
For the mariadb-operator you can add a sidecar under the spec key:
```
  sidecarContainers:
    - name: zabbix-galera-monitor
      image: harbor.osso.io/ossobv/sidecar-scraper:latest
      imagePullPolicy: Always
      env:
        - name: STATUS_NAME
          value: "galera-cluster"
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: GALERA_CLUSTER
          value: "true"
        - name: MARIADB_HOST
          value: "127.0.0.1"
        - name: MARIADB_PORT
          value: "3306"
        - name: MARIADB_USER
          value: "root"
        - name: MARIADB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: mariadb-root
              key: password
```

## Unmanaged statefulset
Add another container with the ossobv sidecar-scraper image and the following config.
```
- name: sidecar-scraper
   image: harbor.osso.io/ossobv/sidecar-scraper:latest
   imagePullPolicy: Always
   env:
   - name: STATUS_NAME
      value: "galera-cluster"
   - name: POD_NAMESPACE
      valueFrom:
      fieldRef:
         fieldPath: metadata.namespace
   - name: POD_NAME
      valueFrom:
      fieldRef:
         fieldPath: metadata.name
   - name: GALERA_CLUSTER
      value: "true"
   volumeMounts:
   - mountPath: /run/mysqld
      name: mariadb-socket
```

## Permissions
Both options will need permissions to create and update configmaps where the data is written.

Role:
```
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: status-configmap-manager
rules:
- apiGroups: [""]
  resources: ["configmaps"]
  verbs: ["get", "list", "create", "update", "patch"]
```

Rolebinding:
```
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: galera-status-configmap-binding
subjects:
- kind: ServiceAccount
  name: galera
  namespace: mariadb-cluster
roleRef:
  kind: Role
  name: status-configmap-manager
  apiGroup: rbac.authorization.k8s.io
```

NOTE: The maria-db operator already has a service account named galera we can use.
A unmanaged statefulset will need a serviceaccount or a rolebinding to the default serviceaccount.

## Example configmap contents
```
apiVersion: v1
data:
  galera-0: '{"wsrep_cluster_size": 1, "wsrep_cluster_status": "Primary", "wsrep_local_state_comment":
    "Synced", "wsrep_connected": "ON", "wsrep_ready": "ON", "current_timestamp": 1787663912.567561}'
  galera-1: '{"wsrep_cluster_size": 2, "wsrep_cluster_status": "Primary", "wsrep_local_state_comment":
    "Synced", "wsrep_connected": "ON", "wsrep_ready": "ON", "current_timestamp": 1787663932.744917}'
  galera-2: '{"wsrep_cluster_size": 2, "wsrep_cluster_status": "Primary", "wsrep_local_state_comment":
    "Synced", "wsrep_connected": "ON", "wsrep_ready": "ON", "current_timestamp": 1787663898.220004}'
kind: ConfigMap
metadata:
  name: status-galera-cluster
  namespace: mariadb-cluster
```
Here we can se a split brain situation going on we want to alert on.

## Monitoring setup
Before setting up galera monitoring make sure your hosts have the following packages installed:

- `jq`
- `kubectl`

To setup galera monitoring perform the following steps:

1. Add the following label to any namespace containing a galera cluster:
   `ossobv/zabbix-agent-osso.k8s-galera=true`

2. Add the `Template k8s-galera.xml` template to your hosts in the zabbix interface.
