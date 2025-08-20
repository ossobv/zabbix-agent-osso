zabbix-agent-osso - Zabbix Agent scripts
========================================

Common zabbix ``UserParameters`` and the necessary support scripts.

This package attempts to address our common zabbix configuration needs.

`Build/release`_ details how to build/release the internal package at OSSO.


------------
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


-------
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


-------------
Build/release
-------------

Merging + building + releasing a new version into the OSSO ppa:

* **All** new commits are pushed on the ``main`` branch.

* Update ``debian/changelog``. See previous versions and previous
  commits titled *"version: Bump to vXXXX"*.

* Run ``make`` in case you hadn't already. It does a few tests.

* Tag the version using ``git tag -sm vXXX vXXX`` and push it.

* Build the package using ``dpkg-buildpackage -sa`` (add ``-us -uc`` if
  you cannot sign). This creates a bunch of ``zabbix-agent-osso*`` files in
  ``..``.

* Copy the files to the PPA server. Add them to the appropriate
  repositories. Normally add it to *all* release versions (codenames) for
  the ``osso`` component::

    # aptly-repo-add-alldist osso /path/to/zabbix-agent-osso_XXX

  Additionally, add it to the ``osso-ops`` component with the
  ``anydist`` codename/suite::

    # aptly repo add osso-ops/anydist /path/to/zabbix-agent-osso_XXX

  Keep the repo signing key at hand, and then::

    # aptly-snapshot-publish-and-prune
