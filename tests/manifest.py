#!/usr/bin/env python3
"""Write a manifest (sha1 per game file) for a game folder: python3 manifest.py GAME_DIR OUT.txt
Skips data/, config.php and install.php (never shipped in updates)."""
import hashlib, os, sys
root, out = sys.argv[1], sys.argv[2]
lines = []
for d, _, fs in os.walk(root):
    for f in fs:
        p = os.path.join(d, f); rel = os.path.relpath(p, root).replace(os.sep, '/')
        if rel.startswith('data/') or rel in ('config.php', 'install.php'): continue
        lines.append(hashlib.sha1(open(p, 'rb').read()).hexdigest() + '  ' + rel)
open(out, 'w').write('\n'.join(sorted(lines, key=lambda l: l[42:])) + '\n')
print(len(lines), 'files ->', out)
