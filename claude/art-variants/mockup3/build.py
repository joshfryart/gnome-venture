"""Builds mockup3/mock.html (the main-stop / town page) from the real copy below.
Copy sources (game/): town.php (todaybox, spot cards, Villagers view), includes/place_ui.php (main_stop_tabs, villager_row_html,
place_header_html), includes/town.php + data/towns.txt (places, actions, hours), includes/catalog.php (Spicepeak Pods and its staff),
includes/seed.php / flowers.php / sinks.php / yard.php (hub shops), world.php shop_cards(), includes/market100.php orders_board_box()/npc_order().
Usage: python3 claude/art-variants/mockup3/build.py"""
import os
from html import escape as e

HERE = os.path.dirname(os.path.abspath(__file__))
M2 = '../mockup2/art/'
ART = 'art/'
PH = '../../../game/assets/img/ph/'
SCENE = '../../../game/assets/img/scenes/stop-market.png'


def head(town, chips):
    ch = ''.join(f'<li class="dochip">{c}</li>' for c in chips)
    return f'''  <header class="dohead dohead--town">
    <div class="dohead__scene"><img class="pix" src="{SCENE}" width="480" height="270" alt="{e(town)} town square"></div>
    <div class="dohead__plate">
      <p class="dohead__kick">Main stop · Town square</p>
      <h2 class="dohead__name">{e(town)}</h2>
      <ul class="dohead__chips">{ch}</ul>
    </div>
  </header>
'''


def tabs(active, folk):
    T = [('square', '🏘️', 'Square', ''), ('villagers', '👥', 'Villagers', str(folk) if folk else ''), ('shops', '🏪', 'Shops', ''),
         ('orders', '📜', 'Orders', ''), ('stop', '🛂', 'Stop', '')]
    h = '  <nav class="mtabs" aria-label="Town sections">'
    for k, ic, lab, b in T:
        on = ' on" aria-current="page' if k == active else ''
        badge = f'<span class="mtabs__badge" aria-hidden="true">{b}</span><span class="vh">, {b} in town now</span>' if b else ''
        h += f'<a href="#" class="mtabs__a{on}"><span class="mtabs__ic" aria-hidden="true">{ic}</span><span class="mtabs__t">{lab}</span>{badge}</a>'
    return h + '</nav>\n'


def today(stats, more, trav):
    s = ''.join(f'<li class="tday__stat"><span class="tday__ic" aria-hidden="true">{ic}</span><b class="tday__n">{n}</b><span class="tday__l">{l}</span></li>' for ic, n, l in stats)
    m = ''.join(f'<li class="tday__chip">{x}</li>' for x in more)
    t = ''.join(f'<a href="#" class="tday__row"><span aria-hidden="true">🧭</span><span class="tday__rowt"><b>{e(n)}</b> is visiting</span><span class="tday__go" aria-hidden="true">›</span></a>' for n in trav)
    return f'''  <section class="tday" aria-label="Today at a glance">
    <ul class="tday__stats">{s}</ul>
    <ul class="tday__more">{m}</ul>{t}
  </section>
'''


def place(name, vig, status, kind='', flags=(), folk=''):
    """status: ('todo', '3 things to do') | ('look', 'Have a look') | ('done', ...) | ('closed', ...) | ('repair', ...)"""
    cls = ['gcard', 'pcard']
    if 'gold' in flags: cls.append('pcard--gold')
    st, txt = status
    if st in ('done', 'closed', 'repair'): cls.append('is-' + st)
    flag = '<span class="gcard__flag">New</span>' if 'new' in flags else ''
    folk_h = f'<span class="pfolk">{folk}</span>' if folk else ''
    gold = '<span class="vh">, found only here</span>' if 'gold' in flags else ''
    return f'''    <a href="#" class="{' '.join(cls)}">{flag}
      <span class="gcard__art"><img class="pix" src="{ART}vig-{vig}.png" width="144" height="108" alt=""></span>
      <span class="gcard__ribbon"><span class="gcard__label">{e(name)}</span>{gold}</span>
      <span class="gcard__meta"><span class="pchip pchip--{st}">{txt}</span>{folk_h}</span>
    </a>
'''


def vcard(slug, name, lines, act, badge=''):
    ls = ''.join(f'<span class="vcard__sub">{l}</span>' for l in lines)
    b = f'<span class="vcard__badge">{badge}</span>' if badge else ''
    return f'''    <li class="vcard">
      <a href="#" class="vcard__who"><span class="vcard__face"><img class="pix" src="{PH}npc-{slug}.png" width="80" height="100" alt=""></span><span class="vcard__ribbon"><span class="vcard__name">{e(name)}</span></span></a>
      <span class="vcard__main">{ls}{b}</span>
      <a href="#" class="fbtn vcard__act">{act}</a>
    </li>
'''


def scard(name, vig, desc, staff, closed=False):
    return f'''    <li><a href="#" class="scard{' is-closed' if closed else ''}">
      <span class="scard__art"><img class="pix" src="{ART}vig-{vig}.png" width="144" height="108" alt=""></span>
      <span class="scard__ribbon"><span class="scard__name">{e(name)}</span></span>
      <span class="scard__desc">{e(desc)}</span>
      <span class="scard__staff">{e(staff)}</span>
    </a></li>
'''


def ocard(slug, name, text, diff, bar, days, reward, have, can, done=False):
    stars = '★' * diff + '☆' * (3 - diff)
    tags = f'<span class="otag otag--stars" role="img" aria-label="Difficulty: {diff} of 3">{stars}</span>'
    if bar: tags += f'<span class="otag">{e(bar)}</span>'
    tags += f'<span class="otag{" otag--warn" if days <= 1 else ""}">⏳ {days} day{"" if days == 1 else "s"} left</span>'
    act = '<span class="ocard__done">✔️ Delivered</span>' if done else f'<button type="button" class="fbtn ocard__act"{"" if can else " disabled"}>Deliver</button>'
    return f'''    <li class="ocard{' is-done' if done else ''}">
      <a href="#" class="ocard__who"><span class="ocard__face"><img class="pix" src="{PH}npc-{slug}.png" width="80" height="100" alt=""></span><span class="vcard__ribbon"><span class="vcard__name">{e(name)}</span></span></a>
      <p class="ocard__q">“{e(text)}”</p>
      <p class="ocard__tags">{tags}</p>
      <p class="ocard__rw">Reward: {e(reward)}{(' · ' + e(have)) if have else ''}</p>
      <div class="ocard__foot">{act}</div>
    </li>
'''


SP_CHIPS = ['🌞 Day', '☁️ Cloudy', '🍂 Autumn 12']
SP_TODAY = today([('📋', 5, 'things left to do today'), ('🚪', 6, 'places open'), ('📌', 2, 'orders on the board')],
                 ['🧑‍🌾 2 gnomes about', '🧺 Market day in 2 days'], ['Lyra Fiddlewing'])
BDAY = '  <p class="tnote">🎂 Today is <a href="#" class="inl">Sage Dewberry</a>’s birthday! A gift today means three times as much.</p>\n'


def phone(screen, body, cap, sid):
    return f'''<figure class="mock" id="{sid}">
<div class="ph" data-screen="{screen}">
{body}</div>
<figcaption class="mock__cap">{cap}</figcaption>
</figure>

'''


square = head('Spicepeak', SP_CHIPS) + BDAY + SP_TODAY + tabs('square', 3) + '''  <h3 class="gx-h">🏘️ Places in Spicepeak <span class="gx-h__sub">tap one to go in</span></h3>
  <div class="gcards gcards--2">
''' + place('The Terrace Green', 'place-green', ('todo', '3 things to do'), folk='<span aria-hidden="true">🦗</span><span class="vh">Lyra Fiddlewing is here.</span> 🧑‍🌾 2 gnomes here') \
    + place('The Chai Stall', 'place-teahouse', ('todo', '1 thing to do')) \
    + place('The Notice Board', 'place-board', ('look', 'Have a look')) \
    + place('The Town Library', 'place-library', ('done', '✔️ all done today')) \
    + place('The Spice Grinders', 'place-grind', ('todo', '1 thing to do'), flags=('gold', 'new'), folk='<span aria-hidden="true">🦋</span><span class="vh">Sage Dewberry is here.</span>') \
    + place('The Cloud Monastery', 'place-monastery', ('repair', '🚧 closed for repairs'), flags=('gold',)) + '''  </div>
  <p class="gx-note">Most things can be done once or a few times a day; the day turns over at midnight Hollow time. ⭐ Gold-edged places are found only in Spicepeak.</p>
'''

mistmoor = head('Mistmoor', ['🌞 Day', '🌧️ Rain', '🍂 Autumn 12']) + today([('📋', 7, 'things left to do today'), ('🚪', 5, 'places open'), ('📌', 1, 'order on the board')], ['🧺 Market day in 2 days'], []) \
    + tabs('square', 1) + '''  <h3 class="gx-h">🏘️ Places in Mistmoor <span class="gx-h__sub">tap one to go in</span></h3>
  <div class="gcards gcards--2">
''' + place('The Village Green', 'place-green', ('todo', '3 things to do'), folk='🧑‍🌾 1 gnome here') \
    + place('The Drizzle & Crumpet', 'place-teahouse', ('todo', '1 thing to do')) \
    + place('The Notice Board', 'place-board', ('look', 'Have a look')) \
    + place('The Town Library', 'place-library', ('todo', '2 things to do')) \
    + place('The Standing Stones', 'place-stones', ('todo', '1 thing to do'), flags=('gold',)) \
    + place('The Crooked Kettle', 'place-pub', ('closed', '🔒 Open 6 pm to 11 pm (Hollow time).'), flags=('gold',)) + '''  </div>
  <p class="gx-note">States: idle, done (stone felt, tick), closed by the clock (stone felt, padlock, the hours in words), closed for repairs (striped barrier), new (flag), found only here (gold stitch, gold sign, star). All stay links: a shut place can still be read.</p>
'''

villagers = head('Spicepeak', SP_CHIPS) + BDAY + SP_TODAY + tabs('villagers', 3) + '''  <h3 class="gx-h">🚶 Out and about</h3>
  <ul class="vcards">
''' + vcard('lyra-fiddlewing', 'Lyra Fiddlewing', ['cheerful grasshopper · traveller', '📍 🌳 The Terrace Green · 💛 Stranger'], 'Chat') \
    + vcard('sage-dewberry', 'Sage Dewberry', ['grumpy butterfly', '📍 🌶️ The Spice Grinders · 💛 Acquaintance'], 'Chat', '🎂 birthday') + '''  </ul>
  <h3 class="gx-h">🏡 At home</h3>
  <ul class="vcards">
''' + vcard('tumble-seedwell', 'Tumble Seedwell', ['dreamy hedgehog', '🏡 Spicepeak Market · 💛 Friend'], '🚪 Knock') + '''  </ul>
  <p class="gx-note">Knock to visit someone at home: you can chat and give a gift there. Tap a name above to see what you know about them.</p>
  <p class="gx-note">📒 Only people in town right now are shown.</p>
  <div class="gx-actions"><a href="#" class="gbtn alt">Everyone you know →</a></div>
'''

shops = head('Spicepeak', SP_CHIPS) + tabs('shops', 3) + '''  <h3 class="gx-h">🏪 Shops in Spicepeak</h3>
  <ul class="scards">
''' + scard('Spicepeak Pods', 'shop-seeds', 'Seeds and flowers from across Spicepeak. Stock changes often, and rare finds turn up now and then.', 'At the counter: Reed Hollowell') + '''  </ul>
  <h3 class="gx-h">🍄 Mossbottom hub <span class="gx-h__sub">reachable from anywhere</span></h3>
  <ul class="scards">
''' + scard('Hedge & Hearth', 'shop-decor', 'Paths, fences, hedges, trees and ornaments for your yard. Place them with the yard designer on your garden page. Its locked Curio Cabinet holds rare pieces that change every Monday.', 'Closed — nobody on shift', True) \
    + scard('Petalpin’s Posies', 'shop-florist', 'The florist at Mossbottom Market: buckets of cut flowers, string, scissors and a counter that smells wonderful. Gnomes are always welcome to lend a hand for half an hour.', 'At the counter: Petalpin Greenfinger') \
    + scard('The Dewdrop Kitchen', 'shop-food', 'Warm meals, open all hours for hungry adventurers.', 'At the counter: Marigold Puddleby') \
    + scard('The Dye Pot', 'shop-dyes', 'Steaming vats of hat and beard dye in every colour of the Hollow. Buy a pot once and the colour is yours for good; pick it on My Gnome.', 'At the counter: Madder Quillfeather') \
    + scard("Twigg's Seed Emporium", 'shop-seeds', 'Everyday seeds, tools, compost and mulch. Reachable from anywhere in the world.', 'At the counter: Old Twigg') + '''  </ul>
'''

orders = head('Spicepeak', SP_CHIPS) + tabs('orders', 3) + '''  <h3 class="gx-h">📜 Orders from the townsfolk</h3>
  <p class="gx-note gx-note--top">Fill an order before its deadline. Harder orders (a higher quality bar) pay more. New orders every 7 days; next round Sun 1 Nov.</p>
  <ul class="ocards">
''' + ocard('sage-dewberry', 'Sage Dewberry', 'Could you bring me 4 × Turmeric, grade B+ (quality 60+)?', 2, 'grade B+ (quality 60+)', 3,
            '345 Petals, 16 XP, +10 friendship, 🎁 Worm Castings', 'you have 2 (grade C, 52) · Yours are grade C+ (quality 52+): not good enough.', False) \
    + ocard('reed-hollowell', 'Reed Hollowell', 'We are hungry: 3 × Lentil Dal, please.', 1, '', 1, '180 Petals, 8 XP, +5 friendship', 'you have 3', True) \
    + ocard('tumble-seedwell', 'Tumble Seedwell', 'I’m hosting! I need a feast (any feast dish).', 3, '', 5, '480 Petals, 24 XP, +15 friendship, 🎁 Cinnamon Seeds', '', False, True) + '''  </ul>
'''

page = '''<!doctype html>
<html lang="en" class="w390">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Town Square mockup</title>
<link rel="stylesheet" href="../mockup2/gather.css">
<link rel="stylesheet" href="town.css">
</head>
<body class="mockpage">
<main class="phones">

''' + phone('square', square, 'Square: felt place cards with a vignette per place kind, a ribbon that grows, a things-to-do chip', 's-square') \
    + phone('square2', mistmoor, 'Square, other states: Mistmoor at noon (the pub opens at 6 pm), long names', 's-square2') \
    + phone('villagers', villagers, 'Villagers: felt rows, name on the sign, one action each', 's-villagers') \
    + phone('shops', shops, 'Shops: a vignette per shop type, who is at the counter, closed state', 's-shops') \
    + phone('orders', orders, 'Orders: pinned felt notes with difficulty, quality bar, deadline and reward', 's-orders') + '''</main>
</body>
</html>
'''
open(os.path.join(HERE, 'mock.html'), 'w', encoding='utf8').write(page)
print('wrote mock.html', len(page), 'bytes')
