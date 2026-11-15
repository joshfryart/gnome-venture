#!/usr/bin/env python3
"""Builds the QUICK RULES: a short player rule book for Puzzle Combat (Gnome Venture 2.7.00), condensed from the full book (build.py).

Usage: python3 build_short.py          -> puzzle-combat-quick-rules.html, then the PDF (node render_short.js), two passes so the contents list gets page numbers
       python3 build_short.py --html   -> the HTML only (no page numbers)

It reuses the full book's CSS (read from build.py's source, not by running it) and its figures (figs.py). It writes no file of the full book."""
import os, re, sys, subprocess
import figs
from figs import piece, grid, note, svg, arrow, CHOP, DODGE, SUN, WILD

HERE = os.path.dirname(os.path.abspath(__file__))
OUT_HTML = os.path.join(HERE, 'puzzle-combat-quick-rules.html')
OUT_PDF = os.path.join(HERE, 'puzzle-combat-quick-rules.pdf')

# ---------------------------------------------------------------- look: the full book's CSS, plus a few changes for a short book
_src = open(os.path.join(HERE, 'build.py'), encoding='utf-8').read()
BASE_CSS = re.search(r'CSS = r"""(.*?)"""', _src, re.S).group(1)
CSS = BASE_CSS + r"""
@page { size: A4; margin: 15mm 16mm 17mm 16mm; }
html { font-size: 10pt; }
table.keep { break-inside: auto; page-break-inside: auto; }
body { line-height: 1.36; }
h2 { break-before: auto; page-break-before: auto; margin-top: 14pt; font-size: 18pt; }
h2.pb { break-before: page; page-break-before: always; margin-top: 0; }
h3 { font-size: 12.5pt; margin: 11pt 0 4pt; }
p { margin: 0 0 5pt; }
table { margin: 4pt 0 8pt; font-size: 9.4pt; }
.box { padding: 6pt 10pt 3pt; margin: 6pt 0 8pt; }
.box h4 { font-size: 11pt; margin-bottom: 3pt; }
.fig { margin: 4pt 0 6pt; }
.fig svg { max-height: 36mm; width: auto; }
.fig.big svg { max-height: 50mm; }
.title { text-align: center; margin: 4mm 0 5mm; }
.title h1 { font-size: 32pt; margin: 0; }
.title .sub { font-size: 13pt; color: #555; margin-top: 2pt; }
.title .rule { width: 50mm; height: 3pt; background: #7a8f4e; margin: 8pt auto 6pt; }
.title .meta { font-size: 9.5pt; color: #555; }
.toc2 { columns: 2; column-gap: 10mm; font-size: 10pt; margin: 0 0 6mm; }
.toc2 .e { display: flex; align-items: baseline; padding: 2.2pt 0; break-inside: avoid; }
.toc2 .e .tn { color: #7a8f4e; font-weight: 700; width: 18pt; }
.toc2 .e .t { font-weight: 700; }
.toc2 .e .s { display: block; font-size: 8.4pt; color: #666; font-weight: 400; }
.toc2 .dots { flex: 1; border-bottom: 0.6pt dotted #999; margin: 0 5pt; transform: translateY(-3pt); }
.two { display: flex; gap: 6mm; }
.two > div { flex: 1; min-width: 0; }
.cheat { font-size: 8.9pt; }
.cheat h2 { margin-top: 0; }
.cheat .cols { column-gap: 8mm; }
.cheat h4 { margin: 5pt 0 1.5pt; }
td.k { font-weight: 700; white-space: nowrap; }
"""

# ---------------------------------------------------------------- headings and helpers
heads = []   # (id, number, title, subtitle)


def ch(num, title, sub='', pb=False):
    hid = 'c' + num
    heads.append((hid, num, title, sub))
    cls = ' class="pb"' if pb else ''
    return f'<h2 id="{hid}"{cls}><span class="n">{num}</span> {title}</h2>'


def h3(title):
    return f'<h3>{title}</h3>'


def fig(s, cap, cls=''):
    return f'<div class="fig {cls}">{s}<div class="cap">{cap}</div></div>'


def box(title, body, kind=''):
    return f'<div class="box {kind}"><h4>{title}</h4>{body}</div>'


def table(head, rows, cls='keep', num=()):
    th = ''.join(f'<th>{h}</th>' for h in head)
    tr = ''.join('<tr>' + ''.join(f'<td{" class=num" if i in num else ""}>{c}</td>' for i, c in enumerate(r)) + '</tr>' for r in rows)
    return f'<table class="{cls}"><thead><tr>{th}</tr></thead><tbody>{tr}</tbody></table>'


def ul(*items):
    return '<ul>' + ''.join(f'<li>{i}</li>' for i in items) + '</ul>'


def ol(*items):
    return '<ol>' + ''.join(f'<li>{i}</li>' for i in items) + '</ol>'


def fig_chain_rank():
    """A made-up position in the 2.7.00 firing order: you place Dodge right of Chop; Chop links down to a Sun. Values follow the engine (Riposte x1.5 rounded, then the Sun x2)."""
    S = 84
    gx, gy = 24, 30
    b = note(gx, 18, 'You place Dodge to the right of Chop. Chop touches a Sun.', 11, bold=True)
    b += grid(gx, gy, S, 2, 2, labels=False)
    b += piece(gx + 0 * S, gy + 0 * S, S, 'Chop', 'Hurt 5', CHOP, 'me', badge='3')
    b += piece(gx + 1 * S, gy + 0 * S, S, 'Dodge', 'Guard 5', DODGE, 'me', badge='2')
    b += piece(gx + 0 * S, gy + 1 * S, S, 'Sun', 'x2', SUN, 'env', badge='1')
    tx = gx + 2 * S + 26
    lines = ['The chain: Dodge (placed), then Chop, then the Sun.', 'It fires in rank order:', '',
             '1  Sun (environment): your pieces in this chain', '    count double.',
             '2  Dodge (Guard): 5 x 2 = 10 guard for you.',
             '3  Chop (Hurt): the chain came to it from Dodge,', '    so it gets Riposte: 5 x 1.5 = 8, then x 2 = 16.', '',
             'Three pieces fired: all three are used up and', 'leave the board (chain of 3).']
    for i, t in enumerate(lines):
        b += note(tx, 46 + i * 15, t, 10.5, bold=(i == 1))
    return svg(640, 210, b, 'A chain of three in the 2.7.00 firing order')


def fig_start():
    """The opening: the Blank, your start piece, the creature's start piece, its aim (positions as in the full book's figure 6)."""
    S = 62
    gx, gy = 22, 22
    b = grid(gx, gy, S)
    b += piece(gx + 1 * S, gy + 1 * S, S, 'Blank', '', WILD, 'none', dashed=True)
    b += piece(gx + 1 * S, gy + 2 * S, S, 'Chop', 'Hurt 5', CHOP, 'me')
    b += piece(gx + 0 * S, gy + 1 * S, S, 'Its piece', 'Trick 2', figs.NSCUT, 'foe')
    b += figs.aim(gx + 0 * S, gy + 0 * S, S)
    tx = gx + 4 * S + 24
    lines = ['The Blank: on one of the four middle cells.', 'Fits every edge. Never fires. No chain runs', 'through it. It leaves at the end of round 1.', '',
             'Tan: your start piece. Rose: the creature’s.', 'Nothing fires in the opening.', '', 'Red mark: the creature’s aim, the cell where', 'its next piece will land.']
    for i, t in enumerate(lines):
        b += note(tx, 44 + i * 15, t, 10.5)
    return svg(640, 280, b, 'The board at the start')


B = []
w = B.append

# ================================================================ page 1: title and contents
w('<div class="title"><h1>Puzzle Combat</h1><div class="sub">Quick rules for players</div><div class="rule"></div>'
  '<div class="meta">Gnome Venture 2.7.00 · the v1 board · short edition of the full rule book</div></div>')
w('<!--TOC-->')
w(box('Puzzle combat in one minute', ul(
    'You and a creature take turns putting jigsaw pieces on a 4 by 4 board.',
    'Pieces whose edges fit are <b>linked</b>. When you place a piece, it and every piece linked to it <b>fire</b> together as a <b>chain</b>.',
    'Your Hurt and Charm pieces fill the creature\'s <b>Yield bar</b>. Fill it and you win.',
    'The creature\'s Hurt pieces lower your <b>health</b>. At 0 you lose.',
    'You see where the creature will play next (its <b>aim</b>) before you move. Use that.',
    'A third player, the <b>environment</b>, drops Sun, Rain, Bramble and Thornburst pieces. Whoever links them in gets the effect.')))
w(box('Saved fights', '<p>A fight that was already saved before 2.7.00 keeps its old rules: the chain fires in link order, and the creature gets a free piece when it has fewer than 2 on the board. This book describes new fights.</p>', 'warn'))

# ================================================================ 1
w(ch('1', 'Goal and the Yield bar', 'win, lose, multipliers', pb=True))
w('<p>Fill the creature\'s <b>Yield bar</b> before your health reaches 0. That is the whole game.</p>')
w(ul('The creature has one bar. It starts empty, for example "Yield 0/43".',
     'Your <b>Hurt</b> pieces fill it. Your <b>Charm</b> pieces fill the same bar. The label shows both: "Yield 23/40: hurt 15, charm 8".',
     'The bar can go <b>down</b>: a creature\'s heal empties it, the hurt part first, then the charm part.',
     'Bigger and higher-level creatures have longer bars.'))
w('<p>A piece does not always add its printed number. The creature card tells you its temper:</p>')
w(table(['Creature', 'Hurt 10 adds', 'Charm 10 adds', 'The card says'],
        [['Wary (most creatures)', '10', '6', '"wary"'], ['Gentle', '8', '10', '"gentle"'], ['Boss', '10', '6', '"cannot be charmed" (Charm still fills the bar)']], num=(1, 2)))
w(h3('Your health'))
w(ul('You bring your expedition\'s health into the fight, and you leave with what is left. Health lost is the real score of a fight.',
     'The creature\'s Hurt pieces lower it. So do Bramble, Thornburst and poison.',
     'Guard blocks the creature\'s Hurt pieces. Guard does not block Bramble, Thornburst or poison.'))
w(h3('How a fight ends'))
w(table(['Ending', 'When', 'You get'],
        [['It backs off', 'The bar is full and charm is <b>not</b> the larger share. Always, for a boss.', 'Full XP and its normal drops.'],
         ['It is won over', 'The bar is full and charm is the larger share (a tie backs off). Never for a boss.', 'Full XP, a gift, and its seed or guide drops.'],
         ['Knocked out', 'Your health reaches 0.', 'Nothing. You wake where you set out with half your health and 2 energy less. You keep your things.'],
         ['You run', 'You press Run. Not allowed against a boss.', 'Nothing won, nothing lost.'],
         ['It wanders off', '24 turns pass. Against a boss this counts as a knock-out.', 'Nothing.']]))
w('<p>If one chain fills the bar <b>and</b> takes your last health, you win: the bar is checked first.</p>')

# ================================================================ 2
w(ch('2', 'One round', 'you, the creature, the environment'))
w(fig(figs.fig_round(), 'Figure 1. A round. You act once, then you watch.'))
w(ol('<b>You</b> do one action: place one piece, or pass. Flipping is free and is not an action.',
     '<b>The creature</b> plays the piece it aimed, and its chain fires.',
     '<b>The environment</b> places one piece on an empty cell. Nothing fires.',
     '<b>Clean-up</b>: poison ticks, old pieces leave, and you get a new hand of 5.'))
w(h3('Your turn in taps'))
w(ol('<b>Look.</b> Read the Yield bar, the aim chip and its red mark, the creature\'s status chips, the environment pieces and your hand.',
     '<b>Pick.</b> Tap a hand piece. The cells where it may go light up. Each lit cell shows what the chain adds to the bar and what it costs you.',
     '<b>Flip.</b> Tap Flip and look again. Every piece has two shapes.',
     '<b>Place.</b> Tap a lit cell. The plan line shows your chain and the result. The aim chip updates. Not happy? Pick again.',
     '<b>End turn.</b> This locks the move. There is no undo. Then you watch the replay.'))
w(h3('Your hand'))
w(ul('Your hand is thrown away and redrawn every round. You cannot save a piece, except a <b>Keeper</b> piece (chapter 4).',
     'Used and expired pieces go to your discard pile. You draw them again later.',
     'You may always <b>pass</b>. It costs nothing, but the creature and the environment still play. Pass only when every move is worse than nothing.'))

# ================================================================ 3
w(ch('3', 'The pieces', 'types, edges, fitting, flip'))
w('<p>Every piece has a name, a type, a number, four edges and sometimes a tag. A legendary crop piece can also carry a built-in knack.</p>')
w(fig(figs.fig_anatomy(), 'Figure 2. Swing, the basic Hurt piece, and the three edge families.'))
w(h3('The seven types'))
w(table(['Type', 'When it fires for you', 'When it fires for the creature'],
        [['<b>Hurt</b>', 'Adds its number to the bar as hurt. The creature\'s guard soaks it first. Its Evade makes one Hurt miss.', 'Lowers your health (your guard soaks it first).'],
         ['<b>Charm</b>', 'Adds its number to the bar as charm (x0.6 on a wary creature or a boss). Guard and Evade do not touch it.', 'Nothing.'],
         ['<b>Guard</b>', 'Blocks that much damage until your next turn starts.', 'Gives it guard that soaks your Hurt until its next turn.'],
         ['<b>Heal</b>', 'Heals you that much, never above your maximum.', 'Empties the bar: the hurt part first, then the charm part.'],
         ['<b>Item</b>', 'Heals you that much. A Snack eats a real snack from your satchel; it is refused at full health and after the fight\'s snack limit.', 'Nothing.'],
         ['<b>Soothe</b>', 'The creature\'s hits this round do that much less in all.', 'Nothing.'],
         ['<b>Trick</b>', 'Nothing by itself. It powers a combo (chapter 5).', 'Its tag works (Quick, Evade, Bash, Poison, Heal...).']]))
w(h3('Fitting and linking'))
w(ul('Each edge is a <b>knob</b> (solid, sticks out) or a <b>hole</b> (hollow, cut in).',
     'Each knob and hole has a family: <b>body</b> (round), <b>mind</b> (keyhole) or <b>craft</b> (triangle).',
     'Two edges <b>fit</b> when one is a knob and the other a hole of the same family.',
     'You may place a piece on an empty cell only if it touches at least one piece <b>and every touching edge fits</b>. There is no "almost".',
     'A joint that fits is a <b>link</b>. Chains run along links.'))
w(fig(figs.fig_fit(), 'Figure 3. Fitting.'))
w('<p><b>Special edges.</b> <i>Wild</i> fits anything. The Blank has four wild edges, but no chain runs through it. A Plant\'s Bramble also has wild edges, and it does link. <i>Flat</i> fits anything and never links (today only the right edge of Offer).</p>')
w(h3('How your pieces are cut'))
w('<p>The lit cells show you where a piece goes, so you need not learn this. It helps you plan.</p>')
w(table(['Edge', 'What it is'],
        [['Left', 'A hole of the type\'s family. Hurt and Guard: body. Heal, Charm, Soothe: mind. Trick, Item: craft.'],
         ['Right', 'A knob. Its family is printed on each piece.'],
         ['Top and bottom', 'One knob and one hole of one family. Hurt, Charm and Trick have the knob on top. Guard, Heal, Soothe and Item have the hole on top.'],
         ['Top/bottom family', 'Tool and craft pieces: craft. Pal pieces: body. Crop and legendary crop pieces: mind. All others: the family of their type.']]))
w(h3('Flipping'))
w(ul('Flip swaps the top and bottom edges. Left and right never change. If a piece cannot go beside a neighbour, flipping will not help.',
     'Flip is free and unlimited. Flip every piece once while you look: it often opens a cell above or below.',
     'A flipped piece stays flipped on the board. It comes back into your hand the right way up (a Keeper piece you did not play keeps its flip).'))
w(h3('How long a piece stays'))
w(table(['Piece', 'It leaves when'],
        [['Any piece', 'A chain of 3 or more fires it (use-up, chapter 5).'],
         ['Your piece', 'After 3 rounds: the round you placed it and two more.'],
         ['A creature piece', 'After 3 rounds, or as soon as it has fired twice. Being placed counts as the first firing.'],
         ['An environment piece', 'After 3 of your turns.'],
         ['The Blank', 'At the end of round 1.']]))
w(h3('Where the numbers come from'))
w('<p>A piece\'s number is its base value, plus your stat for that type, plus a third of your gnome level (rounded down), plus a rank bonus: Uncommon +2, Rare +4, Masterwork +5.</p>')
w(table(['Type', 'Hurt', 'Guard', 'Heal', 'Charm, Soothe', 'Trick, Item'], [['Stat', 'Grit', 'Nimble', 'Hardiness', 'Charm', 'Lore']]))
w('<p>A tool piece wears its tool: 2 durability each time you play it.</p>')

# ================================================================ 4
w(ch('4', 'Tags, poison and knacks', 'one extra effect per piece'))
w(h3('Tags on your pieces'))
w(table(['Tag', 'On', 'What it does'],
        [['<b>Keeper</b>', 'Guard', 'If you do not play it, it stays in your hand through the redraw. The hand is filled up to 5 around it, so you draw 4 new pieces, not 5. It keeps its flip.'],
         ['<b>Plenty</b>', 'Heal, Hurt', 'When you place it: next round your hand is 6 pieces (5 if you were tripped). One round only. Two in one round still give 6.'],
         ['<b>Simmer</b>', 'Heal', 'When you place it: you heal 2 as each of your next 2 turns starts (less if nearly full). A second Simmer sets the count back to 2; it does not add.'],
         ['<b>Pierce</b>', 'Hurt', 'Ignores the creature\'s guard.'],
         ['<b>Poison</b>', 'Hurt', 'Hits the bar again on each of the creature\'s next 2 turns (see below).'],
         ['<b>Trip</b>', 'Hurt', 'The creature skips its next turn: this very round it places nothing.'],
         ['<b>Bash</b>', 'Hurt', 'Adds the guard you hold right now to the hit, and uses that guard up.'],
         ['<b>Quick</b>', 'Hurt', 'No extra effect for you (one piece a turn).'],
         ['<b>Heavy</b>', 'Hurt', 'Nothing extra. It is just a bigger number.'],
         ['<b>Hold</b>', 'Guard', 'What is left of this guard after the creature\'s turn stays up one more turn.'],
         ['<b>Thorns</b>', 'Guard', 'While it is up, each hit it blocks adds 2 to the bar.'],
         ['<b>Evade</b>', 'Guard', 'The creature\'s next Hurt misses completely. If still unused at the end of the round, it also stops a poison tick on you.'],
         ['<b>Mend</b>', 'Guard', 'Also heals you 2.'],
         ['<b>Hum</b>', 'Charm', 'Also soothes 2: its hits this round do 2 less in all.'],
         ['<b>Lull</b>', 'Charm', 'The creature skips its next turn, like Trip.'],
         ['<b>Bond</b>', 'Charm', 'Your Charm counts 10% more for the rest of the fight, up to 3 times, never above x1. No use against a gentle creature.'],
         ['<b>Pluck</b>', 'Trick', 'Once a fight, when you place it: a small chance (8% + 3% per Luck step, half against a boss) to lift an item the creature could drop.']], cls=''))
w(box('Keeper, Plenty and Simmer in practice', ul(
    'They work <b>only when you place the piece</b>. If a later chain fires it again, its number fires but the tag does nothing.',
    '<b>Keeper</b> is the only way to plan ahead. Keep the Guard for the round the aim is big, or for a Riposte. But a kept piece costs you one new piece each round.',
    '<b>Plenty</b> pays next round. Place it when this round\'s best move is small anyway.',
    '<b>Simmer</b> is worth up to 4 health on top of its heal, but only if you are hurt when your turns start.')))
w(h3('Poison'))
w(table(['', 'Your poison on the creature', 'The creature\'s poison on you'],
        [['Size of a tick', 'Half the piece\'s printed number, rounded up (x0.8 on a gentle creature).', 'A third of the printed number for a Hurt, half for a Trick. At least 1.'],
         ['Combos or Sun', 'Do not raise it.', 'Do not raise it.'],
         ['When it ticks', 'As each of the creature\'s next 2 turns starts, also on a turn it skips.', 'At the end of the round, after the environment\'s piece.'],
         ['Stacking', 'A new Poison sets the count back to 2 and keeps the larger tick.', 'Each poison adds 2 ticks; at most 3 wait.'],
         ['What stops it', 'Nothing. A Hurt that misses still sets the poison.', 'Not guard. Your Evade does, if still unused when the round ends.']]))
w(h3('Built-in knacks'))
w('<p>Some legendary crop pieces carry a knack: a second small effect that is part of the piece.</p>')
w(table(['Knack', 'On', 'What it does'],
        [['Tender', 'Heal, Item', '+2 to the heal.'],
         ['Leech', 'Hurt', 'Heals you 1 plus a sixth of the hit, if any of it got past the guard.'],
         ['Spiky', 'Guard', '+2 hurt on the bar each time it fires for you. The creature\'s guard does not soak it.'],
         ['Soft touch', 'Charm, Heal, Item', 'Also soothes 2.'],
         ['Warm', 'Hurt', 'A quarter of the damage also counts as charm (times the charm factor).'],
         ['Finisher', 'Hurt', '+3 once the <b>hurt</b> part alone is at 60% of the bar or more. Charm does not count.'],
         ['Hardy', 'Guard', '+2 guard.']]))

# ================================================================ 5
w(ch('5', 'Combos and chains', 'the heart of the game'))
w(h3('Combos'))
w('<p>A combo is a bonus when the chain runs from one of your pieces straight into another of yours along a link. The bonus lands on the second piece.</p>')
w(table(['Name', 'From', 'Into', 'Bonus on the second piece'],
        [['Ambush', 'Trick', 'Hurt', 'x1.5, plus the Trick\'s number'],
         ['Riposte', 'Guard', 'Hurt', 'x1.5'],
         ['Double Swing', 'Hurt', 'Hurt', '+2'],
         ['Bait', 'Trick', 'Guard', 'plus the Trick\'s number'],
         ['Calm Charm', 'Soothe', 'Charm', 'x1.5'],
         ['Win Over', 'Charm', 'Item', 'half the Item\'s number is also added as charm']]))
w(box('The rule that decides most turns', '<p>The chain starts at the piece you <b>place</b> and runs outward. So <b>place the first piece of the pair next to the second</b>, which is already on the board. To get Ambush, place the Trick next to a Hurt. To get Riposte, place the Guard next to a Hurt. Placing the Hurt next to the Trick gives no combo at all.</p>'
    '<p>A piece reached through the Blank or through an environment piece has no combo partner. The creature gets the same combos from its own pieces.</p>'))
w(h3('How a chain fires'))
w(ol('<b>Build the chain.</b> Start at the piece just placed. Add every piece linked to it, newest first, and from each of those follow its own links. A piece is in a chain once.',
     '<b>Fire in rank order</b> (new in 2.7.00). Inside one rank, the build order holds.'))
w(table(['1st', '2nd', '3rd', '4th', '5th'], [['Environment pieces', 'Guard, Soothe', 'Trick', 'Hurt, Charm', 'Heal, Item']]))
w(ul('Combos still follow the build order: a piece\'s partner is the piece the chain came from, not the piece that fired just before it.',
     'Each piece fires for its <b>owner</b>: yours for you, the creature\'s for the creature.',
     'An environment piece fires for the side that <b>started</b> the chain.',
     'If the fight ends in the middle of a chain, the rest does not fire.',
     'The same rules hold for the creature\'s chain.'))
w(fig(fig_chain_rank(), 'Figure 4. Rank order and a chain of 3.', 'big'))
w(h3('The chain of 3 rule (use-up)'))
w(ul('A chain that fires <b>3 or more</b> pieces uses up every piece that fired. They leave the board at once.',
     'It does not matter who started the chain or who owns the pieces. Environment pieces count and are used up too.',
     'A chain of 1 or 2 uses nothing up. Those pieces stay and can fire again.'))
w(h3('The other side\'s pieces in your chain'))
w(ul('A creature Hurt in your chain hits <b>you</b>. A creature Guard gives it guard against your later Hurts. A creature Heal empties the bar. Its tags work for it.',
     'But it also spends one of that piece\'s two firings. Firing a harmless creature piece is a cheap way to remove it.',
     '<b>Bait:</b> the creature\'s aim is fixed before you move. Put a piece of yours with a fitting edge next to the aim cell, and the creature\'s chain will fire it, for <b>you</b>, with your combos. The aim chip shows it ("fires your Pierce"). It fails if the creature has Evade up: your Hurt misses.'))

# ================================================================ 6
w(ch('6', 'The opening', 'round 1'))
w(fig(fig_start(), 'Figure 5. The board at the start.', 'big'))
w(ol('The Blank sits on a random one of the four middle cells.',
     'You get your first hand of 5. Pick one piece and one side of the Blank.',
     'The creature puts its gentlest piece that is not a Hurt on a random side. If you chose the same side, yours stays and its piece moves to the next free side. A boss puts out two pieces.',
     'Nothing fires. Turn 1 begins with your other 4 pieces in hand.'))
w(box('Start with a Hurt', '<p>Put a Hurt out. On turn 1 you can then place a Trick or a Guard next to it for a combo. Before you confirm, find that partner in your hand and leave its cell free. The aim mark shown during the start pick is a placeholder: read the real aim once both start pieces are down.</p>'))

# ================================================================ 7
w(ch('7', 'The creature\'s turn', 'what it does and how to read the aim'))
w(h3('In order'))
w(ol('Its old guard and Evade drop (unless a Hold piece keeps the guard).',
     'Your poison on it ticks. If that fills the bar, you win before it acts.',
     'It plays its aim: the piece and the cell it showed you. If it cannot, it picks its best move now. If it is slowed (Trip, Lull), it plays nothing.',
     'Its chain fires, by the same rules as yours.',
     'Extras: one more piece after a Quick piece, a Water creature\'s push, a Plant\'s Bramble.',
     'The environment places one piece.',
     'Poison on you ticks, unless your Evade is still up. Then Simmer heals you. A trip takes effect.',
     'Old pieces leave (3 rounds). Venom cells fade.',
     'You draw a new hand (Keepers stay; 4 if tripped, 6 after Plenty). Your guard fades, except what Hold keeps.',
     'The new aim is shown. The creature gets <b>no free piece</b> in new fights.'))
w(h3('The aim'))
w(ul('The red mark is the cell. The chip names the piece and what its whole turn would do right now: "Peck: hits you for 9". It includes combos, Sun, Swarm, your guard, your pieces it fires and a Quick piece\'s second piece.',
     'It does <b>not</b> include poison ticks on you or a Reptile\'s venom.',
     '"· fires Sun" or "· fires Bramble": its chain would fire that environment piece. A ring marks it on the board.',
     'The aim is a promise: the piece lands on that cell even if the cell now touches nothing.'))
w(table(['You do this', 'The creature does'],
        [['Put a piece on the aim cell', 'Picks again: its best move as the board is now, at full strength. Your piece is not harmed.'],
         ['Put a piece next to the aim cell with an edge that does not fit the aimed piece', 'Picks again. The chip reads "broken".'],
         ['Play Trip or Lull', 'Loses its turn. The chip reads "is slowed: no move".']]))
w(h3('The creature\'s pieces'))
w(ul('It holds 3 pieces (a boss 4) and plays one a turn. It must make a link if any piece can.',
     'Every creature piece falls off after it has fired twice ("plays x2").',
     'Its deck: 4 class pieces, 1 region piece (2 for large and boss), a size extra (large: Slam; boss: Scheme and Crush) and 3 pieces of its own. Tap a piece on the card to read it.'))
w(table(['Its tag', 'What it does to you'],
        [['Quick', 'It plays one more piece this turn.'], ['Pierce', 'Ignores your guard.'],
         ['Poison', '2 ticks on your health (see chapter 4). At most 3 wait.'], ['Trip', 'You draw 4 pieces next round instead of 5.'],
         ['Bash', 'Adds its guard to the hit. A Trick with Bash lends its guard to its next Hurt.'],
         ['Evade', 'Your next Hurt misses ("dodges next hit"). It lasts until its next turn starts.'],
         ['Thorns', 'While its guard is up, each of your hits it soaks pricks you (2, or 4% of your health if more).'],
         ['Hold', 'Its guard lasts a turn longer.'], ['Heal', 'Empties the bar by its number: hurt part first, then charm.']]))

# ================================================================ 8
w(ch('8', 'Creature classes', 'one extra rule each'))
w('<p>Every creature has one rule from its class, shown on its card and as a chip. A boss has the boss rule instead.</p>')
w(table(['Class', 'Rule', 'What to do'],
        [['<b>Critter</b><br>Swarm', 'When its Hurt fires, count its <i>other</i> pieces on the board: 2 or 3 give +1, 4 or more give +2. Every piece counts. Also when its Hurt fires in your chain. Its Trick Skitter is Quick.', 'Count its pieces before you read the aim. Chains of 3 through its pieces shrink it. Gentle Critters take Charm at full value.'],
         ['<b>Bird</b><br>Two aims', 'It shows two cells. Take the first and it plays the second; take both and it picks again. Its Trick Flutter Off gives it Evade.', 'Taking a cell rarely saves you. Use Guard, or a misfit next to the aim. When it "dodges next hit", play Guard, Heal or Charm.'],
         ['<b>Beast</b><br>Grudge', 'Each time a piece of yours stands on its aim cell, its Hurt hits 25% harder (up to 3 times). Losing health on its turn clears it. A misfit beside the cell adds no Grudge.', 'Let small hits land. Block only big ones, and prefer a misfit.'],
         ['<b>Water</b><br>Current', 'After its piece lands, one of your pieces touching it slides one cell away, if that cell is free. Its Trick Undertow trips you.', 'Do not count on a link next to its aim lasting. A piece with something behind it cannot be pushed.'],
         ['<b>Plant, Fungus</b><br>Grows', 'After its turn it grows a Bramble beside its piece (one at a time). Whoever chains the Bramble fires it. Its guard has Thorns; Sap Mend heals it.', 'Fire its Bramble yourself first: a tenth of the bar for you. Hit its guard with Pierce or Charm.'],
         ['<b>Reptile, Amphibian</b><br>Venom trail', 'Where its piece leaves the board, the cell is venom for 2 turns. A piece of yours placed there poisons you (2 a round, 2 rounds). Its Trick Venom Spit poisons.', 'Check the cell for the venom mark: the lit number does not show it. Finish fast.'],
         ['<b>Boss</b><br>Two turns', 'It also shows the piece it will play next round. That piece is forced; its cell is chosen then. Starts with 2 pieces, holds 4, plays set-up, Hurt, Hurt in turn.', 'Time your guard for its big piece. Do not block out of habit. Keep Rain away from it. No charm win, no running, 24 turns.']], cls=''))

# ================================================================ 9
w(ch('9', 'The environment', 'the third player'))
w(ul('After the creature\'s turn the environment places one piece. Its next piece is shown in the <b>NEXT</b> strip: you know what is coming, not where.',
     'It goes on an empty cell with nothing on any side, among the three such cells farthest from all pieces. If none exists it takes a cell where it fits. With 12 or more cells taken it places nothing.',
     'Its pieces belong to nobody. Link one into your chain and it fires for you. The creature can do the same.',
     'They count for chain length and are used up by a chain of 3. Otherwise they stay 3 of your turns.'))
w(fig(figs.fig_env(), 'Figure 6. The four environment pieces. Each has all three families on its edges.'))
w(table(['Piece', 'Your chain fires it', 'Its chain fires it', 'Tip'],
        [['<b>Sun</b>', 'Every piece of yours in that chain counts double: hurt, charm, guard, healing.', 'Every piece of its counts double.', 'Bring your biggest chain to it. If its aim touches a Sun, fire the Sun first or take the cell.'],
         ['<b>Bramble</b>', 'A tenth of the bar is added.', 'You lose a tenth of your max health. Guard does not help.', 'Fire it in a chain of 2: it stays for another go.'],
         ['<b>Rain</b>', 'You get guard worth 15% of your max health.', 'It gets guard worth 15% of its Yield bar.', 'Do not leave it to a big creature: its guard is huge.'],
         ['<b>Thornburst</b>', 'You lose a tenth of your max health.', '5% of the bar is added.', 'Stay off cells that touch it: any touching piece links to it.']]))
w(table(['Creature size', 'Sun', 'Bramble', 'Rain', 'Thornburst'],
        [['small', '2', '1', '2', '1'], ['medium, large', '2', '2', '2', '2'], ['boss', '2', '3', '2', '2']], num=(1, 2, 3, 4)))
w('<p class="small">The region adds one more of one kind. The deck is reshuffled when it runs out.</p>')

# ================================================================ 10
w(ch('10', 'Winning: hurt or charm', 'and what carries over'))
w(table(['', 'Hurt route', 'Charm route'],
        [['Counts', 'Fully; x0.8 on a gentle creature.', 'x0.6 on a wary creature or boss; fully on a gentle one. Bond raises it.'],
         ['Stopped by', 'Its guard (Pierce gets through), its Evade, its heal.', 'Only its heal. Guard and Evade do not touch charm.'],
         ['Also counts as this', 'Combos, Sun, Bramble, Thornburst, poison.', 'Warm (a quarter of the hit).'],
         ['Ending', '"Backs off": full XP and normal drops.', '"Won over" if charm is the larger share: full XP, a gift, its seed or guide drops.']]))
w(box('Which route?', '<p>Play Charm when the creature is gentle, when its guard is high, or when it dodges your next hit. Above small size a charm win is rare: Bramble, Thornburst and poison all count as hurt. Do not plan one unless your deck is built for it. Against a boss, Charm still fills the bar at x0.6 and ignores its guard.</p>'))
w(h3('Health carries over'))
w(ul('You start with your expedition\'s health and leave with what is left. A fight won at 20% health makes the next fight on the trip much harder.',
     'Heal and Item pieces, Mend, Simmer, Leech and a Rest outside the fight bring it back.',
     'After the fight a result card shows. "Collect the reward" ends it. Tool wear is saved however the fight ended.'))

# ================================================================ 11
w(ch('11', 'Building your deck', 'the Puzzle box, belt, pals and slots'))
w(ul('Your deck is built in the <b>Puzzle box</b>. It has three tabs: Kit, Belt, Pals. The deck is locked once the fight starts.',
     'The first time, you pack a starter: 4 fixed pieces (Swing, Dodge, Rest, Charm) plus 6 of 12 offered pieces. Or tap a ready kit:'))
w(table(['Kit', 'The 6 pieces'],
        [['Bold (default)', 'your calling piece, Jab, a second Swing, Pierce, Snack, Oat Cake'],
         ['Steady', 'calling piece, Jab, second Swing, Pierce, Brace, your home region\'s piece'],
         ['Kind', 'calling piece, Jab, second Swing, Pierce, Hum, Soothe']]))
w(ul('Later you switch on more pieces you own: knacks, crop pieces, legendary crop pieces, craft pieces, region pieces. Filter buttons: All, basic, crop, a crown for legendary pieces, craft, region, wearables.',
     'A piece you have just earned arrives switched <b>off</b>, with a <b>NEW</b> mark, until you switch it once.',
     '<b>Limits:</b> at least 8 kit pieces; at least 1 Hurt (3 in a custom starter); at most 3 Rare and 1 Masterwork; the slots below. No maximum size. If the deck is not legal, the fight plays the default kit instead.',
     'The deck bar shows "Hurt pieces: N of M" and warns under 3 in 10: "Few Hurt pieces: fights will be long".'))
w(h3('Belt and pals'))
w(ul('Each tool on your fight belt adds its one piece (axe: Chop; tilling tool: Hoe Hook; staff: Sweep; lantern: Glare...).',
     'Belt slots: 2 for every gnome, 3 with the Stitched Fight Belt (level 8), 4 with the Masterwork Fight Belt (level 18).',
     'A tool has 20 durability plus 4 per rank. Each play of its piece costs 2. A broken tool gives no piece: fix it with a Tool Repair Kit.',
     'Each pal in your party lends one piece (for example Bark Badger, a Guard).'))
w(h3('Slots: the Larder and the Keepsakes'))
w(table(['Slot', 'Holds', 'Count by gnome level'],
        [['<b>Larder</b>', 'Crop pieces and legendary crop pieces', '3 from level 1 · 4 from level 10 · 5 from level 20'],
         ['<b>Keepsakes</b>', 'Wearables (chapter 12)', '1 from level 1 · 2 from level 15 · 3 from level 25 · 4 from level 40']]))
w(ul('Each switched-on piece of that kind takes one slot. A crop piece in your starter counts too: the Bold kit\'s Oat Cake takes a Larder slot.',
     'Switching on one too many is refused ("Your Larder holds 3 crop pieces. Take one out first."). A piece over the count stays out of the deck: "left out".',
     'Tool, pal, region, craft and knack pieces need no slot.'))
w(h3('Legendary crop pieces'))
w(ul('There are 42, one for each treasure crop. Harvest that crop 3 times and the piece is yours for good.',
     'Its rank follows your food mastery of that crop, Common to Masterwork. Rare and Masterwork count toward the deck caps.',
     'It needs a Larder slot. Its top and bottom edges are mind, like a crop piece.',
     'They carry the only Keeper, Plenty and Simmer tags, and some carry a knack.',
     'Legendary <b>Heal</b> pieces have mind edges on three sides: they only go beside mind knobs (always beside the Blank in round 1).',
     'The three legendary Item pieces are not Snacks: they eat nothing and are never refused.'))

# ================================================================ 12
w(ch('12', 'Wearables and the Tailor', 'new in 2.7.00'))
w('<p>A wearable is something your gnome wears, and it is also one puzzle piece. It is a <b>Keepsake</b> piece: it needs a Keepsake slot and is off until you switch it on. Wearables exist only where puzzle combat v1 is switched on.</p>')
w(table(['Wearable', 'Cut (piece)', 'Type', 'Base', 'Tag', 'How you get it'],
        [['Flood Boots', 'Puddle Hop<br>Sure Foot', 'Guard<br>Guard', '3<br>3', 'Evade<br>Hold', 'Tailor (craft)'],
         ['Wayfarer\'s Hat', 'Brim Down<br>Tip Back', 'Guard<br>Soothe', '2<br>3', 'Thorns<br>none', 'Shop: level 5, 300 Petals'],
         ['Work Gloves', 'Firm Grip<br>Knuckle Down', 'Hurt<br>Hurt', '3<br>3', 'Leech knack<br>Bash', 'Tailor (craft)'],
         ['Travel Cloak', 'Wrap Up<br>Hood Up', 'Guard<br>Guard', '3<br>3', 'Mend<br>Thorns', 'Tailor (craft)'],
         ['Trail Pack', 'Rummage<br>Tidy Up', 'Trick<br>Trick', '2<br>2', 'Pluck<br>none', 'Shop: level 15, 800 Petals'],
         ['Yarn Scarf', 'Yarn Wrap', 'Charm', '3', 'none', 'Cat Fish']], num=(3,)))
w(h3('Cuts and ranks'))
w(ul('Each cut is its own piece. Two copies of the same cut are one piece; the two cuts of one wearable are two pieces.',
     'Ranks: <b>Common</b>, <b>Lined</b> (+2), <b>Fine</b> (+4). If you own two ranks of a cut, the best one is the piece.',
     'A Fine piece counts as a <b>Rare</b> piece (the deck holds at most 3). You may choose to wear a Fine piece as Lined: then it is not Rare, and a little weaker.',
     'Changing rank does not change the piece\'s on/off switch.'))
w(h3('The Tailor'))
w(ul('The Tailor is a garden building (garden level 6, 1800 Petals). You need one in at least one garden to craft Flood Boots, Work Gloves and a Travel Cloak, to line a wearable, and to re-cut one.',
     '<b>Lining</b> (Common to Lined, then Lined to Fine) is a chance: 30%, plus 8% for each Tailor power point, up to 78%. Power is the sum of the levels of all your Tailors (each counts at most 3). Only the first 6 points help; points above 6 earn you commission Petals instead.',
     'A failed lining gives a <b>Tailor\'s Thread</b>. 5 Threads make the next lining a sure thing.',
     '<b>Re-cutting</b> to the other cut costs 1 Thread (free with a level 2 Tailor).',
     'A level 3 Tailor makes your first wearable craft of the day for free.'))

# ================================================================ 13
w(ch('13', 'Tips', 'how to choose a move'))
w(ol('<b>Can I win now?</b> If a cell ends the fight, take it. Nothing else matters.',
     '<b>Read the cost on the lit cell.</b> Your chain can reach a creature Hurt (it hits you) or a Thornburst. The biggest number is often a trap. Poison is not in the aim number: against Reptiles, finish fast.',
     '<b>Free guard first.</b> A Guard placed next to a Hurt both blocks and attacks (Riposte). Firing a Rain gives guard on top of your move.',
     '<b>Mind its guard and Evade.</b> With a big "its guard" up, play Pierce or Charm. With "dodges next hit" up, lead with a weak Hurt or play another type.',
     '<b>Take the chain of 3</b> when it adds clearly more, uses pieces in their last round, removes a dangerous creature piece, uses up a Sun or Rain before the creature fires it, or ends the fight. Keep a Bramble chain at 2 so it stays.',
     '<b>Do not block for its own sake.</b> Taking the aim cell makes it pick again at full strength. Block only big aims (Sun, combo, Bramble).',
     '<b>Use bait.</b> A fitting piece next to the aim cell is fired for you in its turn.',
     '<b>Trip and Lull</b> cost the creature a whole turn, and your poison still ticks.'))

# ================================================================ cheat sheet
w('<div class="cheat">')
w(ch('14', 'Cheat sheet', 'one page', pb=True))
w('<div class="cols">')
CS = [
    ('Goal', ['Fill the Yield bar. Hurt and Charm both fill it. Its heal empties it (hurt first).', 'Keep your health above 0. It carries over to the next fight.']),
    ('A round', ['You: one piece (or pass). Flip is free.', 'Creature: its aim, its chain, class extras.', 'Environment: one piece on a lonely cell.', 'Clean-up: poison, Simmer, old pieces leave, new hand of 5.']),
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
    out = ['<div class="toc2">']
    for hid, num, title, sub in heads:
        pg = pages.get(hid, '')
        out.append(f'<div class="e"><span class="tn">{num}</span><span class="t">{title}<span class="s">{sub}</span></span><span class="dots"></span><span>{pg}</span></div>')
    out.append('</div>')
    return '<h2 style="margin-top:0;font-size:15pt">Contents</h2>' + ''.join(out)


def write(pages):
    body = '\n'.join(B).replace('<!--TOC-->', toc(pages))
    html = f'<!doctype html><html lang="en"><head><meta charset="utf-8"><title>Puzzle Combat quick rules</title><style>{CSS}</style></head><body>{body}</body></html>'
    open(OUT_HTML, 'w', encoding='utf-8').write(html)


def find_pages():
    n = int(re.search(r'Pages:\s+(\d+)', subprocess.run(['pdfinfo', OUT_PDF], capture_output=True, text=True).stdout).group(1))
    pages = {}
    for pg in range(2, n + 1):
        txt = subprocess.run(['pdftotext', '-f', str(pg), '-l', str(pg), '-layout', OUT_PDF, '-'], capture_output=True, text=True).stdout
        for hid, num, title, sub in heads:
            t = title.replace('&amp;', '&').replace("\\'", "'")
            if hid not in pages and re.search(r'^\s*' + re.escape(num) + r'\s+' + re.escape(t) + r'\s*$', txt, re.M):
                pages[hid] = pg
    return n, pages


if __name__ == '__main__':
    write({})
    if '--html' in sys.argv:
        sys.exit(0)
    subprocess.run(['node', os.path.join(HERE, 'render_short.js')], check=True)
    n, pages = find_pages()
    write(pages)
    subprocess.run(['node', os.path.join(HERE, 'render_short.js')], check=True)
    missing = [h[1] for h in heads if h[0] not in pages]
    print(n, 'pages; contents page numbers found for', len(pages), 'of', len(heads), 'chapters', ('; missing: ' + ', '.join(missing)) if missing else '')
