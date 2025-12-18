<!-- [This file is part of the zabbix-agent-osso package] -->

# Haproxy
Simple MinIO monitoring, configure your MinIO tenants in
`/etc/zabbix/config/minio`.

Having the MinIO cli debian package installed is required.
You can download it [here](https://dl.min.io/client/mc/release/linux-amd64/mc.deb)

The following statistics are monitored and have matching triggers:
- Online/offline drives
- Pool usage
- Decommissioning status

The following statistics are passed along but have no triggers (yet):
- Object count
- Healed disks per pool
- Decommissioning objects failed
- Decommissioning bytes failed

Discovery of the items and triggers is split between items/triggers on the
tenant level and those on the pool level. Sadly the pool name is not available
in all commands, so we use the index as an shared key. You will have to
match the index to the pool name during manual investigation.
