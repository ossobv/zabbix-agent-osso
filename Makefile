.PHONY: check check-sudo check-header cleanup install

check: cleanup check-header check-sudo

check-header:
	# Checking that every file has a leading "zabbix-agent-osso" header.
	@! find zabbix_agent?.d/ scripts/ config/ cron.d/ sudoers.d/ \
	  -maxdepth 1 -type f | xargs \
	  grep -FL '[This file is part of the zabbix-agent-osso package]' | \
	  grep ''
	@echo yes

check-sudo:
	# Checking sudo commands; are appropriate entries in the sudoers files?
	@grep sudo zabbix_agent?.d/*.conf | sed -e \
	    '/UserParameter/!d;s/.*UserParameter[^,]*, .*sudo //;s/ .*//' | \
	  sort -u | \
	  while read arg; do \
	    if ! grep -q "[ /]$$arg\( \|\$$\)" sudoers.d/*; then \
	      echo "$$arg: not in sudoers.d" >&2; exit 1; fi; done
	@echo yes

cleanup:
	# Strip trailing whitespace
	find . -type f ! -path './.*' -print0 | \
	  xargs -0 --no-run-if-empty grep -l '[[:blank:]]$$' | \
	  xargs -d\\n --no-run-if-empty sed -i -e 's/[[:blank:]]\+$$//'

install:
	# zabbix_agentd.d
	install -d -o root $(DESTDIR)/etc/zabbix/zabbix_agentd.d/
	install -o root -m 0444 -t $(DESTDIR)/etc/zabbix/zabbix_agentd.d/ \
	  zabbix_agentd.d/*.conf
	# zabbix_agent2.d
	install -d -o root $(DESTDIR)/etc/zabbix/zabbix_agent2.d/
	install -o root -m 0444 -t $(DESTDIR)/etc/zabbix/zabbix_agent2.d/ \
	  zabbix_agent2.d/*.conf
	# scripts and config (for userparameters/scripts)
	install -d -o root $(DESTDIR)/etc/zabbix/scripts/
	install -d -o root $(DESTDIR)/etc/zabbix/config/
	tar -c --owner=root:0 --group=root:0 --exclude='.*' \
	  scripts/ config/ | tar -x -C $(DESTDIR)/etc/zabbix/
	# cron jobs
	install -d -o root $(DESTDIR)/etc/cron.d
	install -o root -m 0444 -t $(DESTDIR)/etc/cron.d/ cron.d/*
	# sudoers.d
	install -d -o root $(DESTDIR)/etc/sudoers.d
	install -o root -m 0400 -t $(DESTDIR)/etc/sudoers.d/ sudoers.d/*
