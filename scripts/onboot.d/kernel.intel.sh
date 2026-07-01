#!/bin/sh
# [This file is part of the zabbix-agent-osso package]
# This is called by zabbix_onboot with the DMESG env where we'll find early
# boot logs and the CACHE env where we'll store the results.

# We want to know about the Intel E800 ice.pkg Dynamic Device Personalization
# (DDP) -- likely at /lib/firmware/intel/ice/ddp/ice.pkg.zst -- and whether it
# was loaded succesfully.
TARGET=$CACHE/kernel.intel.ice-mode

# "ice: Intel(R) Ethernet Connection E800 Series Linux Driver"
if ! grep -q '^ice:' "$DMESG"; then
    rm -f "$TARGET" 2>/dev/null
    exit 0
fi

if grep -q '^ice[: ].*The DDP package was successfully loaded' "$DMESG"; then
    intel_ice_mode=ddp  # good
else
    intel_ice_mode=no_ddp  # unknown
fi

# Find out whether DDP loading failed. All module logs pertaining to safe mode
# have "Entering Safe Mode".
if grep -q '^ice[: ].*Entering Safe Mode' "$DMESG"; then
    # This can be in conjunction "The DDP package was successfully loaded" but
    # also without.
    intel_ice_mode=safe_mode  # not good
fi
if grep -qE '^ice[: ].*(ice_init_hw failed|[Ff]irmware recovery mode)' \
        "$DMESG"; then
    intel_ice_mode=hw_fail    # even worse
fi

# We want DDP when we have ICE (I think). So store the state and have zabbix
# trigger a disaster alert on it.
echo "$intel_ice_mode" >"$TARGET.new"
mv "$TARGET.new" "$TARGET"
