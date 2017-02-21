.PHONY: check check-sudo check-header cleanup install

check: cleanup check-header check-sudo

check-header:
	# Checking that every file has a leading "zabbix-agent-osso" header.
	@! grep -L 'This file is part of the zabbix-agent-osso package' \
	  zabbix_agentd.d/* scripts/* sudoers.d/* | grep ''
	@echo yes

check-sudo:
	# Checking sudo commands; are appropriate entries in the sudoers files?
	@grep sudo zabbix_agentd.d/*.conf | sed -e \
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
	install -d -o zabbix $(DESTDIR)/etc/zabbix/zabbix_agentd.d/
	install -o zabbix -m 0400 -t $(DESTDIR)/etc/zabbix/zabbix_agentd.d/ \
	  zabbix_agentd.d/*.conf
	# scripts
	install -d -o root $(DESTDIR)/etc/zabbix/scripts/
	install -o root -m 0755 -t $(DESTDIR)/etc/zabbix/scripts/ scripts/*
	# sudoers.d
	install -d -o root $(DESTDIR)/etc/sudoers.d
	install -o root -m 0400 -t $(DESTDIR)/etc/sudoers.d/ sudoers.d/*
