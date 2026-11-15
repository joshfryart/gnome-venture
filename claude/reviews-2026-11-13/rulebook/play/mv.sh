#!/bin/bash
# mv.sh STATE start I SIDE | place I X Y | flipplace I X Y | pass   -> the events, then the compact state
cd "$(dirname "$0")/../../../.."; D=claude/reviews-2026-11-13/rulebook/play; f=$1; shift
if [ "$1" = flipplace ]; then php tests/pf_play.php flip $f $2 >/dev/null; set -- place $2 $3 $4; fi
php tests/pf_play.php "$1" $f "${@:2}" 2>&1 | sed -n '/^WHAT HAPPENED\|^START\|^REFUSED/,/^$/p' | sed -e 's/ -> health [0-9.]* charm [0-9.]* hp [0-9]*//' -e 's/(a chain of 3 or more spends every piece that fired; they go to the discard)//' -e "s/(the creature's fire budget: a creature piece goes after it has fired twice)//" | cut -c1-330
php $D/st.php $f
