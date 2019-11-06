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

    if args[1] == 'wear_leveling':
        awk = "awk '{print $3}'"
    elif args[1] == 'end_to_end_error_detection_count':
        args[1] += ':'
        awk = "awk '{print $3}'"
    else:
        awk = "awk '{print $4}'"

    values = {
        'command': CMD,
        'device': args[0],
        'sub_cmd': args[1],
        'awk': awk
    }
    line = "%(command)s intel smart-log-add %(device)s | grep '^%(sub_cmd)s\ '" \
           " | %(awk)s" % values
    result = subprocess.check_output(
        line, shell=True, env={'PATH': os.environ['PATH']}).strip()
    print result.strip('%')
