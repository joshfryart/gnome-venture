"""Security test pass: admin/mod area, acting on other players' things, bad numbers, injection, double spending.
usage: sec.py BASE DBPATH"""
import sys, re, sqlite3, threading, json, time
import requests

BASE, DB = sys.argv[1], sys.argv[2]
results = []
def db(sql, args=()):
    c = sqlite3.connect(DB); c.row_factory = sqlite3.Row
    try:
        cur = c.execute(sql, args); rows = cur.fetchall(); c.commit(); return rows
    finally: c.close()
def val(sql, args=()):
    r = db(sql, args); return r[0][0] if r else None
def check(name, ok, detail=''):
    results.append((ok, name, detail)); print(('PASS ' if ok else 'FAIL ') + name + (f'  [{detail}]' if detail else ''))

def login(user, pw):
    s = requests.Session()
    r = s.get(BASE + '/login.php'); tok = re.search(r'name="csrf" value="([^"]+)"', r.text).group(1)
    s.post(BASE + '/login.php', data={'csrf': tok, 'username': user, 'password': pw})
    return s
def tok(s, page='/index.php'):
    m = re.search(r'name="csrf" value="([^"]+)"', s.get(BASE + page).text); return m.group(1) if m else ''
def flash(html):
    m = re.findall(r'class="flash (ok|err)">([^<]*)', html); return m[0] if m else ('', '')
def post(s, page, data, getpage=None):
    t = tok(s, getpage or page.split('?')[0] if not page.startswith('/admin') else page)
    d = dict(data); d.setdefault('csrf', t)
    r = s.post(BASE + page, data=d, allow_redirects=True)
    return r

PW = 'TestPass123!'
anon = requests.Session()
sprout = login('sprout', PW); bloom = login('bloom', PW); mona = login('mona', PW); admin = login('admin', 'TestPassword123')
SID = val("SELECT id FROM users WHERE username='sprout'"); BID = val("SELECT id FROM users WHERE username='bloom'")
MID = val("SELECT id FROM users WHERE username='mona'"); AID = val("SELECT id FROM users WHERE username='admin'")

print('== 1. Admin area: who can get in')
admin_pages = ['index.php', 'crud.php?r=users', 'crud.php?r=items', 'settings.php', 'tools.php', 'update.php', 'grant.php', 'log.php', 'upload.php', 'preview.php']
for who, s in (('visitor', anon), ('player', bloom), ('moderator', mona)):
    leaks = []
    for p in admin_pages:
        r = s.get(BASE + '/admin/' + p, allow_redirects=False)
        if r.status_code == 200 and ('Admins only' not in r.text) and len(r.text) > 200: leaks.append(p)
    check(f'{who} cannot open any admin page', not leaks, ','.join(leaks))
r = admin.get(BASE + '/admin/index.php'); check('admin can open the admin panel', r.status_code == 200 and 'Admins only' not in r.text)

print('== 2. Admin actions sent by non-admins (with their own valid token)')
for who, s in (('player', bloom), ('moderator', mona)):
    t = tok(s)
    attempts = {
        'make self admin via users editor': ('/admin/crud.php?r=users&id=%d' % (BID if who == 'player' else MID), {'csrf': t, 'role': 'admin', 'username': 'x', 'email': 'x@x.x'}),
        'change site settings': ('/admin/settings.php', {'csrf': t, 'site_name': 'HACKED', 'registration_open': '1'}),
        'download a database dump': ('/admin/tools.php', {'csrf': t, 'do': 'dump'}),
        'grant themselves Petals': ('/admin/grant.php', {'csrf': t, 'user': 'bloom', 'coins': '999999', 'do': 'grant'}),
        'install an update': ('/admin/update.php', {'csrf': t, 'do': 'install', 'password': PW}),
        'clear the error log': ('/admin/tools.php', {'csrf': t, 'do': 'clear_errors'}),
    }
    for name, (url, data) in attempts.items():
        r = s.post(BASE + url, data=data, allow_redirects=False)
        bad = r.status_code == 200 and 'Admins only' not in r.text
        check(f'{who} cannot {name}', not bad and r.status_code in (302, 403), f'HTTP {r.status_code}')
check('site name unchanged', val("SELECT value FROM settings WHERE name='site_name'") != 'HACKED')
check('nobody got promoted', val("SELECT COUNT(*) FROM users WHERE role='admin'") == 1)

print('== 3. Moderator page')
r = bloom.get(BASE + '/modtools.php', allow_redirects=False); check('player cannot open moderation', r.status_code in (302, 403) or 'Moderation' not in r.text, f'HTTP {r.status_code}')
r = mona.get(BASE + '/modtools.php'); check('moderator can open moderation', r.status_code == 200 and 'Moderation' in r.text)
t = tok(bloom)
r = bloom.post(BASE + '/modtools.php', data={'csrf': t, 'do': 'timeban', 'report': 1, 'hours': 24}, allow_redirects=False)
check('player cannot use moderator actions', r.status_code in (302, 403))
# moderator vs admin: report the admin, then try to time-ban them
db("INSERT INTO reports (reporter_id, target_id, kind, ref_id, reason, created_at, status) VALUES (?,?,?,?,?,datetime('now'),'open')", (SID, AID, 'name', AID, 'rude'))
rep = val("SELECT id FROM reports WHERE target_id=? ORDER BY id DESC", (AID,))
if rep:
    for act in ('timeban', 'mute'):
        r = post(mona, '/modtools.php', {'do': act, 'report': rep, 'hours': 24})
        check(f'moderator cannot {act} an admin', not val("SELECT 1 FROM users WHERE id=? AND (banned_until > datetime('now') OR muted_until > datetime('now'))", (AID,)), flash(r.text)[1][:80])
cols = [r[1] for r in db("PRAGMA table_info(reports)")]

print('== 4. Raising your own rank from player pages')
r = post(bloom, '/account.php', {'do': 'privacy', 'garden_public': '1', 'role': 'admin', 'is_admin': '1', 'coins': '999999'})
check('extra fields on the account form are ignored', val("SELECT role FROM users WHERE id=?", (BID,)) == 'player' and val("SELECT coins FROM users WHERE id=?", (BID,)) < 999999)
s2 = requests.Session(); t2 = re.search(r'name="csrf" value="([^"]+)"', s2.get(BASE + '/register.php').text).group(1)
s2.post(BASE + '/register.php', data={'csrf': t2, 'username': 'sneaky', 'email': 'sn@x.local', 'password': PW, 'password2': PW, 'rules': 1, 'age': 1, 'role': 'admin'})
check('signing up with role=admin gives a normal player', (val("SELECT role FROM users WHERE username='sneaky'") or 'player') == 'player')

print('== 5. CSRF')
r = bloom.post(BASE + '/account.php', data={'do': 'privacy', 'garden_public': '0'}, allow_redirects=True)
check('a form without its token is refused', val("SELECT garden_public FROM users WHERE id=?", (BID,)) == 1)
r = bloom.post(BASE + '/account.php', data={'csrf': tok(sprout), 'do': 'privacy', 'garden_public': '0'})
check("another player's token doesn't work", val("SELECT garden_public FROM users WHERE id=?", (BID,)) == 1)
r = admin.post(BASE + '/admin/settings.php', data={'site_name': 'NoToken'}, allow_redirects=False)
check('admin settings without a token are refused', val("SELECT value FROM settings WHERE name='site_name'") != 'NoToken')

print('== 6. Acting on another player\'s things (bloom vs sprout)')
splot = val("SELECT id FROM plots WHERE user_id=?", (SID,))
r = post(bloom, '/garden.php', {'do': 'switch', 'plot_id': splot})
check("can't switch to someone else's garden", val("SELECT active_plot_id FROM users WHERE id=?", (BID,)) != splot)
r = post(bloom, '/garden.php', {'do': 'rename', 'plot_id': splot, 'name': 'Pwned', 'garden_name': 'Pwned'})
check("can't rename someone else's garden", val("SELECT garden_name FROM plots WHERE id=?", (splot,)) != 'Pwned')
yobj = db("SELECT id, x, y FROM garden_objects WHERE plot_id=? AND x>=0 LIMIT 1", (splot,))
r = post(bloom, '/yard.php', {'do': 'save', 'plot_id': splot, 'layout': json.dumps([])})
check("can't save a yard layout over someone else's", (not yobj) or val("SELECT x FROM garden_objects WHERE id=?", (yobj[0]['id'],)) == yobj[0]['x'])
# stall: sprout lists an item, bloom tries to unlist it
item = val("SELECT ui.item_id FROM user_items ui JOIN items i ON i.id=ui.item_id WHERE ui.user_id=? AND i.tradable=1 AND ui.qty>1 AND i.category<>'tool' LIMIT 1", (SID,))
db("UPDATE users SET level=5 WHERE id IN (?,?)", (SID, BID))
post(sprout, '/market.php?t=stall', {'do': 'list', 'item_id': item, 'qty': 1, 'price': 50}, '/market.php')
lid = val("SELECT id FROM stall_listings WHERE seller_id=? ORDER BY id DESC", (SID,)) if val("SELECT 1 FROM sqlite_master WHERE name='stall_listings'") else None
if lid:
    post(bloom, '/market.php?t=stall', {'do': 'unlist', 'id': lid}, '/market.php')
    check("can't take down someone else's stall listing", val("SELECT COUNT(*) FROM stall_listings WHERE id=?", (lid,)) == 1)
else:
    tbls = [r[0] for r in db("SELECT name FROM sqlite_master WHERE type='table' AND name LIKE '%stall%' OR name LIKE '%listing%'")]
    check('stall listing created for the test', False, 'tables: ' + ','.join(tbls))
# jobs: sprout posts a job, bloom tries to cancel it
post(sprout, '/jobs.php?t=post', {'do': 'post', 'kind': 'deliver', 'item_id': item, 'qty': 1, 'wage': 30, 'days': 1, 'note': 'hi'}, '/jobs.php')
pj = val("SELECT id FROM player_jobs WHERE poster_id=? ORDER BY id DESC", (SID,)) if val("SELECT 1 FROM sqlite_master WHERE name='player_jobs'") else None
if pj:
    post(bloom, '/jobs.php?t=post', {'do': 'cancel', 'id': pj}, '/jobs.php')
    check("can't cancel someone else's posted job", val("SELECT status FROM player_jobs WHERE id=?", (pj,)) != 'cancelled')
# trades: offer from sprout to admin; bloom tries to accept it
if val("SELECT 1 FROM sqlite_master WHERE name='trade_offers'"):
    db("INSERT INTO trade_offers (from_id, to_id, give_items, give_coins, want_items, want_coins, status, created_at) VALUES (?,?,?,?,?,?,'open',datetime('now'))", (SID, AID, '{}', 5, '{}', 0)) if 'created_at' in [r[1] for r in db("PRAGMA table_info(trade_offers)")] else db("INSERT INTO trade_offers (from_id, to_id, give_items, give_coins, want_items, want_coins, status) VALUES (?,?,?,?,?,?,'open')", (SID, AID, '{}', 5, '{}', 0))
    tid = val("SELECT id FROM trade_offers ORDER BY id DESC")
    if tid:
        post(bloom, '/market.php?t=trades', {'do': 'answer', 'id': tid, 'answer': 'accept'}, '/market.php')
        check("can't accept a trade meant for someone else", val("SELECT status FROM trade_offers WHERE id=?", (tid,)) not in ('accepted', 'done'))
# private garden
db("UPDATE users SET garden_public=0 WHERE id=?", (SID,))
r = bloom.get(BASE + '/visit.php?g=%d' % splot)
check("a private garden can't be visited", 'Fernhollow' not in r.text or 'private' in r.text.lower())
db("UPDATE users SET garden_public=1 WHERE id=?", (SID,))

print('== 7. Bad numbers (negative, zero, huge)')
c0 = val("SELECT coins FROM users WHERE id=?", (BID,))
stock = db("SELECT st.id, st.current_stock, st.shop_id FROM shop_stock st JOIN shops sh ON sh.id=st.shop_id JOIN locations l ON l.id=sh.location_id WHERE l.kind='hub' LIMIT 1")
if stock:
    for q in (-5, 0, 99999999):
        db("UPDATE shop_stock SET current_stock=5 WHERE id=?", (stock[0]['id'],))
        post(bloom, '/shop.php?id=%d' % stock[0]['shop_id'], {'do': 'buy', 'qty[%d]' % stock[0]['id']: q}, '/shop.php?id=%d' % stock[0]['shop_id'])   # v0.7.61 basket form
    c1 = val("SELECT coins FROM users WHERE id=?", (BID,))
    check('shop: negative/zero/huge quantities don\'t give Petals', c1 <= c0, f'{c0} -> {c1}')
sell_item = val("SELECT item_id FROM user_items WHERE user_id=? AND qty>0 LIMIT 1", (BID,))
q0 = val("SELECT qty FROM user_items WHERE user_id=? AND item_id=?", (BID, sell_item)); c0 = val("SELECT coins FROM users WHERE id=?", (BID,))
for q in (-3, 999999):
    post(bloom, '/shop.php?id=15&tab=sell', {'do': 'sell', 'qty[%d]' % sell_item: q}, '/shop.php?id=15&tab=sell')   # v0.7.61 basket form, at a hub shop
c1 = val("SELECT coins FROM users WHERE id=?", (BID,)); q1 = val("SELECT qty FROM user_items WHERE user_id=? AND item_id=?", (BID, sell_item)) or 0
check('shop: selling a negative or impossible amount does nothing odd', q1 >= 0 and (c1 - c0) <= 999999 and not (q1 > q0), f'qty {q0}->{q1}, coins {c0}->{c1}')
c0 = val("SELECT coins FROM users WHERE id=?", (BID,))
post(bloom, '/market.php?t=gifts', {'do': 'gift', 'to': val("SELECT gnome_name FROM users WHERE username='sprout'"), 'item_id': 0, 'qty': 0, 'coins': -500, 'note': 'x'}, '/market.php')
check('gifts: negative Petals can\'t pull money from someone', val("SELECT coins FROM users WHERE id=?", (BID,)) <= c0)
post(bloom, '/market.php?t=stall', {'do': 'list', 'item_id': sell_item, 'qty': -2, 'price': -10}, '/market.php')
check('stall: negative amounts/prices are refused', not val("SELECT 1 FROM stall_listings WHERE seller_id=? AND (qty<=0 OR price<=0)", (BID,)))
post(bloom, '/community.php', {'do': 'donate', 'item_id': sell_item, 'qty': -5})
check('community: negative donations refused', (val("SELECT qty FROM user_items WHERE user_id=? AND item_id=?", (BID, sell_item)) or 0) <= max(q1, 0))
c0 = val("SELECT coins FROM users WHERE id=?", (BID,))
post(bloom, '/race.php', {'snail': 0, 'bet': -1000, 'do': 'bet'})
check('snail race: negative bets refused', val("SELECT coins FROM users WHERE id=?", (BID,)) <= c0)
post(bloom, '/jobs.php?t=post', {'do': 'post', 'kind': 'deliver', 'item_id': sell_item, 'qty': 1, 'wage': -100, 'days': 1}, '/jobs.php')
check('jobs: negative wages refused', not val("SELECT 1 FROM player_jobs WHERE poster_id=? AND wage<0", (BID,)))

print('== 8. Injection attempts')
payloads = ["' OR 1=1 --", '"; DROP TABLE users; --', "1 UNION SELECT password_hash FROM users", "%' AND 1=0 UNION SELECT 1--"]
errs = 0
for p in payloads:
    for url in ('/market.php?q=' + requests.utils.quote(p), '/book.php?ch=' + requests.utils.quote(p), '/shop.php?id=' + requests.utils.quote(p), '/folk.php?id=' + requests.utils.quote(p), '/visit.php?g=' + requests.utils.quote(p), '/page.php?p=' + requests.utils.quote(p)):
        r = bloom.get(BASE + url)
        if r.status_code >= 500 or 'SQLSTATE' in r.text or '$2y$' in r.text: errs += 1
    r = admin.get(BASE + '/admin/crud.php?r=users&q=' + requests.utils.quote(p))
    if r.status_code >= 500 or 'SQLSTATE' in r.text or '$2y$' in r.text: errs += 1
check('SQL injection payloads cause no errors or leaks', errs == 0, f'{errs} bad responses')
check('users table still there', val("SELECT COUNT(*) FROM users") >= 4)
r = bloom.get(BASE + '/page.php?p=../config'); check('page.php path tricks show nothing', 'password' not in r.text.lower() or 'Password' in r.text and 'db' not in r.text)
r = bloom.get(BASE + '/book.php?ch=../../config.php'); check('book.php path tricks show nothing', 'pdo' not in r.text.lower())

print('== 9. Script injection (XSS)')
X = '<script>alert(1)</script><img src=x onerror=alert(2)>'
post(bloom, '/garden.php', {'do': 'rename', 'name': X, 'garden_name': X})
post(bloom, '/market.php?t=gifts', {'do': 'gift', 'to': val("SELECT gnome_name FROM users WHERE username='sprout'"), 'item_id': sell_item, 'qty': 1, 'coins': 0, 'note': X}, '/market.php')
post(bloom, '/jobs.php?t=post', {'do': 'post', 'kind': 'tend', 'days': 1, 'wage': 30, 'note': X}, '/jobs.php')
post(bloom, '/report.php?kind=name&id=%d' % SID, {'reason': 'other', 'details': X, 'note': X, 'kind': 'name', 'id': SID}, '/report.php?kind=name&id=%d' % SID)
pages_seen = []
for s, url in ((bloom, '/garden.php'), (sprout, '/index.php'), (sprout, '/market.php?t=gifts'), (sprout, '/jobs.php'), (mona, '/modtools.php'), (sprout, '/profile.php?u=%d' % BID), (sprout, '/visit.php?g=%d' % (val("SELECT id FROM plots WHERE user_id=?", (BID,)) or 0)), (admin, '/admin/crud.php?r=plots')):
    r = s.get(BASE + url)
    if '<script>alert(1)' in r.text or '<img src=x onerror' in r.text: pages_seen.append(url)
stored = {t + '.' + c: val(f"SELECT COUNT(*) FROM {t} WHERE {c} LIKE '%<script>%'") for t, c in (('plots', 'garden_name'), ('gifts', 'note'), ('player_jobs', 'note'), ('reports', 'details'))}
print('   attack text saved in:', stored)
check('typed-in HTML is shown as text everywhere', not pages_seen, ','.join(pages_seen))
r = bloom.get(BASE + '/garden.php'); csp = r.headers.get('Content-Security-Policy', '')
check('Content-Security-Policy blocks inline scripts', "script-src 'self'" in csp and 'unsafe-inline' not in csp)
check('pages refuse to be framed (clickjacking)', r.headers.get('X-Frame-Options') == 'DENY')
check('nosniff header set', r.headers.get('X-Content-Type-Options') == 'nosniff')
ck = [c for c in bloom.cookies if c.name == 'garden_sess']
raw = requests.get(BASE + '/login.php').headers.get('Set-Cookie', '')
check('session cookie is HttpOnly and SameSite', 'httponly' in raw.lower() and 'samesite=lax' in raw.lower(), raw[:120])

print('== 10. Double spending with two logins at once')
two = [login('bloom', PW) for _ in range(5)]
db("UPDATE users SET coins=100 WHERE id=?", (BID,))
exp = db("SELECT st.id, st.current_price FROM shop_stock st JOIN shops sh ON sh.id=st.shop_id JOIN locations l ON l.id=sh.location_id WHERE l.kind='hub' LIMIT 1")
if exp:
    toks = [tok(s, '/shop.php?id=1') for s in two]
    sid_ = val("SELECT shop_id FROM shop_stock WHERE id=?", (exp[0]['id'],))
    db("UPDATE shop_stock SET current_price=80, current_stock=10 WHERE id=?", (exp[0]['id'],))
    def buy(s, t): s.post(BASE + '/shop.php?id=%d' % sid_, data={'csrf': t, 'do': 'buy', 'qty[%d]' % exp[0]['id']: 1})   # v0.7.61 basket form
    ts = [threading.Thread(target=buy, args=(s, t)) for s, t in zip(two, toks)]; [t.start() for t in ts]; [t.join() for t in ts]
    check('5 buys at once with Petals for one: exactly one goes through', val("SELECT coins FROM users WHERE id=?", (BID,)) >= 0 and val("SELECT 10 - current_stock FROM shop_stock WHERE id=?", (exp[0]['id'],)) == 1,
          f'coins now {val("SELECT coins FROM users WHERE id=?", (BID,))}, sold {val("SELECT 10 - current_stock FROM shop_stock WHERE id=?", (exp[0]["id"],))}')
db("UPDATE users SET coins=1000 WHERE id=?", (BID,))
g = val("SELECT item_id FROM user_items WHERE user_id=? AND qty>0 LIMIT 1", (BID,)); db("UPDATE user_items SET qty=1 WHERE user_id=? AND item_id=?", (BID, g))
toks = [tok(s, '/market.php') for s in two]
def gift(s, t): s.post(BASE + '/market.php?t=gifts', data={'csrf': t, 'do': 'gift', 'to': val("SELECT gnome_name FROM users WHERE username='sprout'"), 'item_id': g, 'qty': 1, 'coins': 0, 'note': 'x'})
g_before = val("SELECT COUNT(*) FROM gifts WHERE from_id=? AND item_id=?", (BID, g))
ts = [threading.Thread(target=gift, args=(s, t)) for s, t in zip(two, toks)]; [t.start() for t in ts]; [t.join() for t in ts]
pend = val("SELECT COUNT(*) FROM gifts WHERE from_id=? AND item_id=?", (BID, g)) - g_before
check('gifting your last item 5 times at once sends exactly one', (pend or 0) == 1, f'gifts made: {pend}')

print('== 11. Password guessing')
s3 = requests.Session(); blocked_at = None
for i in range(15):
    t = re.search(r'name="csrf" value="([^"]+)"', s3.get(BASE + '/login.php').text).group(1)
    r = s3.post(BASE + '/login.php', data={'csrf': t, 'username': 'admin', 'password': 'guess%d' % i})
    if re.search(r'(?i)too many|slow down|try again in|wait', r.text): blocked_at = i + 1; break
check('login slows down repeated wrong passwords', blocked_at is not None and blocked_at <= 10, f'blocked after {blocked_at} tries')
s4 = requests.Session(); t = re.search(r'name="csrf" value="([^"]+)"', s4.get(BASE + '/login.php').text).group(1)
r = s4.post(BASE + '/login.php', data={'csrf': t, 'username': 'admin', 'password': 'TestPassword123'})
check('after the limit even the right password waits (no guessing through)', bool(re.search(r'(?i)too many|slow down|try again in|wait', r.text)) or blocked_at is None)
made = 0
for i in range(8):
    s5 = requests.Session(); t = re.search(r'name="csrf" value="([^"]+)"', s5.get(BASE + '/register.php').text).group(1)
    s5.post(BASE + '/register.php', data={'csrf': t, 'username': 'spam%d' % i, 'email': 'spam%d@x.local' % i, 'password': PW, 'password2': PW, 'rules': 1, 'age': 1})
    made += 1 if val("SELECT 1 FROM users WHERE username=?", ('spam%d' % i,)) else 0
check('sign-up spam from one address is limited', made < 8, f'{made} of 8 accounts made')

print('== 12. Sessions')
old = requests.Session(); old.cookies.update(bloom.cookies)
t = tok(bloom); bloom.post(BASE + '/logout.php', data={'csrf': t})
r = old.get(BASE + '/garden.php', allow_redirects=False)
check('logging out kills the session (a copied cookie stops working)', r.status_code == 302)
fix = requests.Session(); fix.cookies.set('garden_sess', 'attackerchosenid123456')
t = re.search(r'name="csrf" value="([^"]+)"', fix.get(BASE + '/login.php').text).group(1)
fix.post(BASE + '/login.php', data={'csrf': t, 'username': 'sprout', 'password': PW})
probe = requests.Session(); probe.cookies.set('garden_sess', 'attackerchosenid123456')
r = probe.get(BASE + '/garden.php', allow_redirects=False)
check('a session id chosen by an attacker is not logged in after the victim logs in', r.status_code == 302)

print('== 13. Deleting an account')
bloom = login('bloom', PW)
post(bloom, '/account.php', {'do': 'delete', 'current': PW, 'confirm': 'DELETE', 'user_id': SID, 'id': SID})
check("account deletion only ever affects yourself", val("SELECT COUNT(*) FROM users WHERE id=?", (SID,)) == 1)
ok = sum(1 for r in results if r[0]); print(f'\n== {ok}/{len(results)} passed')
for r in results:
    if not r[0]: print('FAILED:', r[1], r[2])
