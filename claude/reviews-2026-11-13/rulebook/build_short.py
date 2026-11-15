#!/usr/bin/env python3
"""Builds the QUICK RULES: a short player rule book for Puzzle Combat (Gnome Venture 2.7.00), condensed from the full book (build.py).

Usage: python3 build_short.py          -> puzzle-combat-quick-rules.html, then the PDF (node render_short.js), two passes so the contents list gets page numbers
       python3 build_short.py --html   -> the HTML only (no page numbers)

It has its own compact look (CSS below) and reuses the full book's figure parts (figs.py). It writes no file of the full book."""
import os, re, sys, subprocess
import figs
from figs import piece, grid, note, svg, arrow, _shape, CHOP, DODGE, SUN, WILD, SWING, BRAMBLE, RAIN, THORN

HERE = os.path.dirname(os.path.abspath(__file__))
OUT_HTML = os.path.join(HERE, 'puzzle-combat-quick-rules.html')
OUT_PDF = os.path.join(HERE, 'puzzle-combat-quick-rules.pdf')

# ---------------------------------------------------------------- look
# Colours: green = the book's accent and the environment; tan = your pieces; rose = the creature's (as in the figures). One colour per piece type for the type chips.
CSS = r"""
@page { size: A4; margin: 12mm 13mm 14mm 13mm; }
* { box-sizing: border-box; }
html { font-size: 9pt; }
body { font-family: Inter, "DejaVu Sans", Arial, sans-serif; color: #1d1d1b; line-height: 1.3; margin: 0; }
b { font-weight: 700; }
h1, h2, h3, h4 { margin: 0; break-after: avoid; page-break-after: avoid; }
h2 { display: flex; align-items: center; gap: 7pt; font-family: "Bitstream Charter", Caladea, "DejaVu Serif", serif; font-size: 13.5pt; line-height: 1.15; color: #2b2a26;
     background: #e6ebd6; border-left: 4pt solid #6f8444; padding: 3pt 8pt 3pt 6pt; margin: 9pt 0 5pt; }
h2 .n { background: #56692f; color: #fff; border-radius: 3pt; min-width: 17pt; text-align: center; padding: 0.5pt 4pt; font-size: 11.5pt; }
h2 .s { margin-left: auto; font: 400 7.6pt Inter, "DejaVu Sans", Arial, sans-serif; color: #5a5a50; letter-spacing: 0.2pt; }
h2.pb { break-before: page; page-break-before: always; margin-top: 0; }
h3 { font-size: 8.4pt; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5pt; color: #56692f; margin: 6pt 0 2pt; }
h3:first-child, .two > div > h3:first-child { margin-top: 0; }
h4 { font-size: 8.8pt; font-weight: 700; color: #2b2a26; margin: 0 0 1.5pt; }
p { margin: 0 0 3.5pt; orphans: 3; widows: 3; }
ul, ol { margin: 0 0 4pt; padding-left: 11pt; }
ol { padding-left: 14pt; }
li { margin-bottom: 1.4pt; }
li::marker { color: #6f8444; font-weight: 700; }
table { border-collapse: collapse; width: 100%; margin: 2pt 0 5pt; font-size: 8.4pt; line-height: 1.25; }
thead { display: table-header-group; }
tr { break-inside: avoid; page-break-inside: avoid; }
th { background: #e6ebd6; text-align: left; font-weight: 700; font-size: 7.6pt; color: #3a4520; border-bottom: 0.8pt solid #6f8444; }
th.me { background: #f6e7bf; color: #5c4712; border-bottom-color: #8a6a1f; }
th.foe { background: #f3cdc8; color: #6e2823; border-bottom-color: #9b3b33; }
th.env { background: #d9ead0; color: #2f4f22; border-bottom-color: #4d7a3a; }
th, td { padding: 2pt 4pt; vertical-align: top; }
td { border-bottom: 0.4pt solid #cfccbe; }
td.num, th.num { text-align: center; white-space: nowrap; }
td:first-child { font-weight: 700; }
table.plain td:first-child { font-weight: 400; }
table.keep { break-inside: avoid; page-break-inside: avoid; }
table.nw1 td:first-child, table.nwall td { white-space: nowrap; }
.nw { white-space: nowrap; }
.fig { break-inside: avoid; page-break-inside: avoid; margin: 2pt 0 4pt; text-align: center; }
.fig svg { max-width: 100%; height: auto; display: block; margin: 0 auto; }
.fig .cap { font-size: 7.4pt; color: #5a5a50; margin-top: 1pt; }
.box { break-inside: avoid; page-break-inside: avoid; border: 0.7pt solid #6f8444; border-left-width: 3pt; background: #f4f6ea; border-radius: 3pt; padding: 4pt 7pt 1.5pt; margin: 3pt 0 5pt; }
.box.warn { border-color: #b5651d; background: #fbf1e3; }
.box.tip { border-color: #6c7fa3; background: #eef2f9; }
.box ul, .box ol { margin-bottom: 2.5pt; }
.two { display: flex; gap: 5mm; align-items: flex-start; margin-bottom: 1pt; break-inside: avoid; page-break-inside: avoid; }
.two.brk { break-inside: auto; page-break-inside: auto; }
.two > div { flex: 1; min-width: 0; }
.two > div > *:last-child { margin-bottom: 3pt; }
.mc { columns: 2; column-gap: 5mm; }
.mc li, .mc p { break-inside: avoid; }
.small { font-size: 7.6pt; color: #4a4a42; }
/* piece type chips */
.ty { display: inline-block; font-size: 7.3pt; font-weight: 700; line-height: 1.25; border-radius: 2.5pt; padding: 0 3.5pt; border: 0.6pt solid; white-space: nowrap; }
.ty.hurt { color: #a2332a; background: #fbe6e2; }
.ty.guard { color: #2f5f96; background: #e3edf8; }
.ty.heal { color: #3d7a2b; background: #e4f1dc; }
.ty.charm { color: #933f80; background: #f6e3f1; }
.ty.soothe { color: #1f7d78; background: #dcf1ef; }
.ty.trick { color: #8f6208; background: #fbefc9; }
.ty.item { color: #6d4f33; background: #efe5da; }
.ty.env { color: #2f4f22; background: #d9ead0; }
.new { font-size: 6.6pt; font-weight: 700; background: #34406b; color: #fff; border-radius: 2.5pt; padding: 0.3pt 3pt; vertical-align: 1pt; letter-spacing: 0.2pt; white-space: nowrap; font-family: Inter, "DejaVu Sans", Arial, sans-serif; text-transform: none; }
.sw { display: inline-block; width: 7pt; height: 7pt; border-radius: 1.5pt; border: 0.7pt solid; vertical-align: -0.6pt; margin-right: 2pt; }
.sw.me { background: #f6e7bf; border-color: #8a6a1f; } .sw.foe { background: #f3cdc8; border-color: #9b3b33; } .sw.env { background: #d9ead0; border-color: #4d7a3a; } .sw.none { background: #eee; border-color: #888; border-style: dashed; }
/* title and contents */
.title { display: flex; align-items: flex-end; gap: 8pt; border-bottom: 2.5pt solid #6f8444; padding-bottom: 4pt; margin-bottom: 6pt; }
.title h1 { font-family: "Bitstream Charter", Caladea, "DejaVu Serif", serif; font-size: 25pt; line-height: 1; color: #2b2a26; }
.title .sub { font-size: 11pt; color: #56692f; font-weight: 700; padding-bottom: 1.5pt; }
.title .meta { margin-left: auto; text-align: right; font-size: 7.6pt; color: #5a5a50; line-height: 1.35; }
.toc { margin-bottom: 5pt; }
.toc h4 { text-transform: uppercase; letter-spacing: 0.5pt; font-size: 8.4pt; color: #56692f; margin-bottom: 2pt; }
.toc .cols { font-size: 8.3pt; }
.toc .e { display: flex; align-items: baseline; padding: 1.25pt 0; break-inside: avoid; }
.toc .e a { color: inherit; text-decoration: none; display: contents; }
.toc .tn { color: #56692f; font-weight: 700; width: 13pt; flex: none; }
.toc .dots { flex: 1; border-bottom: 0.6pt dotted #999; margin: 0 4pt; transform: translateY(-2.5pt); min-width: 6pt; }
.toc .pg { font-weight: 700; }
/* strips */
.rank { display: flex; gap: 3pt; align-items: stretch; margin: 2pt 0 5pt; break-inside: avoid; }
.rank > div { flex: 1; border: 0.7pt solid #b9b6a8; border-radius: 3pt; padding: 2pt 4pt; background: #faf9f4; font-size: 8pt; position: relative; }
.rank > div b.o { display: block; font-size: 6.8pt; color: #56692f; text-transform: uppercase; letter-spacing: 0.4pt; }
.rank > div + div::before { content: "›"; position: absolute; left: -4.6pt; top: 28%; font-weight: 700; color: #56692f; background: #fff; line-height: 1; font-size: 9pt; }
.rank > div.me { background: #fbf3dc; border-color: #c9ae6c; } .rank > div.foe { background: #f9e4e1; border-color: #cf928b; } .rank > div.env { background: #e9f3e3; border-color: #94b784; } .rank > div.cl { background: #efefef; }
/* cheat sheet */
.cheat { font-size: 8.8pt; line-height: 1.3; }
.cheat .rank > div { font-size: 8.4pt; }
.cheat .cols { columns: 3; column-gap: 5mm; column-rule: 0.5pt solid #cfccbe; }
.cheat .blk { break-inside: avoid; margin-bottom: 6pt; }
.cheat h4 { font-size: 9pt; color: #fff; background: #56692f; border-radius: 2.5pt; padding: 1pt 5pt; margin-bottom: 2pt; }
.cheat ul, .cheat ol { margin: 0; padding-left: 10pt; }
.cheat li { margin-bottom: 1.2pt; }
"""

# ---------------------------------------------------------------- headings and helpers
heads = []   # (id, number, title, subtitle)


def ch(num, title, sub='', pb=False):
    hid = 'c' + num
    heads.append((hid, num, title, sub))
    cls = ' class="pb"' if pb else ''
    return f'<h2 id="{hid}"{cls}><span class="n">{num}</span><span class="tt">{title}</span><span class="s">{sub}</span></h2>'


def h3(title):
    return f'<h3>{title}</h3>'


def fig(s, cap='', cls=''):
    c = f'<div class="cap">{cap}</div>' if cap else ''
    return f'<div class="fig {cls}">{s}{c}</div>'


def box(title, body, kind=''):
    h = f'<h4>{title}</h4>' if title else ''
    return f'<div class="box {kind}">{h}{body}</div>'


def table(head, rows, cls='keep', num=(), widths=None):
    """head items: text, or (text, th class). rows: lists of cell html."""
    th = ''.join(f'<th class="{h[1]}">{h[0]}</th>' if isinstance(h, tuple) else (f'<th class="num">{h}</th>' if i in num else f'<th>{h}</th>') for i, h in enumerate(head))
    tr = ''.join('<tr>' + ''.join(f'<td{" class=num" if i in num else ""}>{c}</td>' for i, c in enumerate(r)) + '</tr>' for r in rows)
    cg = ('<colgroup>' + ''.join(f'<col style="width:{x}">' if x else '<col>' for x in widths) + '</colgroup>') if widths else ''
    return f'<table class="{cls}">{cg}<thead><tr>{th}</tr></thead><tbody>{tr}</tbody></table>'


def ul(*items):
    return '<ul>' + ''.join(f'<li>{i}</li>' for i in items) + '</ul>'


def ol(*items):
    return '<ol>' + ''.join(f'<li>{i}</li>' for i in items) + '</ol>'


def two(a, b, fa=1, fb=1, brk=False):
    return f'<div class="two{" brk" if brk else ""}"><div style="flex:{fa}">{a}</div><div style="flex:{fb}">{b}</div></div>'


def mc(html):
    return f'<div class="mc">{html}</div>'


def T(*names):
    """Type chips: T('Hurt'), T('Guard', 'Soothe')."""
    return ' '.join(f'<span class="ty {n.lower()}">{n}</span>' for n in names)


NEW = '<span class="new">new in 2.7.00</span>'
ME, FOE, ENV = '<span class="sw me"></span>', '<span class="sw foe"></span>', '<span class="sw env"></span>'


# ---------------------------------------------------------------- figures (boards only: the words stand beside them in the page)
def fig_round():
    return ('<div class="rank">'
            '<div class="me"><b class="o">1 · You</b>Place <b>one</b> piece or pass. Flip is free. Then <b>End turn</b>.</div>'
            '<div class="foe"><b class="o">2 · The creature</b>Plays its aim (or picks again). Its chain fires. Class extras.</div>'
            '<div class="env"><b class="o">3 · The environment</b>Places 1 piece on an empty, lonely cell. Nothing fires.</div>'
            '<div class="cl"><b class="o">4 · Clean-up</b>Poison, Simmer, old pieces leave, new hand of 5, new aim.</div></div>')


def fig_pieces():
    """Swing with its four edges named, the three edge families, a fit and a misfit."""
    b = ''
    S = 100
    px, py = 60, 24
    b += piece(px, py, S, 'Swing', 'Hurt 5', SWING)
    b += note(px + S / 2, 18, 'top: knob (body)', 10, 'middle') + note(px + S / 2, py + S + 10, 'bottom: hole (body)', 10, 'middle')
    b += note(px + 2, py + S / 2 - 8, 'left:', 10, 'end') + note(px + 2, py + S / 2 + 4, 'hole', 10, 'end', bold=True) + note(px + 2, py + S / 2 + 16, '(body)', 10, 'end')
    b += note(px + S + 5, py + S / 2 - 8, 'right:', 10) + note(px + S + 5, py + S / 2 + 4, 'knob', 10, bold=True) + note(px + S + 5, py + S / 2 + 16, '(mind)', 10)
    lx = 228
    b += note(lx, 34, 'Edge families', 10.5, bold=True) + note(lx, 48, 'knob   hole', 9, color='#666')
    for i, (f, nm) in enumerate([('b', 'body: round'), ('m', 'mind: keyhole'), ('c', 'craft: triangle')]):
        yy = 66 + i * 24
        b += _shape(f, lx + 11, yy, 8, 0, '#8a6a1f', '#8a6a1f') + _shape(f, lx + 40, yy, 8, 0, '#fff', '#8a6a1f') + note(lx + 58, yy + 4, nm, 10)
    S2 = 84
    x1 = 356
    b += note(x1 + S2 - 2, 18, 'Fits: a link', 10.5, 'middle', bold=True, color='#2e6b2e')
    b += piece(x1, py + 6, S2, 'Dodge', 'Guard 5', DODGE) + piece(x1 + S2 - 4, py + 6, S2, 'Chop', 'Hurt 5', CHOP)
    b += note(x1 + S2 - 2, py + S2 + 18, 'body knob in body hole', 9.5, 'middle', color='#2e6b2e')
    x2 = 536
    b += note(x2 + S2 + 5, 18, 'Does not fit: not allowed', 10.5, 'middle', bold=True, color='#c0392b')
    b += piece(x2, py + 6, S2, 'Swing', 'Hurt 5', SWING) + piece(x2 + S2 + 10, py + 6, S2, 'Chop', 'Hurt 5', CHOP)
    b += f'<path d="M {x2+S2-3},{py+6+S2/2-9} l 14,18 m 0,-18 l -14,18" stroke="#c0392b" stroke-width="3" fill="none"/>'
    b += note(x2 + S2 + 5, py + S2 + 18, 'mind knob against body hole', 9.5, 'middle', color='#c0392b')
    return svg(720, 140, b, 'Swing, the basic Hurt piece, with its four edges; the three edge families; a fit and a misfit')


def fig_chain_rank():
    """A made-up position in the 2.7.00 firing order: you place Dodge right of Chop; Chop links down to a Sun. Values follow the engine (Riposte x1.5 rounded, then the Sun x2)."""
    S = 84
    b = grid(2, 2, S, 2, 2, labels=False)
    b += piece(2 + 0 * S, 2 + 0 * S, S, 'Chop', 'Hurt 5', CHOP, 'me', badge='3')
    b += piece(2 + 1 * S, 2 + 0 * S, S, 'Dodge', 'Guard 5', DODGE, 'me', badge='2')
    b += piece(2 + 0 * S, 2 + 1 * S, S, 'Sun', 'x2', SUN, 'env', badge='1')
    return svg(2 * S + 4, 2 * S + 4, b, 'A chain of three in the 2.7.00 firing order')


def fig_start():
    """The opening: the Blank, your start piece, the creature's start piece, its aim (positions as in the full book's figure 6)."""
    S = 66
    b = grid(2, 2, S, labels=False)
    b += piece(2 + 1 * S, 2 + 1 * S, S, 'Blank', '', WILD, 'none', dashed=True)
    b += piece(2 + 1 * S, 2 + 2 * S, S, 'Chop', 'Hurt 5', CHOP, 'me')
    b += piece(2 + 0 * S, 2 + 1 * S, S, 'Its', 'Trick 2', figs.NSCUT, 'foe')
    b += figs.aim(2 + 0 * S, 2 + 0 * S, S)
    return svg(4 * S + 4, 4 * S + 4, b, 'The board at the start')


def fig_env():
    S = 78
    b = ''
    for i, (n, l2, e) in enumerate([('Sun', 'x2', SUN), ('Bramble', '-10%', BRAMBLE), ('Rain', 'guard', RAIN), ('Thornburst', '-10% you', THORN)]):
        b += piece(i * (S + 2), 0, S, n, l2, e, 'env')
    return svg(4 * S + 6, S, b, 'The four environment pieces with their edges')


B = []
w = B.append

# ================================================================ page 1: title, the game in one minute, contents
w('<div class="title"><h1>Puzzle Combat</h1><div class="sub">Quick rules</div>'
  '<div class="meta">Gnome Venture 2.7.00 · the v1 board<br>short edition of the full rule book</div></div>')
w(two(box('The game in one minute', ul(
    'You and a creature take turns putting jigsaw pieces on a <b>4 by 4</b> board.',
    'Pieces whose edges fit are <b>linked</b>. The piece you place and everything linked to it <b>fire</b> together as a <b>chain</b>.',
    'Your Hurt and Charm pieces fill the creature\'s <b>Yield bar</b>. Fill it: you win.',
    'Its Hurt pieces lower your <b>health</b>. At 0 you lose.',
    'You see where it will play next (its <b>aim</b>) before you move.',
    'The <b>environment</b> drops Sun, Rain, Bramble and Thornburst pieces. Whoever links one in gets its effect.')),
    '<!--TOC-->' + box('', f'<p><b>Colours.</b> {ME}your pieces · {FOE}the creature\'s · {ENV}the environment\'s. '
          + 'Types: ' + T('Hurt', 'Guard', 'Heal', 'Charm', 'Soothe', 'Trick', 'Item') + '</p>'
          '<p><b>Saved fights</b> from before 2.7.00 keep their old rules (chain fires in link order; the creature gets a free piece when it has fewer than 2 on the board). This book describes new fights.</p>', 'warn'), 1.1, 1))

# ================================================================ 1
w(ch('1', 'Goal and the Yield bar', 'win, lose, multipliers'))
w(two(
    h3('The Yield bar') + ul(
        'One bar, empty at the start ("Yield 0/43"). Bigger and higher-level creatures have longer bars.',
        'Your <b>Hurt</b> and <b>Charm</b> fill the same bar: "Yield 23/40: hurt 15, charm 8".',
        'A creature\'s heal <b>empties</b> it: the hurt part first, then the charm part.')
    + table(['Creature (card says)', 'Hurt 10 adds', 'Charm 10 adds'],
            [['Wary: most creatures', '10', '6'], ['Gentle', '8', '10'], ['Boss: "cannot be charmed"', '10', '6 (Charm still fills the bar)']], num=(1, 2)),
    h3('Your health') + ul(
        'You bring your expedition\'s health in and leave with what is left: it <b>carries over</b> to the next fight.',
        'Lowered by the creature\'s Hurt pieces, Bramble, Thornburst and poison.',
        '<b>Guard</b> blocks only its Hurt pieces: not Bramble, Thornburst or poison.',
        'One chain fills the bar <b>and</b> takes your last health: you win (the bar is checked first).')))
w(h3('How a fight ends'))
w(table(['Ending', 'When', 'You get'],
        [['It backs off', 'Bar full and charm is <b>not</b> the larger share (a tie backs off). Always, for a boss.', 'Full XP and its normal drops.'],
         ['It is won over', 'Bar full and charm is the larger share. Never for a boss.', 'Full XP, a gift, and its seed or guide drops.'],
         ['Knocked out', 'Your health reaches 0.', 'Nothing. You wake where you set out with half your health and 2 energy less. You keep your things.'],
         ['You run', 'You press Run. Not allowed against a boss.', 'Nothing won, nothing lost.'],
         ['It wanders off', '24 turns pass. Against a boss this counts as a knock-out.', 'Nothing.']], widths=['15%', '45%', '40%']))

# ================================================================ 2
w(ch('2', 'One round', 'you, the creature, the environment'))
w(fig_round())
w(two(
    h3('Your turn in taps') + table(['Step', 'What happens'],
        [['1 Look', 'Yield bar, aim chip and its red mark, the creature\'s status chips, environment pieces, your hand.'],
         ['2 Pick', 'Tap a hand piece. Cells where it may go light up; each shows what the chain adds to the bar and what it costs you.'],
         ['3 Flip', 'Tap Flip and look again: every piece has two shapes.'],
         ['4 Place', 'Tap a lit cell. The plan line shows your chain and the result; the aim chip updates. Not happy? Pick again.'],
         ['5 End turn', 'Locks the move. <b>No undo.</b> Then you watch the replay.']], widths=['19%', '']),
    h3('Your hand') + ul(
        '<b>5 pieces</b>, thrown away and redrawn every round. You cannot save a piece, except a <b>Keeper</b> (chapter 4).',
        'Used and expired pieces go to your discard pile; you draw them again later.',
        '<b>Pass</b> is always allowed and free, but the creature and the environment still play. Pass only when every move is worse than nothing.',
        'A tool piece wears its tool: <b>2 durability</b> each time you play it.'), 1.25, 1))

# ================================================================ 3
w(ch('3', 'The pieces', 'types, edges, fitting, flip'))
w('<p>Every piece has a name, a type, a number and four edges; some have a tag (chapter 4). A legendary crop piece can also carry a built-in knack.</p>')
w(fig(fig_pieces()))
w(table(['Type', ('When it fires for you', 'me'), ('When it fires for the creature', 'foe')],
        [[T('Hurt'), 'Adds its number to the bar as hurt. The creature\'s guard soaks it first; its Evade makes one Hurt miss.', 'Lowers your health (your guard soaks it first).'],
         [T('Charm'), 'Adds its number to the bar as charm (x0.6 on a wary creature or a boss). Guard and Evade do not touch it.', 'Nothing.'],
         [T('Guard'), 'Blocks that much damage until your next turn starts.', 'Gives it guard that soaks your Hurt until its next turn.'],
         [T('Heal'), 'Heals you that much, never above your maximum.', 'Empties the bar: hurt part first, then charm.'],
         [T('Item'), 'Heals you that much. A <b>Snack</b> eats a real snack from your satchel; it is refused at full health and after the fight\'s snack limit.', 'Nothing.'],
         [T('Soothe'), 'The creature\'s hits this round do that much less in all.', 'Nothing.'],
         [T('Trick'), 'Nothing by itself. It powers a combo (chapter 5).', 'Its tag works (Quick, Evade, Bash, Poison, Heal...).']], widths=['9%', '56%', '35%']))
CUT = (h3('How your pieces are cut') + table(['Edge', 'What it is'],
        [['Left', 'A <b>hole</b> of the type\'s family. ' + '<br>' + T('Hurt', 'Guard') + ' body<br>' + T('Heal', 'Charm', 'Soothe') + ' mind<br>' + T('Trick', 'Item') + ' craft'],
         ['Right', 'A <b>knob</b>. Its family is printed on each piece.'],
         ['Top, bottom', 'One knob and one hole of one family.<br>Knob on top: ' + T('Hurt', 'Charm', 'Trick') + '<br>Hole on top: ' + T('Guard', 'Heal', 'Soothe', 'Item')],
         ['Top/bottom family', 'Tool and craft pieces: craft. Pal pieces: body. Crop and legendary crop pieces: mind. All others: the family of their type.']], widths=['23%', ''])
    + '<p class="small">The lit cells already show where a piece goes; this only helps you plan.</p>')
STAYS = h3('How long a piece stays') + table(['Piece', 'It leaves when'],
        [['Any piece', 'A chain of 3 or more fires it (chapter 5).'],
         [ME + 'Yours', 'After 3 rounds: the round you placed it and two more.'],
         [FOE + 'Creature\'s', 'After 3 rounds, or as soon as it has fired twice. Being placed counts as the first firing.'],
         [ENV + 'Environment', 'After 3 of your turns.'],
         ['The Blank', 'At the end of round 1.']], cls='keep nw1', widths=['27%', ''])
w(two(
    h3('Fitting and linking') + ul(
        'Each edge is a <b>knob</b> (solid, sticks out) or a <b>hole</b> (hollow, cut in) of one family: <b>body</b> (round), <b>mind</b> (keyhole) or <b>craft</b> (triangle).',
        'Two edges <b>fit</b> when one is a knob and the other a hole of the same family.',
        'You may place on an empty cell only if the piece touches at least one piece <b>and every touching edge fits</b>.',
        'A joint that fits is a <b>link</b>. Chains run along links.',
        '<b>Wild</b> edge: fits anything. The Blank has four, but no chain runs through it. A Plant\'s Bramble has wild edges too, and it does link.',
        '<b>Flat</b> edge: fits anything, never links (today only the right edge of Offer).'),
    CUT))
w(two(
    h3('Flipping') + ul(
        'Flip swaps <b>top and bottom</b>. Left and right never change: if a piece cannot go beside a neighbour, flipping will not help.',
        'Free and unlimited. Flip every piece once while you look.',
        'A flipped piece stays flipped on the board, and comes back into your hand the right way up (an unplayed Keeper keeps its flip).'),
    STAYS))
w(h3('Where the numbers come from'))
w(two('<p>Number = base value + your stat for the type + a third of your gnome level (rounded down) + rank bonus: <span class="nw">Uncommon <b>+2</b></span>, <span class="nw">Rare <b>+4</b></span>, <span class="nw">Masterwork <b>+5</b></span>.</p>',
      table(['Type', T('Hurt'), T('Guard'), T('Heal'), T('Charm', 'Soothe'), T('Trick', 'Item')], [['Stat', 'Grit', 'Nimble', 'Hardiness', 'Charm', 'Lore']]), 1, 1.35))

# ================================================================ 4
w(ch('4', 'Tags, poison and knacks', 'one extra effect per piece'))
w(h3('Tags on your pieces'))
w(two(
    table(['Tag', 'On', 'What it does'],
        [['Pierce', T('Hurt'), 'Ignores the creature\'s guard.'],
         ['Poison', T('Hurt'), 'Hits the bar again on each of the creature\'s next 2 turns (see Poison).'],
         ['Trip', T('Hurt'), 'The creature skips its next turn: this very round it places nothing.'],
         ['Bash', T('Hurt'), 'Adds the guard you hold right now to the hit, and uses that guard up.'],
         ['Quick', T('Hurt'), 'No extra effect for you (one piece a turn).'],
         ['Heavy', T('Hurt'), 'Nothing extra: just a bigger number.'],
         ['Hum', T('Charm'), 'Also soothes 2: its hits this round do 2 less in all.'],
         ['Lull', T('Charm'), 'The creature skips its next turn, like Trip.'],
         ['Bond', T('Charm'), 'Your Charm counts 10% more for the rest of the fight, up to 3 times, never above x1. No use against a gentle creature.'],
         ['Pluck', T('Trick'), 'Once a fight, when you place it: a small chance (8% + 3% per Luck step, half against a boss) to lift an item the creature could drop.']], widths=['14%', '14%', '']),
    table(['Tag', 'On', 'What it does'],
        [['Hold', T('Guard'), 'What is left of this guard after the creature\'s turn stays up one more turn.'],
         ['Thorns', T('Guard'), 'While it is up, each hit it blocks adds 2 to the bar.'],
         ['Evade', T('Guard'), 'The creature\'s next Hurt misses completely. If still unused at the end of the round, it also stops a poison tick on you.'],
         ['Mend', T('Guard'), 'Also heals you 2.'],
         ['Keeper', T('Guard'), 'If you do not play it, it stays in your hand through the redraw (you draw 4 new pieces, not 5). It keeps its flip.'],
         ['Plenty', T('Heal') + '<br>' + T('Hurt'), 'Next round your hand is 6 pieces (5 if you were tripped). One round only; two in one round still give 6.'],
         ['Simmer', T('Heal'), 'You heal 2 as each of your next 2 turns starts (less if nearly full). A second Simmer sets the count back to 2; it does not add.']], widths=['14%', '14%', ''])
    + box('Keeper, Plenty, Simmer', ul(
        'Work <b>only when you place the piece</b>. Fired again by a later chain, the number fires but the tag does nothing.',
        '<b>Keeper</b>: keep the Guard for a big aim or a Riposte. It costs you one new piece each round.',
        '<b>Plenty</b> pays next round: place it when this round\'s best move is small anyway.',
        '<b>Simmer</b>: up to 4 extra health, only if you are hurt when your turns start.'), 'tip')))
w(two(
    h3('Poison') + table(['', ('Your poison on the creature', 'me'), ('The creature\'s poison on you', 'foe')],
        [['Tick size', 'Half the piece\'s printed number, rounded up (x0.8 on a gentle creature).', 'A third of the printed number for a Hurt, half for a Trick. At least 1.'],
         ['Combos, Sun', 'Do not raise it.', 'Do not raise it.'],
         ['Ticks', 'As each of the creature\'s next 2 turns starts, also on a turn it skips.', 'At the end of the round, after the environment\'s piece.'],
         ['Stacking', 'A new Poison sets the count back to 2 and keeps the larger tick.', 'Each poison adds 2 ticks; at most 3 wait.'],
         ['Stopped by', 'Nothing. A Hurt that misses still sets the poison.', 'Not guard. Your Evade does, if still unused when the round ends.']], widths=['15%', '43%', '42%']),
    h3('Built-in knacks <span style="text-transform:none;letter-spacing:0;font-weight:400;color:#5a5a50">(some legendary crop pieces)</span>') + table(['Knack', 'On', 'What it does'],
        [['Tender', T('Heal', 'Item'), '+2 to the heal.'],
         ['Leech', T('Hurt'), 'Heals you 1 plus a sixth of the hit, if any of it got past the guard.'],
         ['Spiky', T('Guard'), '+2 hurt on the bar each time it fires for you. Its guard does not soak it.'],
         ['Soft touch', T('Charm', 'Heal') + ' ' + T('Item'), 'Also soothes 2.'],
         ['Warm', T('Hurt'), 'A quarter of the damage also counts as charm (times the charm factor).'],
         ['Finisher', T('Hurt'), '+3 once the <b>hurt</b> part alone is at 60% of the bar or more.'],
         ['Hardy', T('Guard'), '+2 guard.']], widths=['17%', '22%', '']), 1.15, 1))

# ================================================================ 5
w(ch('5', 'Combos and chains', 'the heart of the game'))
w(two(
    h3('Combos') + '<p>A bonus when the chain runs from one of <b>your</b> pieces straight into another of yours along a link. It lands on the <b>second</b> piece.</p>'
    + table(['Combo', 'From', 'Into', 'Bonus on the second piece'],
        [['Ambush', T('Trick'), T('Hurt'), 'x1.5, plus the Trick\'s number'],
         ['Riposte', T('Guard'), T('Hurt'), 'x1.5'],
         ['Double Swing', T('Hurt'), T('Hurt'), '+2'],
         ['Bait', T('Trick'), T('Guard'), 'plus the Trick\'s number'],
         ['Calm Charm', T('Soothe'), T('Charm'), 'x1.5'],
         ['Win Over', T('Charm'), T('Item'), 'half the Item\'s number is also added as charm']]),
    box('The rule that decides most turns', '<p>A combo is decided by <b>which piece you place and which it links to</b>, not by firing order. The piece you place is the first of the pair. The piece it links to is the second and gets the bonus. Put the first piece next to the second, which is already on the board.</p>'
        + ul('Ambush: place the Trick next to a Hurt.', 'Riposte: place the Guard next to a Hurt.', 'Placing the Hurt next to the Trick gives <b>no combo</b>, even though the Trick fires first (rank order).',
             'A piece reached through the Blank or an environment piece has no combo partner.', 'The creature gets the same combos from its own pieces.')), 1.25, 1))
w(h3('How a chain fires'))
w(ol('<b>Build the chain.</b> Start at the piece just placed. Add every piece linked to it, newest first, and from each of those follow its own links. A piece is in a chain once.',
     f'<b>Fire in rank order</b> {NEW}. Inside one rank, the build order holds.'))
w('<div class="rank"><div><b class="o">1st</b>' + T('Env') + ' pieces</div><div><b class="o">2nd</b>' + T('Guard', 'Soothe') + '</div><div><b class="o">3rd</b>' + T('Trick') + '</div><div><b class="o">4th</b>' + T('Hurt', 'Charm') + '</div><div><b class="o">5th</b>' + T('Heal', 'Item') + '</div></div>')
w(two(
    ul('Combos still follow the <b>build</b> order: a piece\'s partner is the piece the chain came from, not the piece that fired just before it.',
       'Each piece fires for its <b>owner</b>: yours for you, the creature\'s for the creature.',
       'An environment piece fires for the side that <b>started</b> the chain.',
       'If the fight ends in the middle of a chain, the rest does not fire.',
       'The same rules hold for the creature\'s chain.')
    + h3('The chain of 3 rule (use-up)') + ul(
       'A chain that fires <b>3 or more</b> pieces uses up every piece that fired: they leave the board at once.',
       'Whoever started it, whoever owns the pieces. Environment pieces count and are used up too.',
       'A chain of <b>1 or 2</b> uses nothing up: those pieces stay and can fire again.'),
    '<div style="display:flex;gap:3mm;align-items:center"><div class="fig" style="flex:none;width:36mm">' + fig_chain_rank() + '</div><div>'
    + '<p><b>Example.</b> You place Dodge right of Chop; Chop touches a Sun. Chain: Dodge, Chop, Sun. It fires by rank:</p>'
    + table(['', 'Piece', 'Result'], [['1', 'Sun ' + T('Env'), 'your pieces in this chain count double'], ['2', 'Dodge ' + T('Guard'), '5 x 2 = <b>10 guard</b>'],
                                     ['3', 'Chop ' + T('Hurt'), 'came from Dodge: Riposte 5 x 1.5 = 8, then x2 = <b>16</b>']], cls='keep plain')
    + '<p>3 fired: all three leave the board.</p></div></div>', 1, 1.2))
w(h3('The other side\'s pieces in your chain'))
w(mc(ul('A creature Hurt in your chain hits <b>you</b>. A creature Guard gives it guard against your later Hurts. A creature Heal empties the bar. Its tags work for it.',
        'But it spends one of that piece\'s two firings: firing a harmless creature piece is a cheap way to remove it.',
        '<b>Bait:</b> the aim is fixed before you move. Put a piece of yours with a fitting edge next to the aim cell and the creature\'s chain fires it, for <b>you</b>, with your combos. The aim chip shows it ("fires your Pierce"). It fails if the creature has Evade up: your Hurt misses.')))

# ================================================================ 6
w(ch('6', 'The opening', 'round 1'))
w(two(
    fig(fig_start(), f'{ME}yours · {FOE}the creature\'s · red mark: its aim'),
    ol('The <b>Blank</b> sits on a random one of the four middle cells. It fits every edge, never fires, and no chain runs through it. It leaves at the end of round 1.',
       'You get your first hand of 5. Pick <b>one piece</b> and <b>one side</b> of the Blank.',
       'The creature puts its gentlest piece that is not a Hurt on a random side. Same side as you: yours stays, its piece moves to the next free side. A boss puts out two pieces.',
       '<b>Nothing fires.</b> Turn 1 begins with your other 4 pieces in hand.')
    + box('Start with a Hurt', ul('On turn 1 you can then place a Trick or a Guard next to it for a combo. Find that partner in your hand first and leave its cell free.',
                                 'The aim mark shown during the start pick is a placeholder: read the real aim once both start pieces are down.'), 'tip'), 1, 2.4))

# ================================================================ 7
w(ch('7', 'The creature\'s turn', 'what it does and how to read the aim'))
w(h3('In order'))
w(mc(ol('Its old guard and Evade drop (unless a Hold piece keeps the guard).',
        'Your poison on it ticks. If that fills the bar, you win before it acts.',
        'It plays its <b>aim</b>: the piece and the cell it showed you. If it cannot, it picks its best move now. If it is slowed (Trip, Lull), it plays nothing.',
        'Its chain fires, by the same rules as yours.',
        'Extras: one more piece after a Quick piece, a Water creature\'s push, a Plant\'s Bramble.',
        'The environment places one piece.',
        'Poison on you ticks, unless your Evade is still up. Then Simmer heals you. A trip takes effect.',
        'Old pieces leave (3 rounds). Venom cells fade.',
        'You draw a new hand (Keepers stay; 4 if tripped, 6 after Plenty). Your guard fades, except what Hold keeps.',
        f'The new aim is shown. The creature gets <b>no free piece</b> in new fights {NEW}.')))
w(two(
    h3('The aim') + ul(
        'The red mark is the cell. The chip names the piece and what its <b>whole turn</b> would do right now ("Peck: hits you for 9"): combos, Sun, Swarm, your guard, your pieces it fires, a Quick piece\'s second piece.',
        '<b>Not</b> included: poison ticks on you, a Reptile\'s venom.',
        '"· fires Sun" / "· fires Bramble": its chain would fire that environment piece. A ring marks it on the board.',
        'The aim is a promise: the piece lands on that cell even if the cell now touches nothing.')
    + table([('You do this', 'me'), ('The creature does', 'foe')],
        [['Put a piece <b>on</b> the aim cell', 'Picks again: its best move as the board is now, at full strength. Your piece is not harmed.'],
         ['Put a piece <b>next to</b> the aim cell with an edge that does not fit the aimed piece', 'Picks again. The chip reads "broken".'],
         ['Play Trip or Lull', 'Loses its turn. The chip reads "is slowed: no move".']], cls='keep plain', widths=['42%', '']),
    h3('The creature\'s pieces') + ul(
        'It holds <b>3</b> pieces (a boss 4) and plays one a turn. It must make a link if any piece can.',
        'Every creature piece falls off after it has fired twice ("plays x2").',
        'Its deck: 4 class pieces, 1 region piece (2 for large and boss), a size extra (large: Slam; boss: Scheme and Crush) and 3 pieces of its own. Tap a piece on the card to read it.')
    + table(['Its tag', ('What it does to you', 'foe')],
        [['Quick', 'It plays one more piece this turn.'], ['Pierce', 'Ignores your guard.'],
         ['Poison', '2 ticks on your health (chapter 4). At most 3 wait.'], ['Trip', 'You draw 4 pieces next round instead of 5.'],
         ['Bash', 'Adds its guard to the hit. A Trick with Bash lends its guard to its next Hurt.'],
         ['Evade', 'Your next Hurt misses ("dodges next hit"). Lasts until its next turn starts.'],
         ['Thorns', 'While its guard is up, each of your hits it soaks pricks you (2, or 4% of your health if more).'],
         ['Hold', 'Its guard lasts a turn longer.'], ['Heal', 'Empties the bar by its number: hurt part first, then charm.']], widths=['15%', ''])))

# ================================================================ 8
w(ch('8', 'Creature classes', 'one extra rule each'))
w('<p>Every creature has one rule from its class, shown on its card and as a chip. A boss has the boss rule instead.</p>')
w(table(['Class · rule', ('What it does', 'foe'), ('What to do', 'me')],
        [['Critter<br><span class="small">Swarm</span>', 'When its Hurt fires, count its <i>other</i> pieces on the board: 2 or 3 give <b>+1</b>, 4 or more <b>+2</b>. Every piece counts. Also when its Hurt fires in your chain. Its Trick Skitter is Quick.', 'Count its pieces before you read the aim. Chains of 3 through its pieces shrink it. Gentle Critters take Charm at full value.'],
         ['Bird<br><span class="small">Two aims</span>', 'It shows two cells. Take the first and it plays the second; take both and it picks again. Its Trick Flutter Off gives it Evade.', 'Taking a cell rarely saves you. Use Guard, or a misfit next to the aim. When it "dodges next hit", play Guard, Heal or Charm.'],
         ['Beast<br><span class="small">Grudge</span>', 'Each time a piece of yours stands on its aim cell, its Hurt hits <b>25% harder</b> (up to 3 times). Losing health on its turn clears it. A misfit beside the cell adds no Grudge.', 'Let small hits land. Block only big ones, and prefer a misfit.'],
         ['Water<br><span class="small">Current</span>', 'After its piece lands, one of your pieces touching it slides one cell away, if that cell is free. Its Trick Undertow trips you.', 'Do not count on a link next to its aim lasting. A piece with something behind it cannot be pushed.'],
         ['Plant, Fungus<br><span class="small">Grows</span>', 'After its turn it grows a Bramble beside its piece (one at a time). Whoever chains the Bramble fires it. Its guard has Thorns; Sap Mend heals it.', 'Fire its Bramble yourself first: a tenth of the bar for you. Hit its guard with Pierce or Charm.'],
         ['Reptile, Amphibian<br><span class="small">Venom trail</span>', 'Where its piece leaves the board, the cell is venom for 2 turns. A piece of yours placed there poisons you (2 a round, 2 rounds). Its Trick Venom Spit poisons.', 'Check the cell for the venom mark: the lit number does not show it. Finish fast.'],
         ['Boss<br><span class="small">Two turns</span>', 'It also shows the piece it will play next round. That piece is forced; its cell is chosen then. Starts with 2 pieces, holds 4, plays set-up, Hurt, Hurt in turn.', 'Time your guard for its big piece. Do not block out of habit. Keep Rain away from it. No charm win, no running, 24 turns.']],
        cls='', widths=['15%', '47%', '38%']))

# ================================================================ 9
w(ch('9', 'The environment', 'the third player'))
w(two(
    ul('After the creature\'s turn the environment places <b>one piece</b>. The <b>NEXT</b> strip shows which: you know what is coming, not where.',
       'It goes on an empty cell with nothing on any side, among the three such cells farthest from all pieces. If none exists it takes a cell where it fits. With 12 or more cells taken it places nothing.',
       'Its pieces belong to nobody. Link one into your chain and it fires for you. The creature can do the same.',
       'They count for chain length and are used up by a chain of 3. Otherwise they stay 3 of your turns.'),
    fig(fig_env(), 'Each has all three families on its edges.')
    + table(['In the deck, by creature size', 'Sun', 'Bramble', 'Rain', 'Thornburst'],
            [['small', '2', '1', '2', '1'], ['medium, large', '2', '2', '2', '2'], ['boss', '2', '3', '2', '2']], num=(1, 2, 3, 4), cls='keep plain')
    + '<p class="small">The region adds one more of one kind. The deck is reshuffled when it runs out.</p>', 1.1, 1))
w(table(['Piece', ('Your chain fires it', 'me'), ('Its chain fires it', 'foe'), 'Tip'],
        [[T('Env').replace('Env', 'Sun'), 'Every piece of yours in that chain counts double: hurt, charm, guard, healing.', 'Every piece of its counts double.', 'Bring your biggest chain to it. If its aim touches a Sun, fire the Sun first or take the cell.'],
         [T('Env').replace('Env', 'Bramble'), 'A tenth of the bar is added.', 'You lose a tenth of your max health. Guard does not help.', 'Fire it in a chain of 2: it stays for another go.'],
         [T('Env').replace('Env', 'Rain'), 'You get guard worth 15% of your max health.', 'It gets guard worth 15% of its Yield bar.', 'Do not leave it to a big creature: its guard is huge.'],
         [T('Env').replace('Env', 'Thornburst'), 'You lose a tenth of your max health.', '5% of the bar is added.', 'Stay off cells that touch it: any touching piece links to it.']], widths=['11%', '29%', '25%', '35%']))

# ================================================================ 10
w(ch('10', 'Winning: hurt or charm', 'and what carries over'))
w(two(
    table(['', T('Hurt') + ' route', T('Charm') + ' route'],
        [['Counts', 'Fully; x0.8 on a gentle creature.', 'x0.6 on a wary creature or boss; fully on a gentle one. Bond raises it.'],
         ['Stopped by', 'Its guard (Pierce gets through), its Evade, its heal.', 'Only its heal. Guard and Evade do not touch charm.'],
         ['Also counts', 'Combos, Sun, Bramble, Thornburst, poison.', 'Warm (a quarter of the hit).'],
         ['Ending', '"Backs off": full XP and normal drops.', '"Won over" if charm is the larger share: full XP, a gift, its seed or guide drops.']], widths=['17%', '38%', '45%']),
    box('Which route?', ul('Play Charm when the creature is <b>gentle</b>, when its <b>guard is high</b>, or when it <b>dodges your next hit</b>.',
                           'Above small size a charm win is rare: Bramble, Thornburst and poison all count as hurt. Do not plan one unless your deck is built for it.',
                           'Against a boss, Charm still fills the bar at x0.6 and ignores its guard.'), 'tip')
    + ul('<b>Health back:</b> Heal and Item pieces, Mend, Simmer, Leech, and a Rest outside the fight.',
         'After the fight a result card shows; "Collect the reward" ends it. Tool wear is saved however the fight ended.'), 1.3, 1))

# ================================================================ 11
w(ch('11', 'Building your deck', 'the Puzzle box, belt, pals and slots'))
w(two(
    ul('Built in the <b>Puzzle box</b> (tabs: Kit, Belt, Pals). Locked once the fight starts.',
       'First time: a starter of 4 fixed pieces (Swing, Dodge, Rest, Charm) plus <b>6 of 12</b> offered pieces, or a ready kit:')
    + table(['Kit', 'The 6 pieces'],
        [['Bold (default)', 'your calling piece, Jab, a second Swing, Pierce, Snack, Oat Cake'],
         ['Steady', 'calling piece, Jab, second Swing, Pierce, Brace, your home region\'s piece'],
         ['Kind', 'calling piece, Jab, second Swing, Pierce, Hum, Soothe']], widths=['24%', ''])
    + ul('Later you switch on more pieces you own: knacks, crop, legendary crop, craft and region pieces. Filters: All, basic, crop, a crown for legendary pieces, craft, region, wearables.',
         'A piece you have just earned arrives switched <b>off</b>, marked <b>NEW</b>, until you switch it once.',
         'The deck bar shows "Hurt pieces: N of M" and warns under 3 in 10: "Few Hurt pieces: fights will be long".'),
    h3('Deck limits') + table(['Rule', 'Limit'],
        [['Kit pieces', 'at least <b>8</b>; no maximum'], ['Hurt pieces', 'at least <b>1</b> (3 in a custom starter)'], ['Rare · Masterwork', 'at most <b>3</b> · at most <b>1</b>'],
         ['Slots', 'Larder and Keepsakes, below'], ['Not legal?', 'The fight plays the default kit instead.']], widths=['32%', ''])
    + h3('Belt and pals') + ul(
        'Each tool on your fight belt adds its one piece (axe: Chop; tilling tool: Hoe Hook; staff: Sweep; lantern: Glare...).',
        'Belt slots: <b>2</b>; <b>3</b> with the Stitched Fight Belt (level 8); <b>4</b> with the Masterwork Fight Belt (level 18).',
        'A tool has 20 durability plus 4 per rank; each play of its piece costs 2. A broken tool gives no piece: fix it with a Tool Repair Kit.',
        'Each pal in your party lends one piece (for example Bark Badger, a Guard).'), 1.15, 1))
w(h3('Slots: the Larder and the Keepsakes'))
w(table(['Slot', 'Holds', 'Count by gnome level'],
        [['Larder', 'Crop pieces and legendary crop pieces', '<b>3</b> from level 1 · <b>4</b> from level 10 · <b>5</b> from level 20'],
         ['Keepsakes', 'Wearables (chapter 12)', '<b>1</b> from level 1 · <b>2</b> from level 15 · <b>3</b> from level 25 · <b>4</b> from level 40']], widths=['13%', '37%', '50%']))
w(two(
    ul('Each switched-on piece of that kind takes one slot. A crop piece in your starter counts too: the Bold kit\'s Oat Cake takes a Larder slot.',
       'One too many is refused ("Your Larder holds 3 crop pieces. Take one out first."). A piece over the count stays out of the deck: "left out".',
       'Tool, pal, region, craft and knack pieces need no slot.'),
    h3('Legendary crop pieces') + ul(
       '<b>42</b>, one per treasure crop. Harvest that crop <b>3 times</b> and the piece is yours for good.',
       'Rank follows your food mastery of that crop, Common to Masterwork. Rare and Masterwork count toward the deck caps.',
       'Needs a Larder slot. Top and bottom edges are mind, like a crop piece.',
       'They carry the only Keeper, Plenty and Simmer tags, and some carry a knack.',
       'Legendary <b>Heal</b> pieces have mind edges on three sides: they only go beside mind knobs (always beside the Blank in round 1).',
       'The three legendary Item pieces are not Snacks: they eat nothing and are never refused.'), 1, 1.25))

# ================================================================ 12
w(ch('12', 'Wearables and the Tailor', f'{NEW}', pb=True))
w('<p>A wearable is something your gnome wears and also one puzzle piece: a <b>Keepsake</b> piece. It needs a Keepsake slot and is off until you switch it on. Wearables exist only where puzzle combat v1 is switched on.</p>')
w(two(
    table(['Wearable', 'Cut (piece)', 'Type', 'Base', 'Tag', 'How you get it'],
        [['Flood Boots', 'Puddle Hop<br>Sure Foot', T('Guard') + '<br>' + T('Guard'), '3<br>3', 'Evade<br>Hold', 'Tailor (craft)'],
         ['Wayfarer\'s Hat', 'Brim Down<br>Tip Back', T('Guard') + '<br>' + T('Soothe'), '2<br>3', 'Thorns<br>none', 'Shop: level 5,<br>300 Petals'],
         ['Work Gloves', 'Firm Grip<br>Knuckle Down', T('Hurt') + '<br>' + T('Hurt'), '3<br>3', 'Leech knack<br>Bash', 'Tailor (craft)'],
         ['Travel Cloak', 'Wrap Up<br>Hood Up', T('Guard') + '<br>' + T('Guard'), '3<br>3', 'Mend<br>Thorns', 'Tailor (craft)'],
         ['Trail Pack', 'Rummage<br>Tidy Up', T('Trick') + '<br>' + T('Trick'), '2<br>2', 'Pluck<br>none', 'Shop: level 15,<br>800 Petals'],
         ['Yarn Scarf', 'Yarn Wrap', T('Charm'), '3', 'none', 'Cat Fish']], num=(3,), cls='keep nwall')
    + h3('Cuts and ranks') + ul(
        'Each cut is its own piece. Two copies of the same cut are one piece; the two cuts of one wearable are two pieces.',
        'Ranks: <b>Common</b>, <b>Lined</b> (+2), <b>Fine</b> (+4). If you own two ranks of a cut, the best one is the piece.',
        'A Fine piece counts as <b>Rare</b> (deck holds at most 3). You may wear a Fine piece as Lined: then it is not Rare, and a little weaker.',
        'Changing rank does not change the piece\'s on/off switch.'),
    h3('The Tailor') + ul(
        'A garden building (garden level 6, 1800 Petals). You need one in at least one garden to craft Flood Boots, Work Gloves and a Travel Cloak, to line a wearable, and to re-cut one.',
        '<b>Lining</b> (Common to Lined, then Lined to Fine) is a chance: <b>30%</b>, plus <b>8%</b> for each Tailor power point, up to <b>78%</b>.',
        'Power is the sum of the levels of all your Tailors (each counts at most 3). Only the first 6 points help; points above 6 earn you commission Petals instead.',
        'A failed lining gives a <b>Tailor\'s Thread</b>. 5 Threads make the next lining a sure thing.',
        '<b>Re-cutting</b> to the other cut costs 1 Thread (free with a level 2 Tailor).',
        'A level 3 Tailor makes your first wearable craft of the day for free.'), 1.85, 1))

# ================================================================ 13
w(ch('13', 'Tips', 'how to choose a move'))
w(mc(ol('<b>Can I win now?</b> If a cell ends the fight, take it. Nothing else matters.',
        '<b>Read the cost on the lit cell.</b> Your chain can reach a creature Hurt (it hits you) or a Thornburst. The biggest number is often a trap. Poison is not in the aim number: against Reptiles, finish fast.',
        '<b>Free guard first.</b> A Guard placed next to a Hurt both blocks and attacks (Riposte). Firing a Rain gives guard on top of your move.',
        '<b>Mind its guard and Evade.</b> With a big "its guard" up, play Pierce or Charm. With "dodges next hit" up, lead with a weak Hurt or play another type.',
        '<b>Take the chain of 3</b> when it adds clearly more, uses pieces in their last round, removes a dangerous creature piece, uses up a Sun or Rain before the creature fires it, or ends the fight. Keep a Bramble chain at 2 so it stays.',
        '<b>Do not block for its own sake.</b> Taking the aim cell makes it pick again at full strength. Block only big aims (Sun, combo, Bramble).',
        '<b>Use bait.</b> A fitting piece next to the aim cell is fired for you in its turn.',
        '<b>Trip and Lull</b> cost the creature a whole turn, and your poison still ticks.')))

# ================================================================ cheat sheet
w('<div class="cheat">')
w(ch('14', 'Cheat sheet', 'one page', pb=True))
w(fig_round())
w('<div class="cols">')
CS = [
    ('Goal', ['Fill the Yield bar. Hurt and Charm both fill it. Its heal empties it (hurt first).', 'Keep your health above 0. It carries over to the next fight.']),
    ('Fitting', ['Knob into hole, same family (round, keyhole, triangle).', 'Every touching edge must fit. A fit is a link.', 'Left is a hole, right is a knob. Flip swaps top and bottom.']),
    ('Chains', ['The chain is the placed piece and everything linked to it.', 'It fires in rank order: environment, Guard/Soothe, Trick, Hurt/Charm, Heal/Item.', 'Each piece fires for its owner. Environment pieces fire for the starter.', '3 or more fired: all of them leave the board.', 'Pieces stay 3 rounds. Creature pieces fall after 2 firings.']),
    ('Combos (place the first next to the second)', ['Trick into Hurt: x1.5 + Trick (Ambush).', 'Guard into Hurt: x1.5 (Riposte).', 'Hurt into Hurt: +2 (Double Swing).', 'Trick into Guard: + Trick (Bait).', 'Soothe into Charm: x1.5. Charm into Item: half as charm.']),
    ('Before you place', ['Can a cell end the fight?', 'Aim chip: how much, where, "fires ..."? Poison on top?', 'Its chips: guard, dodges next hit, thorny, Grudge, Swarm count.', 'Lit cell: what does it cost me? (creature Hurt, Thornburst, venom)', 'Flipped: is there a better cell?', 'Sun, Rain, Bramble: who fires them first?', 'After placing: what does the aim chip say now?']),
    ('The aim', ['It lands on its cell unless your piece is on the cell, a misfit stands beside it, or it is slowed.', 'Then it picks again at full strength.', 'The number is its whole turn, without poison and venom.', 'Your fitting piece beside the aim cell is fired for you (bait).', 'No free piece for the creature in new fights.']),
    ('Environment', ['Sun: the firing side\'s pieces count x2.', 'Bramble: the other side loses a tenth. Chain of 2 keeps it.', 'Rain: guard for the firing side (15%). Do not leave it to it.', 'Thornburst: hurts whoever fires it. Stay off it.']),
    ('Classes', ['Critter: Hurt +1 per 2 other pieces (max +2).', 'Bird: two aims. Guard instead of chasing.', 'Beast: blocking makes it hit harder. Let small hits land.', 'Water: pushes your piece away.', 'Plant: grows a Bramble. Fire it first.', 'Reptile: venom cells and poison. Finish fast.', 'Boss: shows next round\'s piece. No charm win, no running, 24 turns.']),
    ('Tags to remember', ['Keeper: stays in hand. Plenty: hand of 6 next round. Simmer: heal 2, twice.', 'Pierce: through guard. Trip, Lull: it skips a turn.', 'Evade: next Hurt misses; unused, it stops your poison tick.', 'Poison: half the printed number, 2 turns, flat.']),
    ('Deck', ['At least 8 kit pieces and 1 Hurt. At most 3 Rare, 1 Masterwork.', 'Larder (crop): 3, 4 at level 10, 5 at 20.', 'Keepsakes (wearables): 1, 2 at 15, 3 at 25, 4 at 40.', 'New pieces arrive off, marked NEW.']),
    ('Numbers', ['Board 4 by 4. Hand 5. One action. Fight limit 24 turns.', 'Charm x0.6 on wary and bosses. Hurt x0.8 on gentle.', 'Grudge +25% a block, up to 3. Venom 2 a round for 2 rounds.', 'Poison on you: at most 3 ticks wait.']),
]
for t, items in CS:
    w(f'<div class="blk"><h4>{t}</h4>' + (ol if t == 'Before you place' else ul)(*items) + '</div>')
w('</div></div>')


# ---------------------------------------------------------------- assemble
def toc(pages):
    out = ['<div class="toc"><h4>Contents</h4><div class="cols">']
    for hid, num, title, sub in heads:
        pg = pages.get(hid, '')
        out.append(f'<div class="e"><a href="#{hid}"><span class="tn">{num}</span><span class="t">{title}</span><span class="dots"></span><span class="pg">{pg}</span></a></div>')
    out.append('</div></div>')
    return ''.join(out)


def write(pages):
    body = '\n'.join(B).replace('<!--TOC-->', toc(pages))
    html = f'<!doctype html><html lang="en"><head><meta charset="utf-8"><title>Puzzle Combat quick rules</title><style>{CSS}</style></head><body>{body}</body></html>'
    open(OUT_HTML, 'w', encoding='utf-8').write(html)


def find_pages():
    """Page of each chapter, read from the PDF's named destinations (the contents links make Chromium write one per chapter id)."""
    n = int(re.search(r'Pages:\s+(\d+)', subprocess.run(['pdfinfo', OUT_PDF], capture_output=True, text=True).stdout).group(1))
    out = subprocess.run(['pdfinfo', '-dests', OUT_PDF], capture_output=True, text=True).stdout
    pages = {}
    for m in re.finditer(r'^\s*(\d+)\s.*"(c\d+)"\s*$', out, re.M):
        pages[m.group(2)] = int(m.group(1))
    return n, pages


if __name__ == '__main__':
    write({})
    if '--html' in sys.argv:
        sys.exit(0)
    subprocess.run(['node', os.path.join(HERE, 'render_short.js')], check=True)
    n, pages = find_pages()
    write(pages)
    subprocess.run(['node', os.path.join(HERE, 'render_short.js')], check=True)
    n2, pages2 = find_pages()
    assert (n2, pages2) == (n, pages), 'page numbers moved between the two passes'
    missing = [h[1] for h in heads if h[0] not in pages]
    print(n, 'pages; contents page numbers found for', len(pages), 'of', len(heads), 'chapters', ('; missing: ' + ', '.join(missing)) if missing else '', pages)
