#!/bin/bash
# 2.7.55 board sizes, field caps, Tremor / Spring, boss AOE (tests/pf_board_sizes.php). No DB, no server. The JS twin: tests/pfengine_js.sh.
php "$(cd "$(dirname "$0")" && pwd)/pf_board_sizes.php"
