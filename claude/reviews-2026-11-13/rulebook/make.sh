#!/bin/bash
# Build the book: HTML, PDF, then the contents list's page numbers from the PDF, then both again.
cd "$(dirname "$0")"
python3 build.py && node render.js || exit 1
python3 - <<'PY'
import json, re, subprocess
heads = json.load(open('play/heads.json')); n = int(re.search(r'Pages:\s+(\d+)', subprocess.run(['pdfinfo', 'puzzle-combat-rulebook.pdf'], capture_output=True, text=True).stdout).group(1))
pages = {}
for pg in range(3, n + 1):
    txt = subprocess.run(['pdftotext', '-f', str(pg), '-l', str(pg), '-layout', 'puzzle-combat-rulebook.pdf', '-'], capture_output=True, text=True).stdout
    for hid, num, title in heads:
        if hid in pages: continue
        t = re.sub(r'<[^>]+>', '', title).replace('&amp;', '&')
        if re.search(r'^\s*' + re.escape(num) + r'\s+' + re.escape(t) + r'\s*$', txt, re.M): pages[hid] = pg
json.dump(pages, open('play/pages.json', 'w')); print(n, 'pages;', len(pages), 'of', len(heads), 'headings found; missing:', [h[1] for h in heads if h[0] not in pages])
PY
python3 build.py play/pages.json && node render.js && pdfinfo puzzle-combat-rulebook.pdf | grep Pages
