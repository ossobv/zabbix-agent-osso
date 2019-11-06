!/usr/bin/env python
import json
import subprocess
CMD = '/usr/sbin/nvme'

if __name__ == '__main__':
    data = {}
    data['data'] = []
    line = "IFS=$'\n'; for x in `%s list | grep ^\/`;" \
           "do echo `echo $x | awk '{print $1}'`; done" % CMD
    devices = subprocess.check_output(line, shell=True).split()
    for i, device in enumerate(devices):
        data['data'].append({"{#NVME}": device})
    print json.dumps(data)
