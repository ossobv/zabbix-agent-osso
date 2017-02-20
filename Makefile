.PHONY: check check-sudo install

check: check-sudo

check-sudo:
	# Checking sudo commands; are appropriate entries in the sudoers files?
	@grep sudo zabbix_agentd.d/*.conf | sed -e '/UserParameter/!d;s/.*UserParameter[^,]*, .*sudo //;s/ .*//' | sort -u | while read arg; do if ! grep -q "[ /]$$arg\$$" sudoers.d/*; then echo "$$arg: not in sudoers.d" >&2; exit 1; fi; done
	@echo yes

install:
	# zabbix_agentd.d
	install -d -o zabbix $(DESTDIR)/etc/zabbix/zabbix_agentd.d/
	install -o zabbix -m 0400 -t $(DESTDIR)/etc/zabbix/zabbix_agentd.d/ zabbix_agentd.d/*.conf 
	# scripts
	install -d -o root $(DESTDIR)/etc/zabbix/scripts/
	install -o root -m 0755 -t $(DESTDIR)/etc/zabbix/scripts/ scripts/*
	# sudoers.d
	install -d -o root $(DESTDIR)/etc/sudoers.d
	install -o root -m 0400 -t $(DESTDIR)/etc/sudoers.d/ sudoers.d/*
