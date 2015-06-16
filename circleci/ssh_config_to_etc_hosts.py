#!/usr/bin/env python

import os
import re

# There's a ssh config parser in paramiko library, but it fails to parse
# config on CircleCI nodes. Oh well.

re_hostname = re.compile(r'''Host\s+(node\d)\n\s+HostName\s+([\d\.]+)''')

with open(os.path.join(os.environ['HOME'], '.ssh', 'config')) as f:
    hosts = re_hostname.findall(f.read())

for alias, ip in hosts:
    print ip, alias