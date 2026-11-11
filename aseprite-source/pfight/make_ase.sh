#!/bin/sh
# usage: make_ase.sh <aseprite binary> <png dir> <out dir>
for f in "$2"/*.png; do "$1" -b "$f" --save-as "$3/$(basename "${f%.png}").aseprite" >/dev/null 2>&1; done
