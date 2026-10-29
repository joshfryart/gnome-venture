#!/usr/bin/env bash
# Runs tools/catfish_recolor.py: 8 coats x 5 cat frames, overlays (patterns, ears/tail parts, eyes, masks),
# head-to-head coat distances per tone, and the --compose layered-cat helper.
set -e
export PYTHONDONTWRITEBYTECODE=1
cd "$(dirname "$0")/.."
OUT=$(mktemp -d); trap 'rm -rf "$OUT" "$OUT.log"; rm -rf tools/__pycache__' EXIT
python3 tools/catfish_recolor.py --check --out "$OUT" | tee "$OUT.log"
grep -q FAILED "$OUT.log" && exit 1
grep -q unmapped "$OUT.log" && { echo "FAIL: unmapped colours"; exit 1; }
IN=aseprite-source/catfish/test
N=$(ls "$OUT"/cf-cat-*-*.png | wc -l)
F=$(ls "$IN"/cf-cat-grey-*.png | wc -l)   # drawn frames grow as the art does
[ "$N" = $((8 * F)) ] || { echo "FAIL: expected $((8 * F)) cat outputs, got $N"; exit 1; }
for c in grey black white orange cream brown silver-blue ginger-red; do
  for f in idleA pounce catch nap stalk; do [ -f "$OUT/cf-cat-$c-$f.png" ] || { echo "FAIL missing $c $f"; exit 1; }; done
done
python3 -I - "$IN" "$OUT" <<'P'
import sys, numpy as np
from PIL import Image
i, o = sys.argv[1:]
for f in ('idleA','pounce','catch','nap','stalk'):
    a = np.array(Image.open(f'{i}/cf-cat-grey-{f}.png').convert('RGBA')); b = np.array(Image.open(f'{o}/cf-cat-grey-{f}.png').convert('RGBA'))
    assert (a == b).all(), 'grey != template ' + f
    ws = np.array(Image.open(f'{o}/cf-cat-white-{f}.png').convert('RGBA')); bk = np.array(Image.open(f'{o}/cf-cat-black-{f}.png').convert('RGBA'))
    assert (ws[...,3] == a[...,3]).all() and (bk[...,3] == a[...,3]).all(), 'alpha changed'
    for im in (ws, bk):
        assert len({tuple(p) for p in im.reshape(-1,4) if p[3]} - {tuple(p) for p in a.reshape(-1,4)}) >= 4, 'tones not swapped'
print('ok')
P
python3 -I - "$IN" "$OUT" <<'P'
import sys, glob, os, numpy as np
from PIL import Image
i, o = sys.argv[1:]
C = 'grey black white orange cream brown silver-blue ginger-red'.split()
def arr(p): return np.array(Image.open(p).convert('RGBA'))
n = 0
for f in sorted(glob.glob(f'{i}/cf-pat-*-grey-*.png')):
    for c in C:
        g = o + '/' + os.path.basename(f).replace('-grey-', f'-{c}-'); assert os.path.exists(g), g
        a, b = arr(f), arr(g); n += 1
        assert (a[..., 3] == b[..., 3]).all()
        if c == 'grey': assert (a == b).all()
assert n == 5 * len(glob.glob(f"{i}/cf-pat-tabby-grey-*.png")) * 8, n   # patterns x drawn key frames x coats
parts = sorted(glob.glob(f'{i}/cf-ears-folded-*.png') + glob.glob(f'{i}/cf-tail-bobtail-*.png'))
assert len(parts) >= 8
for f in parts:
    k = os.path.basename(f)[:-4].split('-')
    for c in C:
        g = o + '/' + '-'.join(k[:3] + [c, k[3]]) + '.png'; assert os.path.exists(g), g
        a, b = arr(f), arr(g); assert (a[..., 3] == b[..., 3]).all()
        if c == 'grey': assert (a == b).all()
        else: assert (a != b).any(), 'part not recoloured ' + g
# masks and final eye files are copied byte for byte (mask white is not art)
cp = glob.glob(f'{i}/cf-*-mask-*.png') + glob.glob(f'{i}/cf-eyes-[!r]*.png')
assert len(cp) >= 28   # grows as frames are drawn
for f in cp:
    assert open(f, 'rb').read() == open(o + '/' + os.path.basename(f), 'rb').read(), 'not copied unchanged ' + f
# roles: patch_white is fixed, coat_deep follows the coat ramp
# patch_white_* stay fixed; only patch_white_edge (#463e5e, derive coat_deep) follows the coat ramp
g, ob = arr(f'{i}/cf-pat-tuxedo-grey-idleA.png'), arr(f'{o}/cf-pat-tuxedo-orange-idleA.png')
edge = (g[..., :3] == [0x46, 0x3e, 0x5e]).all(-1) & (g[..., 3] > 0)
assert edge.any(), 'tuxedo has an edge row'
assert (g[~edge] == ob[~edge]).all(), 'white patch must be fixed'
assert (g[edge] != ob[edge]).any(), 'patch_white_edge must follow the coat'
assert (g == arr(f'{o}/cf-pat-tuxedo-grey-idleA.png')).all(), 'grey is the template'
assert (arr(f'{i}/cf-pat-tabby-grey-idleA.png') != arr(f'{o}/cf-pat-tabby-orange-idleA.png')).any()
print('overlays ok (%d pattern files, %d part files)' % (n, len(parts) * 8))
P
python3 -I - <<'P'
# coat head-to-head distance (CIE Lab, Euclidean) per tone; orange vs cream is the pair the art side flagged
import sys, itertools, numpy as np
sys.dont_write_bytecode = True
sys.path.insert(0, 'tools')
import catfish_recolor as R
def lab(hx):
    c = np.array(R.h2rgb(hx)) / 255; c = np.where(c > .04045, ((c + .055) / 1.055) ** 2.4, c / 12.92)
    x = np.array([[.4124,.3576,.1805],[.2126,.7152,.0722],[.0193,.1192,.9505]]) @ c / np.array([.9505, 1, 1.089])
    f = np.where(x > .008856, np.cbrt(x), 7.787 * x + 16 / 116)
    return np.array([116 * f[1] - 16, 500 * (f[0] - f[1]), 200 * (f[1] - f[2])])
MIN = {'shade': 12, 'base': 12, 'light': 12, 'gloss': 6}   # gloss tones converge toward white by design
for t, m in MIN.items():
    for a, b in itertools.combinations(R.COATS, 2):
        d = np.linalg.norm(lab(R.ramp(R.COATS[a])[t]) - lab(R.ramp(R.COATS[b])[t]))
        assert d > m, f'{a} vs {b} too close in {t}: {d:.1f} <= {m}'
        if {a, b} == {'orange', 'cream'}: assert d > 15, f'orange vs cream {t}: {d:.1f}'
print('coat distances ok')
P
# compositor: base coat, clear masks, parts, pattern, eyes
C=$(mktemp -d); trap 'rm -rf "$OUT" "$OUT.log" "$C"; rm -rf tools/__pycache__' EXIT
n=0
for combo in "orange tabby amber none none idleA" "cream tuxedo green folded bobtail pounce" "ginger-red calico blue folded none catch" \
             "white pointed hazel none bobtail nap" "black spotted amber,blue folded bobtail idleA" "grey none green folded bobtail nap" \
             "silver-blue calico hazel none bobtail pounce" "brown tabby blue folded none nap" "cream calico amber folded bobtail catch"; do
  set -- $combo
  args=(--compose --coat "$1" --pattern "$2" --eyes "$3" --frame "$6" --out "$C/c$n.png")
  [ "$4" = none ] || args+=(--ears "$4"); [ "$5" = none ] || args+=(--tail "$5")
  python3 tools/catfish_recolor.py "${args[@]}" >/dev/null || { echo "FAIL compose $combo"; exit 1; }
  n=$((n+1))
done
python3 -I - "$C" "$IN" <<'P'
import sys, glob, numpy as np
from PIL import Image
c, i = sys.argv[1:]
fs = sorted(glob.glob(c + '/c*.png')); assert len(fs) == 9
for f in fs:
    a = np.array(Image.open(f).convert('RGBA')); assert a.shape == (64, 64, 4)
    assert set(np.unique(a[..., 3])) <= {0, 255}, 'alpha ' + f
    op = a[a[..., 3] > 0][:, :3]
    assert len(np.unique(op, axis=0)) <= 28, '%s has %d colours' % (f, len(np.unique(op, axis=0)))
    assert not (op == 255).all(-1).any() and not (op == [255, 0, 255]).all(-1).any()
# plain compose of a coat frame without options equals the recoloured frame; a folded-ear cat differs from base only inside ears mask area + part
base = np.array(Image.open(f'{i}/cf-cat-grey-idleA.png').convert('RGBA'))
mask = np.array(Image.open(f'{i}/cf-ears-mask-idleA.png').convert('RGBA'))[..., 3] > 0
part = np.array(Image.open(f'{i}/cf-ears-folded-idleA.png').convert('RGBA'))[..., 3] > 0
import subprocess, os
out = c + '/plain.png'
subprocess.run([sys.executable, '-I', '-c', 'import sys;sys.dont_write_bytecode=True;sys.path.insert(0,"tools");import catfish_recolor as R;sys.exit(R.main(sys.argv[1:]))',
                '--compose', '--coat', 'grey', '--frame', 'idleA', '--ears', 'folded', '--out', out], check=True, stdout=subprocess.DEVNULL)
g = np.array(Image.open(out).convert('RGBA'))
diff = (g != base).any(-1)
assert not (diff & ~(mask | part)).any(), 'compose changed pixels outside mask/part'
assert (g[part] == np.array(Image.open(f'{i}/cf-ears-folded-idleA.png').convert('RGBA'))[part]).all()
print('compose ok (9 combos)')
P
rm -f "$OUT.log"; rm -rf tools/__pycache__; echo "catfish_recolor: ok"
