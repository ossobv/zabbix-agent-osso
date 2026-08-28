#!/usr/bin/env python3
# [This file is part of the zabbix-agent-osso package]
import argparse
import json
import subprocess


class K8sZabbixBase:
    """
    Base class for Kubernetes Zabbix discovery and monitoring.
    """

    def __init__(
            self, name: str, description: str, label: str, cm_prefix: str):
        self.name = name
        self.description = description
        self.label = label
        self.cm_prefix = cm_prefix

    def is_valid_node(self, node_value: str) -> bool:
        """
        Override in subclasses to filter valid data inside ConfigMap data.
        """
        return True

    def get_cm_data(
            self, context: str, namespace: str, configmap: str) -> object:
        try:
            raw_output = subprocess.check_output(
                ['kubectl', '--context', context, '-n', namespace, 'get', 'cm',
                 configmap, '-ojson'], text=True, stderr=subprocess.DEVNULL)
        except subprocess.CalledProcessError:
            print('ZBX_NOTSUPPORTED')
            exit(1)
        return json.loads(raw_output)

    def get_nodes_in_configmap(
            self, context: str, namespace: str, configmap: str) -> list[str]:
        data = self.get_cm_data(context, namespace, configmap)
        cm_data = data.get('data', {})
        return [key for key, val in cm_data.items() if self.is_valid_node(val)]

    def build_zabbix_discovery_json(
            self, context: str, namespace: str, configmap: str,
            node: str) -> dict:
        return {
            "{#CONTEXT}": context,
            "{#NAMESPACE}": namespace,
            "{#CONFIGMAP}": configmap,
            "{#NODE}": node,
        }

    def get_contexts(self) -> list[str]:
        output = subprocess.check_output(
            ['kubectl', 'config', 'get-contexts', '-oname'], text=True)
        return output.splitlines()

    def get_namespaces(self, context: str) -> list[str]:
        try:
            output = subprocess.check_output(
                ['kubectl', '--context', context, 'get', 'namespaces', '-l',
                 self.label, '-oname'], text=True, stderr=subprocess.DEVNULL,
                timeout=5)
            return output.splitlines()
        except (subprocess.CalledProcessError, subprocess.TimeoutExpired):
            return []

    def get_configmaps(self, context: str, namespace: str) -> list[str]:
        configmaps = subprocess.check_output(
            ['kubectl', '--context', context, '-n', namespace, 'get',
             'configmap', '-oname'], text=True)
        cms = [cm.removeprefix('configmap/') for cm in configmaps.splitlines()]
        return [
            cm for cm in cms
            if cm == self.cm_prefix or cm.startswith(self.cm_prefix + '-')]

    def discover_instances(self):
        output = []
        for context in self.get_contexts():
            for namespace in self.get_namespaces(context):
                ns = namespace.removeprefix('namespace/')
                configmaps = self.get_configmaps(context, ns)
                for configmap in configmaps:
                    nodes = self.get_nodes_in_configmap(context, ns, configmap)
                    for node in nodes:
                        output.append(
                            self.build_zabbix_discovery_json(
                                context, ns, configmap, node)
                        )
        print(json.dumps(output))

    def get_data(self, context: str, namespace: str, cm: str, node: str):
        data = self.get_cm_data(context, namespace, cm)
        cm_data = data.get('data', {})
        if node not in cm_data:
            print('ZBX_NOTSUPPORTED')
            exit(1)

        print(cm_data[node])

    def run(self):
        parser = argparse.ArgumentParser(
            self.name, description=self.description)
        subparsers = parser.add_subparsers(dest="command", required=True)

        subparsers.add_parser(
            'discover-instances', help='Run Zabbix discovery')

        get_data_parser = subparsers.add_parser('get-data', help='Get data')
        get_data_parser.add_argument('--context', required=True)
        get_data_parser.add_argument('--namespace', required=True)
        get_data_parser.add_argument('--cm', required=True)
        get_data_parser.add_argument('--node', required=True)

        args = parser.parse_args()

        if args.command == 'discover-instances':
            self.discover_instances()
        elif args.command == 'get-data':
            self.get_data(args.context, args.namespace, args.cm, args.node)
