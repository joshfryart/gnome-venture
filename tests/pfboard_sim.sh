#!/bin/bash
# Puzzle combat BOARD engine: rules, invariants and pace over every creature (no DB, no server).
php "$(cd "$(dirname "$0")" && pwd)/pfboard_sim.php" --quiet
