#!/usr/bin/env python
import os
import subprocess
import sys

CMD = '/usr/sbin/nvme'

if __name__ == '__main__':
    args = sys.argv[1:]
    if not len(args) == 2:
        print "2 arguments required: device and property"
        sys.exit(1)

    values = {
        'command': CMD,
        'device': args[0],
        'sub_cmd': args[1],
    }
    line = "%(command)s smart-log %(device)s | grep '^%(sub_cmd)s\  '" \
           "| awk -F: '{print $2}' | awk '{print $1}'" % values
    result = subprocess.check_output(
        line, shell=True, env={'PATH': os.environ['PATH']}).strip()
    print result.strip('%')
