#!/bin/sh
mkdir -p /var/log/ckpool/users /var/log/ckpool/pool
chmod 755 /var/log/ckpool /var/log/ckpool/users /var/log/ckpool/pool
exec /usr/local/bin/ckpool "$@"
