<!-- [This file is part of the zabbix-agent-osso package] -->

# k8s-gpu

K8s GPU monitoring works by checking the allocatable and annotations of nodes using kubectl.
The script detects nodes with GPUs by fetching which nodes have nvidia.com/gpu available under status.allocatable.
VRAM/GPU usage is also gathered by using the hami.io/node-nvidia-register annotations.
These metrics are fetched as a single consolidated JSON payload and split into individual items within Zabbix using Dependent Items.

To use this script you need:

1. Kubernetes cluster where at least one node has an Nvidia GPU:

    - Hami-operator is installed on the cluster
    - Nvidia drivers and Containerd Nvidia runtime are configured on node
    - The node with GPU is labeled with gpu=on
    - Hami-operator device-plugin daemonset is running on the node

2. Load the template and enable the template for the hosts:

    - The hosts should have kubectl and have get/list RBAC to view nodes 
