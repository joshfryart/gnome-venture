"""Pass 2 crawler: visit every reachable game page as a player, press every button once, record anything odd.
usage: crawl.py BASE USER PASS LABEL [max_posts]"""
import sys, re, json, time, collections
from urllib.parse import urljoin, urlparse
import requests
from bs4 import BeautifulSoup

BASE, USER, PW, LABEL = sys.argv[1:5]
MAXPOST = int(sys.argv[5]) if len(sys.argv) > 5 else 400
SKIP_PAGES = ('logout.php', 'install.php', '/admin/', 'reset.php', 'forgot.php', 'register.php', 'login.php')
SKIP_DO = {'delete_account', 'delete', 'password', 'email', 'logout', 'dismiss', 'abandon', 'cancel', 'restore', 'install', 'sell_all', 'clear'}

s = requests.Session()
r = s.get(BASE + '/login.php')
tok = re.search(r'name="csrf" value="([^"]+)"', r.text).group(1)
s.post(BASE + '/login.php', data={'csrf': tok, 'username': USER, 'password': PW})

findings = collections.defaultdict(list)
seen_pages, queue = set(), ['/index.php', '/garden.php']
posted = set()
nposts = 0

def norm(u):
    p = urlparse(u)
    if p.netloc and p.netloc != urlparse(BASE).netloc: return None
    if not p.path.endswith('.php'): return None
    if any(x in p.path for x in SKIP_PAGES): return None
    q = p.query
    # collapse ids so we don't crawl every shop/npc/item
    q = re.sub(r'(id|g|r|sel|item|u|user|plot|npc|lm)=\d+(-\d+)?', lambda m: m.group(1) + '=N', q)
    return p.path + ('?' + q if q else ''), p.path + ('?' + p.query if p.query else '')

def check(html, where, status, url):
    if status >= 400: findings['http'].append(f'{status} {where}')
    if 'Something went wrong' in html or 'Fatal error' in html or 'Warning:' in html or 'Notice:' in html or 'Deprecated:' in html:
        findings['php'].append(where)
    soup = BeautifulSoup(html, 'html.parser')
    for f in soup.select('.flash.err, .msglog.mlside .ml.err.new'):
        findings['err-msg'].append(f'{where}: {f.get_text(" ", strip=True)[:140]}')
    main = soup.find('main')
    if main is not None and len(main.get_text(strip=True)) < 40:
        findings['empty'].append(where)
    return soup

key_seen = set()
while queue:
    u = queue.pop(0)
    n = norm(urljoin(BASE, u))
    if not n: continue
    key, real = n
    if key in key_seen: continue
    key_seen.add(key)
    r = s.get(BASE + real, allow_redirects=True)
    where = real
    soup = check(r.text, 'GET ' + where, r.status_code, r.url)
    seen_pages.add(urlparse(r.url).path)
    for a in soup.select('a[href]'):
        h = a['href']
        if h.startswith('#') or h.startswith('mailto:'): continue
        nn = norm(urljoin(r.url, h))
        if nn and nn[0] not in key_seen: queue.append(nn[1])
    # press every button in main once (one per form "signature")
    main = soup.find('main') or soup
    for form in main.select('form'):
        if (form.get('method') or 'get').lower() != 'post': continue
        if form.get('enctype') == 'multipart/form-data': continue
        data = {}
        for inp in form.select('input[name]'):
            t = (inp.get('type') or 'text').lower()
            if t in ('checkbox', 'radio') and not inp.has_attr('checked'):
                if t == 'radio' and inp['name'] not in data: data[inp['name']] = inp.get('value', '')
                continue
            data[inp['name']] = inp.get('value', '')
            if t in ('text', 'number') and not data[inp['name']]: data[inp['name']] = inp.get('min') or ('1' if t == 'number' else 'Test')
        for sel in form.select('select[name]'):
            opts = [o for o in sel.select('option') if o.get('value', o.get_text()) != '' and not o.has_attr('disabled')]
            if opts: data[sel['name']] = opts[0].get('value', opts[0].get_text())
        for ta in form.select('textarea[name]'): data[ta['name']] = 'Hello there'
        btn = form.select_one('button[name], input[type=submit][name]')
        if btn and btn.get('name'): data[btn['name']] = btn.get('value', '')
        disabled = form.select_one('button[disabled]') is not None and not form.select_one('button:not([disabled])')
        if disabled: continue
        do = data.get('do', '') or data.get('act', '')
        if do in SKIP_DO or any(k in data for k in ('password', 'new_password')): continue
        action = urljoin(r.url, form.get('action') or r.url)
        nn = norm(action)
        if not nn: continue
        sig = (nn[0].split('?')[0], do, tuple(sorted(k for k in data if k not in ('csrf',))))
        if sig in posted: continue
        posted.add(sig)
        if nposts >= MAXPOST: continue
        nposts += 1
        rp = s.post(action, data=data, allow_redirects=True)
        wh = f'POST {nn[1]} do={do}'
        sp = check(rp.text, wh, rp.status_code, rp.url)
        ok = [f.get_text(' ', strip=True)[:100] for f in sp.select('.flash.ok, .msglog.mlside .ml.ok.new')]
        findings['posted'].append(f'{wh} -> {urlparse(rp.url).path} {"OK: " + ok[0] if ok else ""}')
        nn2 = norm(rp.url)
        if nn2 and nn2[0] not in key_seen: queue.append(nn2[1])

print(f'== {LABEL}: {len(key_seen)} page variants, {nposts} buttons pressed')
for k in ('http', 'php', 'empty', 'err-msg'):
    vals = findings[k]
    c = collections.Counter(vals)
    print(f'-- {k}: {len(vals)}')
    for v, n in c.most_common(60): print(f'   {n}× {v}')
json.dump(findings, open(f'crawl-{LABEL}.json', 'w'), indent=1)
