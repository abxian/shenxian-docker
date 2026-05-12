#!/bin/sh
set -eu

exec /dashboard/app -c /dashboard/data/config.yaml
