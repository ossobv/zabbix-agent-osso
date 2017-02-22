zabbix-agent-osso - Zabbix Agent scripts
========================================

Common zabbix ``UserParameters`` and the necessary support scripts.

This package attempts to address our common zabbix configuration needs.


Installation
------------

* Install this onto the machine (FIXME: as a 'deb' obviously).

* Fix the ``zabbix_agentd.conf`` to include ``zabbix_agentd.d/*.conf``
  (possibly without ``*.conf`` for older zabbix agents; and not
  the ``zabbix_agentd.conf.d`` old-style directory).

* Add this local config as ``local.conf``::

    Hostname=walter-dev.EXAMPLE.COM
    Server=zabbix.EXAMPLE.COM, zabbix-proxy1.EXAMPLE.COM, zabbix-proxy2.EXAMPLE.COM
    ServerActive=
    #DebugLevel=4


Sources
-------

+-----------------------+----------------------------------------------------+
| path                  | description                                        |
+=======================+====================================================+
| ``zabbix_agentd.d/``  | The zabbix UserParameters as expected to be        |
|                       | included through ``zabbix_agentd.conf``.           |
+-----------------------+----------------------------------------------------+
| ``scripts/``          | The scripts directory mainly consists of scripts   |
|                       | that should be run periodically by the root user.  |
|                       |                                                    |
|                       | Most are not invoked by the zabbix                 |
|                       | UserParameter directly because they either         |
|                       | take too much time to run or because they          |
|                       | require more permissions.                          |
+-----------------------+----------------------------------------------------+
| ``cron.d/``           | Cron jobs for slow tasks.                          |
+-----------------------+----------------------------------------------------+
| ``sudoers.d/``        | Sudoers files for zabbix scripts that require more |
|                       | permissions.                                       |
+-----------------------+----------------------------------------------------+


TODO
----

* Add asterisk monitoring?
* Add MySQL monitoring?
* Add RANDOM-sleep to periodic cron jobs?
