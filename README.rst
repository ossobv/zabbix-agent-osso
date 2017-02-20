osso-zabbix-config
==================

``zabbix_agentd.d``
-------------------

The zabbix UserParameters as expected to be included through
zabbix_agentd.conf.


``scripts/``
------------

The scripts directory mainly consists of scripts that should be run
periodically by the root user.

Most are not invoked by the zabbix UserParameter directly because they
either take too much time to run or because they require more
permissions.


``sudoers.d/``
--------------

Sudoers files for zabbix scripts that require more permissions.


TODO
----

* We need to fix the dependencies/suggestions/recomments.
* We need to add the cron entries to cron.d.
* We need to test these with the appropriate templates.
* We also need the Zabbix templates here.
