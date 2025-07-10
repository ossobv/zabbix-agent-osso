zabbix-agent-osso - Zabbix Agent scripts
========================================

Common zabbix ``UserParameters`` and the necessary support scripts.

This package attempts to address our common zabbix configuration needs.


Installation
------------

* Install this onto the machine. Fetch a pre-built debian package from
  somewhere or build one yourself::

    dpkg-buildpackage -us -uc -sa

* Fix the ``zabbix_agentd.conf`` to include ``zabbix_agentd.d/*.conf``
  (possibly without ``*.conf`` for older zabbix agents; and not
  the ``zabbix_agentd.conf.d`` old-style directory).

* Add this local config as ``local.conf``::

    Hostname=walter-dev.EXAMPLE.COM
    Server=zabbix.EXAMPLE.COM, zabbix-proxy1.EXAMPLE.COM, zabbix-proxy2.EXAMPLE.COM
    ServerActive=zabbix-proxy1.EXAMPLE.COM
    #DebugLevel=4

* On your Zabbix server you'll want to import the provided `Zabbix
  Templates`_.

.. _`Zabbix Templates`: https://github.com/ossobv/zabbix-agent-osso/tree/master/templates


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
| ``config/``           | The config directory holds locally configurable    |
|                       | settings for UserParameters or scripts.            |
|                       |                                                    |
|                       | Expected filenames:                                |
|                       | - acme.local (NOT in the package)                  |
|                       | - acme.readme                                      |
|                       | - acme.txt                                         |
+-----------------------+----------------------------------------------------+
| ``cron.d/``           | Cron jobs for slow tasks.                          |
+-----------------------+----------------------------------------------------+
| ``sudoers.d/``        | Sudoers files for zabbix scripts that require more |
|                       | permissions.                                       |
+-----------------------+----------------------------------------------------+
