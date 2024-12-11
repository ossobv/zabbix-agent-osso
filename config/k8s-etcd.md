<!-- [This file is part of the zabbix-agent-osso package] -->

# k8s-etcd

K8s-etcd monitors an in-cluster etcd setup.
The status of the etcd is written to a configmap with the following (example)
pod.

statefulset:

```yml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  labels:
    run: etcd-status-sender
    application: patroni
  name: etcd-status-sender
  namespace: production-postgres
spec:
  selector:
    matchLabels:
      run: etcd-status-sender
      application: patroni
  replicas: 1
  template:
    metadata:
      labels:
        run: etcd-status-sender
        application: patroni
    spec:
      serviceAccountName: etcd-status-sender
      containers:
        - image: harbor.osso.io/ossobv/etcdctl:3.5.15
          name: etcd-status-sender
          env:
            - name: ETCD_ENDPOINTS
              value: patroni-etcd-0.patroni-etcd:2379,patroni-etcd-1.patroni-etcd:2379,patroni-etcd-2.patroni-etcd:2379
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  apiVersion: v1
                  fieldPath: metadata.namespace
            - name: ETCD_CM_STATUS_NAME
              value: zao-etcd-status # customize if needed
          securityContext:
            allowPrivilegeEscalation: false
            capabilities:
              drop:
                - ALL
            privileged: false
            runAsNonRoot: true
            seccompProfile:
              type: RuntimeDefault
          volumeMounts:
            - mountPath: /tmp/scripts
              name: etcd-status-script
          command: ["/tmp/scripts/etcd-status.sh"]
      volumes:
        - name: etcd-status-script
          configMap:
            name: etcd-status-script
            defaultMode: 0775
      securityContext:
        fsGroup: 1000
        fsGroupChangePolicy: OnRootMismatch
        runAsGroup: 1000
        runAsNonRoot: true
        runAsUser: 1000
      dnsPolicy: ClusterFirst
      restartPolicy: Always
status: {}
```

script:

```yml
apiVersion: v1
data:
  etcd-status.sh: |
    #!/bin/sh
    CA_CERT="/var/run/secrets/kubernetes.io/serviceaccount/ca.crt";
    sed -e 's/^/Authorization: Bearer /' /var/run/secrets/kubernetes.io/serviceaccount/token >/tmp/auth

    while :
    do
      ETCD_STATUS="$(etcdctl endpoint status --endpoints=$ETCD_ENDPOINTS \
        --write-out=json)"
      echo "Etcd status: $ETCD_STATUS"
      ETCD_HEALTH="$(etcdctl endpoint health --endpoints=$ETCD_ENDPOINTS \
        --write-out=json)"
      echo "Etcd health: $ETCD_HEALTH"
      REQUEST_JSON=$(echo "{\"etcd_status\":${ETCD_STATUS},\"etcd_health\":${ETCD_HEALTH}}" | jq tostring)
      PAYLOAD="[{\"op\":\"replace\",\"path\":\"/data/status\",\"value\":${REQUEST_JSON}}]"

      curl --cacert ${CA_CERT} --header @/tmp/auth \
        --header "Content-Type: application/json-patch+json" --request PATCH \
        --data "${PAYLOAD}" \
        https://kubernetes.default.svc:443/api/v1/namespaces/${POD_NAMESPACE}/configmaps/$(ETCD_CM_STATUS_NAME)

      echo 'DONE'
      sleep 60
    done
kind: ConfigMap
metadata:
  name: etcd-status-script
  namespace: production-postgres
```

To enable the zabbix-agent-osso you need to label the namespace the configmap
is saved to.

```sh
kubectl label namespaces production-postgres ossobv/zabbix-agent-osso.k8s-etcd=true
kubectl label namespaces production-postgres ossobv/zabbix-agent-osso.k8s-etcd-status-name=zao-etcd-status

```

Now enable the template on the host and the new items and triggers in the
template will be found automatically.
The template has triggers for the health and the etcd database size, this
trigger can be tuned for database size.
