"""Mockup 4: writes mock.html (five phone screens built from ONE item-square component, .itm in items.css).
Data is real: names, slugs and rarities from game/includes/data (recipes.txt, gatherables.txt, crafts.txt, flowers.txt, hybrids.txt),
icons from game/assets/img/ph/{slug}.png (the item_icon() placeholder convention, 64 px); no picture = item_emoji() fallback.
The itm() helper is the PHP item_square() to come: same arguments, same markup.
Usage: python3 claude/art-variants/mockup4/build.py"""
import html, os

HERE = os.path.dirname(os.path.abspath(__file__))
PH = os.path.join(HERE, '..', '..', '..', 'game', 'assets', 'img', 'ph')
RW = {'c': 'Common', 'u': 'Uncommon', 'r': 'Rare', 'l': 'Legendary'}
e = html.escape


def icon(slug, emo, name):
    if slug and os.path.exists(os.path.join(PH, slug + '.png')):
        return f'<img class="itm__ic pix" src="../../../game/assets/img/ph/{slug}.png" width="64" height="64" alt="">'
    return f'<span class="itm__emo" aria-hidden="true">{emo or "🎁"}</span>'


def money(n):
    """money() for a chip: the number, the petal mark, the word for screen readers."""
    return f'{n:,}<i class="itm__pet" aria-hidden="true"></i><span class="vh"> Petals</span>'


KINDS = [(' Seed Packet', 'Seed packet'), (' Seeds', 'Seeds'), (' Seedling', 'Seedling'), (' Cutting', 'Cutting')]


def split_kind(name):
    """Lift the kind words off a name (catalog.php / flowers.php / tools.php build them on): 'Tomato Seeds' -> ('Tomato', 'Seeds')."""
    if name.startswith('Broken '):
        return name[7:], 'Broken'
    for suf, kind in KINDS:
        if name.endswith(suf):
            return name[:-len(suf)], kind
    return name, ''


def itm(name, slug=None, emo=None, rar='c', n=None, nlab='You have', foot=(), state='', flag=None, flagcls='', pressed=None, cell=None, sheet=True, extra_vh=''):
    """One item square. foot = [(chip class, html)], state = space-separated is-* classes, cell = 'details' (Satchel) or 'tile' (shop .btile)."""
    base, kind = split_kind(name)
    ln = len(base)
    cls = ['itm', 'itm--' + rar] + (['itm--xlong'] if ln > 19 else ['itm--long'] if ln > 13 else []) + state.split()
    if kind:
        foot = [('itm__kind', kind + f'<span class="vh"> ({e(name)})</span>')] + list(foot)
    chips = ''.join(f'<span class="{c}">{h}</span>' for c, h in foot)
    rw = f'<span class="itm__rar">{RW[rar]}</span>' if rar != 'c' else ''
    inner = (f'<span class="itm__win">{icon(slug, emo, name)}<i class="itm__gem" aria-hidden="true"></i>'
             + (f'<b class="itm__n"><span class="vh">{nlab} </span>×{n:,}</b>' if n is not None else '') + '</span>'
             + f'<span class="itm__rib"><span class="itm__name">{e(base)}</span></span>'
             + f'<span class="itm__foot">{rw}{chips}{"" if rar != "c" else "<span class=\"vh\">Common</span>"}{extra_vh}</span>'
             + (f'<span class="itm__flag {flagcls}">{flag}</span>' if flag else ''))
    if cell == 'details':
        return (f'<details class="itmcell"{" open" if pressed else ""}><summary class="{" ".join(cls)}">{inner}</summary>'
                f'<div class="ipop" hidden><b>{e(name)}</b></div></details>')
    ap = '' if pressed is None else f' aria-pressed="{"true" if pressed else "false"}"'
    btn = f'<button type="button" class="{" ".join(cls)}"{ap}{" aria-haspopup=\"dialog\"" if sheet else ""}>{inner}</button>'
    if cell == 'tile':
        return f'<div class="itmcell btile">{btn}<dialog class="isheet-d" aria-label="{e(name)}"></dialog></div>'
    return btn


def grid(items, cls=''):
    return f'<div class="itmwrap"><div class="itms {cls}">' + ''.join(items) + '</div></div>'


def phone(key, cap, body):
    return (f'<figure class="mock" id="s-{key}">\n<div class="ph" data-screen="{key}">\n{body}\n</div>\n'
            f'<figcaption class="mock__cap">{cap}</figcaption>\n</figure>\n')


TABS = ('<nav class="ptabs" aria-label="Satchel sections"><a href="#" class="{a}">🎒 <span class="ptabs__txt">Satchel</span></a>'
        '<a href="#" class="{b}">🧰 <span class="ptabs__txt">Toolbelt</span></a><a href="#" class="{c}">🍳 <span class="ptabs__txt">Crafting</span></a></nav>')

# ---------------------------------------------------------------- Satchel
sat = [
    ('🌱 Seeds', [
        itm('Tomato Seeds', 'tomato-seed', n=9999, cell='details'),
        itm('Night-flowering Jasmine Seeds', 'night-jasmine-seed', rar='u', n=24, flag='New', cell='details'),
        itm('Night-flowering Jasmine Seed Packet', 'night-jasmine-seed', rar='u', n=1, cell='details'),
        itm('Chocolate Cosmos Hybrid Seeds', 'chocolate-cosmos-seed', rar='l', n=2, cell='details'),
    ]),
    ('🍲 Food', [
        itm('Cloud Monastery Chili Crisp', None, '🌶️', rar='u', n=3, flag='Rare taste!', flagcls='itm__flag--taste', cell='details'),
        itm('Goat Cheese and Quail Egg Tart', 'goat-cheese-tart', rar='r', n=12, cell='details'),
        itm('Mistmoor Cloudberry Supper', 'feast-mistmoor-supper', rar='l', n=1, flag='New', cell='details'),
        itm('Ginger and Apple Cordial', 'ginger-apple-cordial', n=6, cell='details'),
        itm('Tomato', 'tomato', n=312, cell='details'),
        itm('Pumpkin', 'pumpkin', n=7, cell='details'),
    ]),
    ('🧰 Tools', [
        itm('Masterwork Stirrup Hoe', 'masterwork-stirrup-hoe', rar='r', n=1, state='is-use', foot=[('itm__use', 'In use')], cell='details'),
        itm('Stirrup Hoe', 'stirrup-hoe', n=1, foot=[('itm__note', 'Spare')], cell='details'),
        itm('Broken Masterwork Harvest Cart', 'broken-masterwork-harvest-cart', rar='r', n=1, state='is-off', foot=[('itm__note', 'Mend it')], cell='details'),
    ]),
    ('🍄 Finds', [
        itm('Morpho Scales', 'morpho-scales', rar='r', n=4, cell='details'),
        itm('Geode', 'geode', rar='r', n=1, pressed=True, cell='details'),
        itm('Seed Pearl', 'seed-pearl', rar='l', n=1, cell='details'),
        itm('Shed Butterfly Scales', 'butterfly-scales', rar='u', n=11, cell='details'),
        itm('Wild Strawberries', 'wild-strawberries', n=48, cell='details'),
    ]),
]
sat_body = ('<header class="ihead"><p class="ihead__kick">Your things</p><h2 class="ihead__name">🎒 Satchel</h2>'
            '<p class="ihead__line">Tap anything to see what it does. <span class="ihead__purse">2,480 Petals</span></p></header>'
            + TABS.format(a='on', b='', c='')
            + '<form class="ifilt" action="#"><label>Show <select><option>Everything (412)</option></select></label>'
              '<label>Sort <select><option>🗂️ By type</option></select></label></form>'
            + ''.join(f'<h3 class="gx-h">{h} <span class="gx-h__sub">{len(i)} kinds</span></h3>' + grid(i) for h, i in sat)
            + '<p class="legend">Felt tint, gem shape, letter and word all say the rarity. Gold sign and halo: its card is open. Buckle: in use. Stone felt: broken or locked.</p>')

# ---------------------------------------------------------------- Shop: Buy
buy = [
    itm('Tomato Seeds', 'tomato-seed', n=40, nlab='On the shelf', foot=[('itm__price', money(12))], cell='tile'),
    itm('Carrot Seeds', 'carrot-seed', n=36, nlab='On the shelf', foot=[('itm__price', '<span class="itm__trend" aria-hidden="true">↓</span>' + money(9) + '<span class="vh">, cheaper today</span>')], cell='tile'),
    itm('White Ginger Lily Seeds', 'white-ginger-lily-seed', rar='u', n=8, nlab='On the shelf', state='is-sel is-inbasket', foot=[('itm__price', money(90)), ('itm__inb', '2 in basket')], cell='tile'),
    itm('Night-flowering Jasmine Seeds', 'night-jasmine-seed', rar='r', n=3, nlab='On the shelf', flag='New', foot=[('itm__price', money(1400))], cell='tile'),
    itm('Chocolate Cosmos Hybrid Seeds', 'chocolate-cosmos-seed', rar='l', n=1, nlab='On the shelf', foot=[('itm__price', money(12500))], cell='tile'),
    itm('Lily-of-the-valley Seeds', 'lily-of-the-valley-seed', rar='u', n=12, nlab='On the shelf', foot=[('itm__price', '<span class="itm__trend" aria-hidden="true">↑</span>' + money(140) + '<span class="vh">, dearer today</span>')], cell='tile'),
    itm('Blue Poppy Seeds', 'blue-poppy-seed', rar='r', n=5, nlab='On the shelf', state='is-off', foot=[('itm__price', money(4600)), ('itm__short', 'Short 2,120<span class="vh"> Petals</span>')], cell='tile'),
    itm('Busy Lizzie Seeds', 'busy-lizzie-seed', n=0, nlab='On the shelf', state='is-off is-locked', foot=[('itm__note', 'Sold out · back tomorrow')], cell='tile'),
    itm('Pumpkin Seeds', 'pumpkin-seed', n=22, nlab='On the shelf', foot=[('itm__price', money(18))], cell='tile'),
]
basket_buy = ('<form class="basket ibasket" action="#" aria-label="Basket"><ul class="ibasket__list blist">'
              '<li class="ibasket__row"><span class="ibasket__what">2 × White Ginger Lily Seeds</span><span class="ibasket__sum">180</span></li>'
              '<li class="ibasket__row"><span class="ibasket__what">10 × Tomato Seeds</span><span class="ibasket__sum">120</span></li></ul>'
              '<div class="ibasket__foot bfoot"><b class="ibasket__total btotal">Total 300 Petals</b>'
              '<button type="button" class="fbtn fbtn--ghost bclear">Empty</button><button type="button" class="fbtn bgo">🧺 Buy all</button></div></form>')
shop_head = ('<header class="ihead"><p class="ihead__kick">Spicepeak · Shop</p><h2 class="ihead__name">The Seed Barrow</h2>'
             '<p class="ihead__line">{line} <span class="ihead__purse">2,480 Petals</span></p></header>')
chips = ('<nav class="ichips shopcats" aria-label="Show"><button type="button" class="ichip{a}">All <small>{n}</small></button>'
         '<button type="button" class="ichip">🌱 Seeds <small>{s}</small></button><button type="button" class="ichip">🌸 Flowers <small>3</small></button></nav>')
nav2 = ('<nav class="ptabs" aria-label="Shop sections"><a href="#" class="{a}">🛒 <span class="ptabs__txt">Buy</span></a>'
        '<a href="#" class="{b}">💰 <span class="ptabs__txt">Sell</span></a></nav>')
buy_body = (shop_head.format(line='Seeds from all over. Fill the basket, pay once.') + nav2.format(a='on', b='')
            + chips.format(a=' on', n=12, s=9) + grid(buy) + basket_buy)

# ---------------------------------------------------------------- Shop: Sell
sell = [
    itm('Morpho Scales', 'morpho-scales', rar='r', n=4, state='is-want is-sel is-inbasket', foot=[('itm__want', '★ Wanted'), ('itm__price', money(98)), ('itm__inb', '2 in basket')], cell='tile'),
    itm('Goat Cheese and Quail Egg Tart', 'goat-cheese-tart', rar='r', n=12, state='is-want', foot=[('itm__want', '★ Wanted'), ('itm__price', '<span class="itm__trend" aria-hidden="true">↑</span>' + money(1250) + '<span class="vh">, dearer today</span>')], cell='tile'),
    itm('Tomato', 'tomato', n=9999, foot=[('itm__price', '<span class="itm__trend" aria-hidden="true">↓</span>' + money(6) + '<span class="vh">, cheaper today</span>')], cell='tile'),
    itm('Shed Butterfly Scales', 'butterfly-scales', rar='u', n=11, foot=[('itm__price', money(24))], cell='tile'),
    itm('Seed Pearl', 'seed-pearl', rar='l', n=1, flag='New', foot=[('itm__price', money(12500))], cell='tile'),
    itm('Mistmoor Cloudberry Supper', 'feast-mistmoor-supper', rar='l', n=1, state='is-want', foot=[('itm__want', '★ Wanted'), ('itm__price', money(4800))], cell='tile'),
    itm('Masterwork Stirrup Hoe', 'masterwork-stirrup-hoe', rar='r', n=1, state='is-off is-use', foot=[('itm__use', 'In use'), ('itm__note', 'Can’t sell')], cell='tile'),
    itm('Chili Pepper', 'chili-pepper', n=58, foot=[('itm__price', money(7))], cell='tile'),
    itm('Geode', 'geode', rar='r', n=1, foot=[('itm__price', money(80))], cell='tile'),
]
basket_sell = ('<form class="basket ibasket" action="#" aria-label="Basket"><ul class="ibasket__list blist">'
               '<li class="ibasket__row"><span class="ibasket__what">2 × Morpho Scales ★</span><span class="ibasket__sum">196</span></li></ul>'
               '<div class="ibasket__foot bfoot"><b class="ibasket__total btotal">You get 196 Petals</b>'
               '<button type="button" class="fbtn fbtn--ghost bclear">Empty</button><button type="button" class="fbtn bgo">🧺 Sell all</button></div></form>')
sell_body = (shop_head.format(line='★ Wanted things sell for more today.') + nav2.format(a='', b='on')
             + chips.format(a=' on', n=9, s=0).replace('🌱 Seeds <small>0</small>', '🍲 Food <small>2</small>') + grid(sell) + basket_sell)

# ---------------------------------------------------------------- Crafting
def ing(name, slug, emo, have, need, rar='c'):
    ok = have >= need
    chip = ('itm__ok', f'✔ uses {need}') if ok else ('itm__short', f'✖ short {need - have}')
    return itm(name, slug, emo, rar=rar, n=have, foot=[chip], extra_vh=f'<span class="vh">{"enough" if ok else "not enough"}: you have {have}, the recipe needs {need}</span>')


craft_body = (
    '<header class="ihead"><p class="ihead__kick">Your things</p><h2 class="ihead__name">🍳 Crafting · Cooking</h2>'
    '<p class="ihead__line">Two pots free · ⚡ 34 energy</p></header>' + TABS.format(a='', b='', c='on')
    + '<nav class="ichips" aria-label="Show"><button type="button" class="ichip on">Ready <small>4</small></button><button type="button" class="ichip">Missing <small>9</small></button><button type="button" class="ichip">To discover <small>21</small></button></nav>'
    + '<h3 class="gx-h">Recipes</h3><div class="irecipes">'
    + '<section class="irec"><div class="irec__top"><span class="irec__win"><img class="itm__ic pix" src="../../../game/assets/img/ph/goat-cheese-tart.png" width="64" height="64" alt=""></span>'
      '<h4 class="irec__name">Goat Cheese and Quail Egg Tart <span class="irec__tag">🍲 meal</span></h4><p class="irec__sub">+2 hardiness, +2 lore for 4 hours</p></div>'
      '<p class="irec__h">Ingredients</p>'
    + grid([ing('Goat Cheese', 'goat-cheese', '🧀', 3, 1), ing('Quail Egg', 'quail-egg', '🥚', 14, 3), ing('Wheat', 'wheat', '🌾', 2, 2), ing('Onion', 'onion', '🧅', 9999, 1)], 'itms--flush')
    + '<div class="irec__go"><button type="button" class="fbtn">×1 ⚡4</button><button type="button" class="fbtn">×2</button><button type="button" class="fbtn fbtn--ghost">All 3</button>'
      '<span class="irec__meta">⚡4 each · ⏱ 20 min in a pot</span></div></section>'
    + '<section class="irec is-miss"><div class="irec__top"><span class="irec__win"><img class="itm__ic pix" src="../../../game/assets/img/ph/feast-mistmoor-supper.png" width="64" height="64" alt=""></span>'
      '<h4 class="irec__name">Mistmoor Cloudberry Supper <span class="irec__tag">🍳 feast</span></h4><p class="irec__sub">+4 hardiness, +3 luck for 8 hours</p></div>'
      '<p class="irec__h">Ingredients</p>'
    + grid([ing('Cloudberry', 'cloudberry', '🫐', 1, 2, 'u'), ing('Hazelnut', 'hazelnut', '🌰', 4, 1), ing('Leek', 'leek', '🥬', 2, 2),
            ing('Barley', 'barley', '🌾', 0, 3), ing('Potato', 'potato', '🥔', 27, 2), ing('Thyme', 'thyme', '🌿', 1, 1)], 'itms--flush')
    + '<p class="irec__need">Need 1 Cloudberry, 3 Barley</p></section></div>')

# ---------------------------------------------------------------- Gift picker
def gift(name, slug, emo, rar, n, taste, pressed=False):
    t = {'loved': '💛 Loved', 'liked': '👍 Liked', 'disliked': '👎 Disliked', '': ''}[taste]
    return itm(name, slug, emo, rar=rar, n=n, foot=[('itm__taste', t)] if t else [], pressed=pressed, sheet=False)


gift_body = (
    '<header class="ihead"><p class="ihead__kick">Villager · Spicepeak</p><h2 class="ihead__name">🦋 Sage Dewberry</h2>'
    '<p class="ihead__line">Good friends · 140 / 200 to Close friends</p></header>'
    + '<section class="isheet" aria-label="Choose a gift"><div class="isheet__head"><h3 class="isheet__t">🎁 Pick a gift for Sage</h3>'
      '<button type="button" class="isheet__x" aria-label="Close">✕</button></div>'
      '<p class="isheet__hint">It’s Sage’s birthday: a gift counts three times. Tastes you’ve found are marked.</p>'
    + grid([gift('Damask Rose', 'damask-rose', '🌹', 'u', 5, 'loved', True), gift('Goat Cheese and Quail Egg Tart', 'goat-cheese-tart', '', 'r', 12, 'liked'),
            gift('Cloud Monastery Chili Crisp', None, '🌶️', 'u', 3, ''), gift('Wild Strawberries', 'wild-strawberries', '', 'c', 48, 'liked'),
            gift('Worm Castings', 'worm-castings', '', 'c', 9999, 'disliked'), gift('Seed Pearl', 'seed-pearl', '', 'l', 1, ''),
            gift('Shed Butterfly Scales', 'butterfly-scales', '', 'u', 11, ''), gift('Tomato', 'tomato', '', 'c', 312, 'liked'), gift('Morpho Scales', 'morpho-scales', '', 'r', 4, '')])
    + '<div class="isheet__foot"><span class="isheet__sum">Damask Rose: Sage loves these.</span><button type="button" class="fbtn">🎁 Give</button></div></section>')

page = f'''<!doctype html>
<html lang="en" class="w390">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Item squares mockup</title>
<link rel="stylesheet" href="../mockup2/gather.css">
<link rel="stylesheet" href="items.css">
</head>
<body class="mockpage">
<main class="phones">
{phone('satchel', 'Satchel: one grid per type, counts to ×9,999, longest real names, every rarity, open, new, in use, broken.', sat_body)}
{phone('shop-buy', 'Shop Buy: price chips, stock counts, one tile in the basket, too dear, sold out, basket bar.', buy_body)}
{phone('shop-sell', 'Shop Sell: ★ wanted (badge and word), one in the basket, in use can’t be sold, “You get” basket.', sell_body)}
{phone('craft', 'Crafting: the ingredients as item squares with have / need (✔ or ✖ plus words).', craft_body)}
{phone('gift', 'Gift picker (folk.php): tastes found, one chosen (aria-pressed).', gift_body)}
</main>
</body>
</html>
'''
open(os.path.join(HERE, 'mock.html'), 'w').write(page)
print('mock.html written')
