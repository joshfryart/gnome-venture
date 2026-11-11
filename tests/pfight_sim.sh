#!/bin/bash
# Puzzle combat engine: bot sims over every creature plus invariants (no DB, no server).
php "$(cd "$(dirname "$0")" && pwd)/pfight_sim.php" --quiet
