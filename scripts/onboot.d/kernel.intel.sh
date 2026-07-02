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

# Does this happen? Trigger if so.
intel_ice_mode=no_ddp
success=0
if grep -qE '^ice[: ].*(ice_init_hw failed|[Ff]irmware recovery mode)' \
        "$DMESG"; then
    intel_ice_mode=hw_fail  # figure this out later
else
    # Find all mentioned PCI addresses.
    pciaddrs=$(awk \
        '/^ice /{sub(":$","",$2);r[$2]=1} END{for(k in r){print k}}' \
        <"$DMESG")

    # For each address, check the latest of the messages.
    for pci in $pciaddrs; do
        intel_ice_mode=$(
            sed -e "/^ice $pci:/"'!d;s/^ice [^ ]* //' "$DMESG" |
            while read -r line; do
                case $line in
                *'The DDP package was successfully loaded'*)
                    echo ddp;;
                *'DDP package already present on device'*)
                    echo ddp;;
                *'Entering Safe Mode'*)
                    echo safe_mode;;
                *'ice_init_hw failed'*|*[Ff]'irmware recovery mode'*)
                    echo hw_fail; break;;  # break fast
                esac
            done | tail -n1
        )
        test -n "$intel_ice_mode" || intel_ice_mode=no_ddp

        # Shortcut the found result.
        case $intel_ice_mode in
            ddp) success=$((success+1));;
            no_ddp) test "$success" -eq 0 || intel_ice_mode=ddp;;
            hw_fail|safe_mode) break;;
        esac
    done
fi

# We want DDP when we have ICE (I think). So store the state and have zabbix
# trigger a disaster alert on it.
echo "$intel_ice_mode" >"$TARGET.new"
mv "$TARGET.new" "$TARGET"
