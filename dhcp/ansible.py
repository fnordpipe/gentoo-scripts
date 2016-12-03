#!/usr/bin/python2.7

# Copyright (c) 2016 crito <crito@fnordpipe.org>

import ConfigParser
import json
import redis
import sys
import time

class RedisCacheClient:
    redis = None

    def __init__(self):
        config = ConfigParser.ConfigParser()
        config.read('/etc/dhcp/ansible.ini')

        self.redis = redis.Redis(
            host = config.get('cache', 'host'),
            port = config.get('cache', 'port'),
            db = config.get('cache', 'db'),
            password = config.get('cache', 'password'))

    def run(self):
        if len(sys.argv) != 5 or sys.argv[3] == 'none':
            exit(1)

        hostname = '%s.%s' % (sys.argv[3], sys.argv[4])
        redisCacheKey = 'ansible_facts%s' % (hostname)
        redisCacheValue = {
            'ansible_default_ipv4': {
                'macaddress': sys.argv[1],
                'address': sys.argv[2]
            }
        }

        if not self.redis.exists(redisCacheKey):
            self.redis.set(redisCacheKey, json.dumps(redisCacheValue))
            self.redis.zadd('ansible_cache_keys', hostname, time.time())

if __name__ == '__main__':
    RedisCacheClient().run()
