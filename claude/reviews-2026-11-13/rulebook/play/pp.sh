#!/bin/bash
# compact wrapper around tests/pf_play.php: drops the long constant help lines and shortens the edge words
cd /home/user/gnome-venture
php tests/pf_play.php "$@" 2>&1 | grep -v "^ENVIRONMENT PIECES link\|^Per cell\|^Multipliers\|^Your hand is redrawn\|^BOARD (x\|^BAR \|^YOUR HAND" \
 | sed -e 's/^ENVIRONMENT (a third player.*NEXT: /ENV NEXT: /' -e 's/hole-/h/g' -e 's/knob-/k/g' -e 's/ | from: [a-z]*, stays 3 rounds//' -e 's/ | stays \([0-9]\) round(s), this one included | from: [a-z]*/ stays \1/' -e 's/ | layer: [a-z]*//' -e 's/ Take the cell and it has to pick again (no penalty for it)\.//' -e 's/ c0 h-0//g' -e 's/(full = it backs off)//; s/(full = won over)//' -e 's/USED UP (a chain of 3 or more spends every piece that fired; they go to the discard)/USED UP/' | cut -c1-800
php claude/reviews-2026-11-13/rulebook/play/peek.php "$2"
