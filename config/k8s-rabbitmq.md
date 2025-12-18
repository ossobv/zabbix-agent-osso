<!-- [This file is part of the zabbix-agent-osso package] -->

# k8s-rabbitmq

The k8s RabbitMQ script allows monitoring of an RabbitMQ cluster managed by the RabbitMQ operator,
The status of each node in the cluster is written to a configmap by a sidecar container.

This status is then read using this script and transferred to Zabbix.

Our sidecar script can be found [here](https://git.osso.nl/pub/docker/osso-sidecar-scraper)

Setting up the sidecar using the kubernetes RabbitMQ operator can be done by adding the sidecar pod to the overwrite section of the RabbitmqCluster resource:

```
apiVersion: rabbitmq.com/v1beta1
kind: RabbitmqCluster
metadata:
  name: rabbitmq-cluster
  namespace: production-rabbitmq
spec:
  replicas: 3
  image: harbor.osso.io/docker-readonly/library/rabbitmq:3.12.2-management
  override:
    statefulSet:
      spec:
        template:
          spec:
            containers:
              - name: rabbitmq-monitoring
                image: harbor.osso.io/ossobv/sidecar-scraper:v0.10 # Use our version of the image here.
                env:
                  - name: RABBITMQ_USER
                    valueFrom:
                      secretKeyRef:
                        name: rabbitmq-cluster-default-user
                        key: username
                  - name: RABBITMQ_PASS
                    valueFrom:
                      secretKeyRef:
                        name: rabbitmq-cluster-default-user
                        key: password
                  - name: STATUS_NAME
                    value: rabbitmq-cluster-production
                  - name: POD_NAMESPACE
                    value: production-rabbitmq
```

It is important to pass the username and password to the sidecar for authenticating with the RabbitMQ API.

Please note that the `is-in-service` health endpoint used in the sidecar scraper is only available in RabbitMQ 4. The Zabbix item and trigger have not been added because we run version 3. This can easily be done by cloning one of the existing items and changing the json path to `$.in_service`.
