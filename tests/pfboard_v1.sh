#!/bin/bash
# v1 board rules (admin setting pfight_v1; 2.6.75: environment pieces, section 13 in pfboard_v1_env.php; the 2.6.74 ground and events for fights under way): every rule, flag-off parity, flip, use-up, terrain, events, Teamwork, size by creature, whole fights. No DB, no server.
php "$(cd "$(dirname "$0")" && pwd)/pfboard_v1.php"
