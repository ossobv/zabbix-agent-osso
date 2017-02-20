osso-zabbix-config
==================

Common zabbix ``UserParameters`` that we generally need.


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
| ``sudoers.d/``        | Sudoers files for zabbix scripts that require more |
|                       | permissions.                                       |
+-----------------------+----------------------------------------------------+


TODO
----

* Create the debian-package :P

* We need to fix the dependencies/suggestions/recommends.

* We need to add the cron entries to cron.d.

* Add iptables and ip6tables monitoring to kernel.* or firewall.*.

Mostly done
~~~~~~~~~~~

* We also need the Zabbix templates here. (Most done.)

* We need to test these with the appropriate templates.
