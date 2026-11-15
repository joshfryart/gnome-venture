#!/usr/bin/env python3
"""Builds puzzle-combat-rulebook.html (print CSS, A4). Usage: python3 build.py [pages.json]
pages.json (optional) maps heading ids to page numbers for the contents list; render.js writes it after a first pass."""
import json, os, sys, re
import figs

HERE = os.path.dirname(os.path.abspath(__file__))
pages = {}
if len(sys.argv) > 1 and os.path.exists(sys.argv[1]):
    pages = json.load(open(sys.argv[1]))

P = '<span class="v p" title="Seen in my own play on the real engine">played</span>'
C = '<span class="v c" title="Read in the code, not seen in play">code</span>'
Q = '<span class="v q" title="Could not verify">not verified</span>'

CSS = r"""
@page { size: A4; margin: 17mm 16mm 19mm 16mm; }
* { box-sizing: border-box; }
html { font-size: 11pt; }
body { font-family: Inter, "DejaVu Sans", Arial, sans-serif; color: #1d1d1b; line-height: 1.42; margin: 0; }
h1, h2, h3, h4 { font-family: "Bitstream Charter", Caladea, "DejaVu Serif", serif; color: #2b2a26; break-after: avoid; page-break-after: avoid; }
h2 { font-size: 20pt; margin: 0 0 8pt; padding-bottom: 4pt; border-bottom: 2pt solid #7a8f4e; break-before: page; page-break-before: always; }
h2 .n { color: #7a8f4e; margin-right: 8pt; }
h3 { font-size: 13.5pt; margin: 15pt 0 5pt; }
h3 .n, h4 .n { color: #7a8f4e; margin-right: 6pt; }
h4 { font-size: 11.5pt; margin: 11pt 0 3pt; }
p { margin: 0 0 6pt; orphans: 3; widows: 3; }
ul, ol { margin: 0 0 7pt; padding-left: 16pt; }
ol { padding-left: 22pt; }
h3.pb { break-before: page; page-break-before: always; margin-top: 0; }
li { margin-bottom: 2.5pt; }
table { border-collapse: collapse; width: 100%; margin: 6pt 0 10pt; font-size: 9.6pt; }
thead { display: table-header-group; }
tr { break-inside: avoid; page-break-inside: avoid; }
th { background: #e9eddc; text-align: left; font-weight: 700; }
th, td { border: 0.6pt solid #b9b6a8; padding: 3.2pt 5pt; vertical-align: top; }
table.keep { break-inside: avoid; page-break-inside: avoid; }
td.num, th.num { text-align: right; white-space: nowrap; }
.fig { break-inside: avoid; page-break-inside: avoid; margin: 8pt 0 10pt; text-align: center; }
.fig svg { max-width: 100%; height: auto; }
.fig .cap { font-size: 9pt; color: #555; margin-top: 2pt; }
.box { break-inside: avoid; page-break-inside: avoid; border: 0.8pt solid #7a8f4e; background: #f5f7ec; border-radius: 5pt; padding: 7pt 10pt 4pt; margin: 8pt 0 10pt; }
.box.warn { border-color: #b5651d; background: #fbf1e3; }
.box.ex { border-color: #6c7fa3; background: #eef2f9; }
.box h4 { margin-top: 0; }
.v { font-size: 7.4pt; font-weight: 700; border-radius: 3pt; padding: 0.5pt 3.5pt; white-space: nowrap; vertical-align: 1pt; letter-spacing: 0.2pt; text-transform: uppercase; }
.v.p { background: #dcebd0; color: #2f5d1c; }
.v.c { background: #e3e6f2; color: #34406b; }
.v.q { background: #f6dcd2; color: #8a2d12; }
code { font-family: "DejaVu Sans Mono", monospace; font-size: 8.6pt; background: #f1efe8; padding: 0 2pt; border-radius: 2pt; }
.cover { height: 250mm; display: flex; flex-direction: column; justify-content: center; text-align: center; break-after: page; page-break-after: always; }
.cover h1 { font-size: 40pt; margin: 0 0 4pt; }
.cover .sub { font-size: 16pt; color: #555; margin-bottom: 26pt; }
.cover .meta { font-size: 10.5pt; color: #444; line-height: 1.7; }
.cover .rule { width: 60mm; height: 3pt; background: #7a8f4e; margin: 16pt auto; }
.toc { break-after: page; page-break-after: always; }
.toc h2 { break-before: auto; page-break-before: auto; }
.toc ol { list-style: none; padding: 0; margin: 0; column-count: 2; column-gap: 10mm; font-size: 8.6pt; line-height: 1.28; }
.toc li { display: flex; align-items: baseline; margin: 0; padding: 1.2pt 0; }
.toc li.l1 { font-weight: 700; margin-top: 3.6pt; }
.toc li.l2 { padding-left: 10pt; font-size: 8pt; padding-top: 0.5pt; padding-bottom: 0.5pt; }
.toc li { break-inside: avoid; }
.toc .dots { flex: 1; border-bottom: 0.6pt dotted #999; margin: 0 5pt; transform: translateY(-2.5pt); }
.toc .tn { color: #7a8f4e; width: 24pt; display: inline-block; }
.small { font-size: 9.3pt; color: #444; }
.cheat h2 { margin-bottom: 4pt; }
.cheat { font-size: 9pt; line-height: 1.32; }
.cheat .cols { column-count: 2; column-gap: 9mm; }
.cheat h4 { margin: 7pt 0 2pt; font-size: 10.5pt; color: #4e6124; }
.cheat ul { margin-bottom: 3pt; padding-left: 12pt; }
.cheat li { margin-bottom: 1pt; }
.cheat .blk { break-inside: avoid; }
.turn { font-size: 9.4pt; }
.turn td:first-child { white-space: nowrap; font-weight: 700; }
.st { font-size: 7.6pt; font-weight: 700; border-radius: 3pt; padding: 0.8pt 4.5pt; white-space: nowrap; vertical-align: 2pt; letter-spacing: 0.3pt; text-transform: uppercase; margin-left: 4pt; font-family: Inter, "DejaVu Sans", Arial, sans-serif; }
.st.ok { background: #2f5d1c; color: #fff; }
.st.ch { background: #b5651d; color: #fff; }
.st.op { background: #8a2d12; color: #fff; }
.st.nw { background: #34406b; color: #fff; }
table.leg { font-size: 8.6pt; }
table.leg td, table.leg th { padding: 2.2pt 4pt; }
"""

heads = []   # (level, id, number, title)


def h2(num, title):
    hid = 's' + num.replace('.', '_')
    heads.append((1, hid, num, title))
    return f'<h2 id="{hid}"><span class="n">{num}</span> {title}</h2>'


def h3(num, title, badge=''):
    """badge: a state label shown after the title (chapter 10); it is not part of the contents entry."""
    hid = 's' + num.replace('.', '_')
    heads.append((2, hid, num, title))
    pb = ' class="pb"' if num in ('A.2', 'A.3', 'A.4', 'A.5') else ''
    return f'<h3 id="{hid}"{pb}><span class="n">{num}</span> {title}{badge}</h3>'


def h4(num, title):
    return f'<h4><span class="n">{num}</span>{title}</h4>'


def fig(svg, cap):
    return f'<div class="fig">{svg}<div class="cap">{cap}</div></div>'


B = []
w = B.append

# ------------------------------------------------------------------ 1
w(h2('1', 'What you are doing'))
w(f"""
<p>Puzzle combat is a small board game inside Gnome Venture. You meet a creature. You both put jigsaw pieces on a 4 by 4 board. Pieces that link fire together as a chain. This book describes the rules as they are in a <b>new fight today</b> (version 2.7.00, puzzle combat v1, still switched on for admins only: setting <code>pfight_v1</code> Off / Admins only). Fights already saved keep the rules they started with (<code>PFB_V1_PRE</code>).</p>
{h3('1.1', 'The goal')}
<p>Fill the creature's <b>Yield bar</b> before your <b>health</b> reaches 0. That is the whole game. {P}</p>
{h3('1.2', 'The Yield bar')}
<ul>
<li>The creature has one bar. It starts empty, for example <b>Yield 0/43</b>.</li>
<li>Your <b>Hurt</b> pieces fill it. Your <b>Charm</b> pieces fill the same bar. {P}</li>
<li>When it is full the creature yields and you win.</li>
<li>The label counts both parts: "Yield 23/40: hurt 15, charm 8". {C}</li>
<li>The bar can go <b>down</b>: a creature's heal empties it, the hurt part first, then the charm part (new in 2.6.989). {C}</li>
</ul>
<p>How much a piece adds is not always its number:</p>
<table class="keep">
<thead><tr><th>Creature</th><th>Hurt 10 adds</th><th>Charm 10 adds</th><th>How you know</th></tr></thead>
<tbody>
<tr><td>Wary (most creatures)</td><td class="num">10</td><td class="num">6</td><td>The creature card says "wary".</td></tr>
<tr><td>Gentle</td><td class="num">8</td><td class="num">10</td><td>The card says "gentle".</td></tr>
<tr><td>Boss (a great creature)</td><td class="num">10</td><td class="num">6</td><td>The card says "cannot be charmed". Charm still fills the bar.</td></tr>
</tbody></table>
<p class="small">Code: <code>PF_GENTLE_HM</code> 0.8, <code>PF_HOSTILE_CM</code> 0.6 in <code>pfight.php</code>. Seen in play: Charm 5 added 3 against the Pincer Earwig (wary); Lull 14 beside a Sun added 16.8 against the Great Hawk (boss). {P} The gentle row is from the code. {C}</p>
<p>The bar is longer for bigger and higher creatures. From my fights, with a gnome of the creature's level:</p>
<table class="keep">
<thead><tr><th>Creature</th><th>Size, level</th><th class="num">Yield bar</th><th class="num">Your health</th><th class="num">A typical Hurt of yours</th><th class="num">A typical hit of its</th></tr></thead>
<tbody>
<tr><td>Pincer Earwig</td><td>small, 4</td><td class="num">42.8</td><td class="num">32</td><td class="num">3 to 5</td><td class="num">4 to 5 (+1 or +2, Swarm)</td></tr>
<tr><td>Carrion Crow</td><td>medium, 9</td><td class="num">74.6</td><td class="num">47</td><td class="num">5 to 8</td><td class="num">3 to 4</td></tr>
<tr><td>Wild Boar</td><td>large, 21</td><td class="num">171.8</td><td class="num">88</td><td class="num">10 to 16</td><td class="num">6 to 7</td></tr>
<tr><td>Great Hawk</td><td>boss, 28</td><td class="num">215.2</td><td class="num">114</td><td class="num">13 to 19</td><td class="num">8 to 10</td></tr>
</tbody></table>
<p class="small">All four rows were dealt again on 2.6.990. {P} The gnome here is the test gnome of <code>tests/pf_play.php</code> (health 20 + 3 per level, plus 5 per stat step). Your own gnome may differ. {Q} Since 2.6.988 a Critter's pieces are no longer x0.6: the Earwig's Nip is 5 (it was 3).</p>
{h3('1.3', 'Your health')}
<ul>
<li>Your health is the health of your expedition. You bring it into the fight and you take what is left out of it. {C}</li>
<li>The creature's Hurt pieces lower it. So do Bramble, Thornburst and poison.</li>
<li><b>Guard</b> blocks the creature's Hurt pieces. Guard does not block Bramble {P}, Thornburst or poison {C}.</li>
<li>At 0 you are knocked out and the fight is lost.</li>
</ul>
{h3('1.4', 'One round')}
""")
w(fig(figs.fig_round(), 'Figure 1. A round. You act once, then you watch.'))
w(f"""
<ul>
<li>You do <b>one action</b>: place one piece, or pass. Flipping a piece is free and is not an action.</li>
<li>Then the creature plays. Then the environment places one piece. Then old pieces leave and you draw a new hand.</li>
<li>Your hand is thrown away and redrawn every round. You cannot save a piece for later, with one exception: a piece with the <b>Keeper</b> tag stays in your hand (new in 2.6.990, see 2.9). {P}</li>
</ul>
{h3('1.5', 'How a fight can end')}
<table class="keep">
<thead><tr><th>Ending</th><th>When</th><th>What you get</th></tr></thead>
<tbody>
<tr><td><b>It backs off</b> (seen off)</td><td>The bar is full and charm is not the larger share. Always, for a boss.</td><td>Full XP and its normal drops. {C}</td></tr>
<tr><td><b>It is won over</b> (charmed)</td><td>The bar is full and charm is the larger share (more charm than hurt; a tie backs off). Not possible for a boss.</td><td>Full XP, a gift, and its seed or guide drops. {C}</td></tr>
<tr><td><b>You are knocked out</b></td><td>Your health is 0.</td><td>Nothing. You wake where you set out, with half your health. {C}</td></tr>
<tr><td><b>You run</b></td><td>You press Run. Not allowed against a boss.</td><td>Nothing won, nothing lost. {C}</td></tr>
<tr><td><b>It wanders off</b></td><td>24 turns pass. Against a boss this counts as a knock-out.</td><td>Nothing. {C}</td></tr>
</tbody></table>
<p class="small">If one chain both fills the bar and takes your last health, you win: the bar is checked first (<code>pf_check_end</code>). {C} All four of my hand-played fights ended "backs off". {P}</p>
{h3('1.6', 'What is new since the 2.6.986 edition')}
<table class="keep">
<thead><tr><th>Version</th><th>Change</th><th>Where in this book</th></tr></thead>
<tbody>
<tr><td>2.6.987</td><td>The aim number covers the creature's whole turn (a Quick piece's extra piece is in it). "Stays N rounds" reads 3 everywhere. The help sheet no longer explains the switched-off aim strike. Quick's text for your pieces says it has no extra effect.</td><td>6.2, 2.7, 2.5, 10.1 to 10.4</td></tr>
<tr><td>2.6.988</td><td>Swarm is a new rule: a Critter plays one piece a turn at full value, and its Hurt grows with the pieces it has out. Poison ticks are flat. Your Evade stops a poison tick.</td><td>6.5.1, 2.10, 6.4</td></tr>
<tr><td>2.6.989</td><td>A creature's heal empties the Yield bar, hurt first, then charm. New pieces arrive switched off with a NEW mark. Crop pieces need a Larder slot. Venom cannot push poison above 3 ticks.</td><td>2.2, 3.6, 6.5.6</td></tr>
<tr><td>2.6.990</td><td>Three new tags: Keeper, Plenty, Simmer. 42 legendary crop pieces, some with a built-in knack. A crown filter in the Puzzle box.</td><td>2.9, 2.11, 3.7, appendix C</td></tr>
<tr><td>2.7.00</td><td>A chain fires in a new order: environment, guard, tricks, hurt and charm, healing. The creature no longer gets a free piece at the end of your turn. Six wearables, made at a new Tailor, are Keepsake pieces. Keepsake slots 1 to 4.</td><td>5.4, 6.1, 3.6, 3.8</td></tr>
</tbody></table>
<p class="small"><b>About the 2.7.00 edition.</b> The rules in these three places were read in the code on 2.7.00 {C}. I did not play new fights or re-run the 684 policy fights. Every figure marked {P} and every table of runs is from 2.6.990, and the fights in appendix B were played in the old chain order and with the free piece. Read them as examples of the board, not as 2.7.00 results. The rules in chapters 5.4, 6.1, 3.6 and 3.8 override them. Saved fights keep the old rules (no new order, free piece on).</p>
""")

# ------------------------------------------------------------------ 2
w(h2('2', 'The pieces'))
w(f"""
{h3('2.1', 'What is on a piece')}
<p>Every piece has a <b>name</b>, a <b>type</b>, a <b>number</b>, four <b>edges</b> and sometimes a <b>tag</b>. A legendary crop piece can also carry a built-in <b>knack</b> (2.11).</p>
""")
w(fig(figs.fig_anatomy(), 'Figure 2. Swing, the basic Hurt piece, and the three edge families.'))
w(f"""
{h3('2.2', 'The seven types')}
<table class="keep">
<thead><tr><th>Type</th><th>What its number does when it fires for you</th><th>Notes</th></tr></thead>
<tbody>
<tr><td><b>Hurt</b></td><td>Adds that much hurt to the Yield bar.</td><td>The creature's guard soaks it first. Its Evade makes one Hurt miss. {P}</td></tr>
<tr><td><b>Charm</b></td><td>Adds that much charm to the Yield bar (x0.6 on a wary creature or a boss).</td><td>Guard and Evade do not touch charm. {P} A creature's heal can: it empties the charm part once the hurt part is gone. {C}</td></tr>
<tr><td><b>Guard</b></td><td>Blocks that much damage until your next turn starts.</td><td>It stays up through the creature's turn, then fades. {P}</td></tr>
<tr><td><b>Heal</b></td><td>Heals you that much.</td><td>Never above your maximum. {P}</td></tr>
<tr><td><b>Item</b> (Snack)</td><td>Heals you that much.</td><td>Snack eats a real snack from your satchel. It is refused at full health and after the fight's snack limit. {C} The three legendary Item pieces have no Snack tag: they eat nothing and are never refused (10.20). {C}</td></tr>
<tr><td><b>Soothe</b></td><td>The creature's next hits this round do that much less in all.</td><td>The pool is gone after the creature's turn. {C}</td></tr>
<tr><td><b>Trick</b></td><td>Nothing by itself. It boosts a Hurt or Guard of yours that fires right after it (see 2.6).</td><td>Seen: Slip Past 6, then Chop 5, gave 14. {P}</td></tr>
</tbody></table>
<p>When a piece fires <b>for the creature</b> the same types work the other way: its Hurt lowers your health, its Guard soaks your Hurt, its Heal empties the Yield bar (the hurt part first, then the charm part). Its Charm and Soothe pieces do nothing. {C}</p>
<p class="small">The heal rule is <code>pf_foe_heal</code> (<code>pfight.php</code> line 687). I ran it on a set-up position: hurt 3 and charm 10 on the bar, a heal of 5, left hurt 0 and charm 8 (<code>play/checks.php</code>). Before 2.6.989 a bar filled by Charm could not be emptied.</p>
{h3('2.3', 'Edges, fitting and linking')}
<ul>
<li>Each edge is a <b>knob</b> (solid, sticks out) or a <b>hole</b> (hollow, cut in).</li>
<li>Each knob and hole belongs to a <b>family</b>: body (round), mind (keyhole) or craft (triangle).</li>
<li>Two edges <b>fit</b> when one is a knob and the other a hole of the <b>same family</b>.</li>
<li>You may place a piece on an empty cell only if it <b>touches</b> at least one piece and <b>every</b> edge that touches a piece fits. {P}</li>
<li>A joint that fits is a <b>link</b>. Chains run along links.</li>
</ul>
""")
w(fig(figs.fig_fit(), 'Figure 3. Fitting. There is no "almost": a touching edge fits or the cell is closed to that piece.'))
w(f"""
<p>Two special edges exist:</p>
<ul>
<li><b>Wild</b>: fits anything. The Blank has four wild edges, but no chain runs through the Blank. A Plant's own Bramble also has wild edges, and it does link. {C}</li>
<li><b>Flat</b>: fits anything and never links. Today only Offer (flat right edge) has one. Mud, which is out of the game for now, is flat all round. {C}</li>
</ul>
<h4>How your pieces are cut</h4>
<p>You do not need to learn this by heart, the lit cells show where a piece goes. But the pattern helps you plan:</p>
<table class="keep">
<thead><tr><th>Edge</th><th>What it is</th><th>Example: Swing (Hurt)</th></tr></thead>
<tbody>
<tr><td>Left</td><td>A hole of the type's family. Hurt and Guard: body. Heal, Charm, Soothe: mind. Trick, Item: craft.</td><td>body hole</td></tr>
<tr><td>Right</td><td>A knob. Its family is printed per piece.</td><td>mind knob</td></tr>
<tr><td>Top, bottom</td><td>One knob and one hole of one family. Hurt, Charm and Trick have the knob on top. Guard, Heal, Soothe and Item have the hole on top.</td><td>body knob on top, body hole below</td></tr>
</tbody></table>
<p class="small">The top and bottom family follows where the piece comes from: tool and craft pieces craft, pal pieces body, crop pieces and legendary crop pieces mind, all others the family of their type (<code>PFB_SRC_FAM</code>, <code>pfb_author_edges</code>). Checked against every hand I was dealt, the legendary pieces included. {P}</p>
<p>What follows from it: a Hurt or a Guard can sit to the <b>right</b> of any piece with a body knob on its right. Pieces of the same column family stack above and below each other, knob-on-top under hole-on-top.</p>
<p>A legendary Heal piece has mind edges on three sides (left, top, bottom). It only goes beside mind knobs. In one fight I held Pecan Pie and Buckthorn Zing with no cell at all, flipped or not. Beside the Blank, in round 1, they always fit. {P}</p>
{h3('2.4', 'Flipping')}
""")
w(fig(figs.fig_flip(), 'Figure 4. Flip.'))
w(f"""
<ul>
<li>Flip is free and unlimited. Flip the piece, look at the new lit cells, flip it back if you like. {P}</li>
<li>A flipped piece stays flipped on the board. It is the right way up again when it comes back into your hand. A <b>Keeper</b> piece that you flipped and did not play stays flipped in your hand next round. {P}</li>
<li>Flip matters when the only free cell next to your target is on the wrong side. In my Carrion Crow fight, turn 6, the flipped Snack reached a cell beside a Sun and healed 13. Unflipped, its two cells both ran into a Thornburst. {P}</li>
</ul>
{h3('2.5', 'Tags on your pieces')}
<p>A tag is one extra effect. This table says what each tag really does on this board. The first three are new in 2.6.990 and have their own section (2.9).</p>
<table>
<thead><tr><th>Tag</th><th>On</th><th>What it does</th><th>Checked</th></tr></thead>
<tbody>
<tr><td><b>Keeper</b></td><td>Guard</td><td>If you do not play it, it stays in your hand through the redraw. The hand is then filled up to 5 around it.</td><td>{P}</td></tr>
<tr><td><b>Plenty</b></td><td>Heal, Hurt</td><td>When you place it: next round you pick from 6 pieces instead of 5. One round only. It does not stack.</td><td>{P}</td></tr>
<tr><td><b>Simmer</b></td><td>Heal</td><td>When you place it: you heal 2 as each of your next 2 turns starts.</td><td>{P}</td></tr>
<tr><td><b>Quick</b></td><td>Hurt</td><td>The game text now says: "no extra effect for you (one piece a turn)". The engine still draws you a piece, and the redraw throws it away. See 10.2.</td><td>{C}</td></tr>
<tr><td><b>Pierce</b></td><td>Hurt</td><td>Ignores the creature's guard.</td><td>{P}</td></tr>
<tr><td><b>Poison</b></td><td>Hurt</td><td>At the start of each of the creature's next 2 turns the bar gets half of the piece's <b>printed</b> number (rounded up). Flat: combos and Sun do not raise it. A new Poison restarts the 2 turns; it does not stack. See 2.10.</td><td>{P}</td></tr>
<tr><td><b>Trip</b></td><td>Hurt</td><td>The creature skips its next turn: this very round it places nothing.</td><td>{C}</td></tr>
<tr><td><b>Bash</b></td><td>Hurt</td><td>Adds the guard you hold right now to the hit, and uses that guard up.</td><td>{C}</td></tr>
<tr><td><b>Heavy</b></td><td>Hurt</td><td>Nothing on this board. It is just a bigger number.</td><td>{C}</td></tr>
<tr><td><b>Hold</b></td><td>Guard</td><td>What is left of this guard after the creature's turn stays up one more turn.</td><td>{P}</td></tr>
<tr><td><b>Thorns</b></td><td>Guard</td><td>While it is up, each hit it blocks adds 2 to the Yield bar.</td><td>{C}</td></tr>
<tr><td><b>Evade</b></td><td>Guard</td><td>The creature's next Hurt misses completely. If the Evade is still unused at the end of the round, a poison tick on you does nothing (it still counts down). Careful: a creature Hurt fired in your own chain right after it uses the Evade up.</td><td>{C}</td></tr>
<tr><td><b>Mend</b></td><td>Guard</td><td>Also heals you 2.</td><td>{C}</td></tr>
<tr><td><b>Hum</b></td><td>Charm</td><td>Also soothes 2: its hits this round do 2 less in all.</td><td>{C}</td></tr>
<tr><td><b>Lull</b></td><td>Charm</td><td>The creature skips its next turn, like Trip.</td><td>{P}</td></tr>
<tr><td><b>Bond</b></td><td>Charm</td><td>Your Charm counts 10% more for the rest of the fight, up to 3 times, never above x1. No use against a gentle creature.</td><td>{C}</td></tr>
<tr><td><b>Pluck</b></td><td>Trick</td><td>A small chance to lift an item the creature could drop. Once a fight, only when you place it. 8% plus 3% per Luck step, half against a boss.</td><td>{C}</td></tr>
</tbody></table>
<p class="small">Texts: <code>PF_TAGS_V1</code> in <code>pfight.php</code> (lines 54 to 72). Evade's line now reads "its first hit misses and poison ticks do nothing". Evade and Trip were "played" in the 2.6.986 edition; I did not place either in a 2.6.990 fight, so they are "code" here. The poison part of Evade was run on a set-up position (<code>play/checks.php</code>).</p>
{h3('2.6', 'Combos')}
<p>A combo is a bonus for two of <b>your</b> pieces that fire one right after the other along a link. The bonus lands on the later piece. The fight text only says "COMBO" and the name, so here are the rules. {P}</p>
<table class="keep">
<thead><tr><th>Name</th><th>First fires</th><th>Then fires</th><th>Bonus on the second piece</th><th>Seen in play on 2.6.990</th></tr></thead>
<tbody>
<tr><td><b>Ambush</b></td><td>Trick</td><td>Hurt</td><td>x1.5, plus the Trick's number</td><td>Slip Past 6, Chop 5: 14. Sow Doubt 8, Jab 5: 16</td></tr>
<tr><td><b>Riposte</b></td><td>Guard</td><td>Hurt</td><td>x1.5</td><td>Dodge 5, Chop 5: 8. Oat Cake 11, Chop 16: 24</td></tr>
<tr><td><b>Double Swing</b></td><td>Hurt</td><td>Hurt</td><td>+2</td><td>the Crow's: Dive Bomb 4, Mob Caw 3: 5</td></tr>
<tr><td><b>Bait</b></td><td>Trick</td><td>Guard</td><td>plus the Trick's number</td><td>the Boar's, in a policy run: Dry Spell 2, Mud Wallow 4: 6</td></tr>
<tr><td><b>Calm Charm</b></td><td>Soothe</td><td>Charm</td><td>x1.5</td><td>not seen</td></tr>
<tr><td><b>Win Over</b></td><td>Charm</td><td>Item</td><td>half the Item's number is also added as charm</td><td>not seen</td></tr>
</tbody></table>
<div class="box warn"><h4>The order rule that decides most turns</h4>
<p>The piece you <b>place</b> fires <b>first</b>. So to get Ambush you place the <b>Trick</b> next to a Hurt that is already on the board. To get Riposte you place the <b>Guard</b> next to a Hurt that is already there. Placing the Hurt next to the Trick gives no combo at all.</p></div>
<p>The creature gets the same combos from its own pieces. Its aim names them ("combo Double Swing"). {P}</p>
{h3('2.7', 'How long a piece stays')}
<table class="keep">
<thead><tr><th>Piece</th><th>It leaves when</th></tr></thead>
<tbody>
<tr><td>Any piece</td><td>A chain of 3 or more fires it (use-up, see 5.5).</td></tr>
<tr><td>Your piece</td><td>After 3 rounds: the round you placed it and two more.</td></tr>
<tr><td>A creature piece</td><td>After 3 rounds, or as soon as it has fired twice. Being placed counts as the first firing.</td></tr>
<tr><td>An environment piece</td><td>After 3 of your turns.</td></tr>
<tr><td>The Blank</td><td>At the end of round 1.</td></tr>
</tbody></table>
<p class="small">Per-piece life is switched off: every piece stays 3 rounds (<code>pfb_life</code>). {P} Since 2.6.987 the NEXT strip and the creature card print 3 as well (10.3). {C}</p>
{h3('2.8', 'Where the numbers come from')}
<ul>
<li>A piece's number is its base value, plus your stat for that type, plus a third of your gnome level (rounded down), plus a rank bonus (Uncommon +2, Rare +4, Masterwork +5). {C}</li>
<li>Stats by type: Hurt uses Grit, Guard Nimble, Heal Hardiness, Charm and Soothe Charm, Trick and Item Lore. {C}</li>
<li>A legendary crop piece takes its rank from your mastery of that one crop (3.7). {C}</li>
<li>A tool piece wears its tool: 2 durability each time you play it. A chip in the fight shows the wear. {C}</li>
</ul>
{h3('2.9', 'Keeper, Plenty and Simmer')}
<p>Three tags came with 2.6.990. Today only legendary crop pieces carry them (two pieces each, see appendix C).</p>
""")
w(fig(figs.fig_hand(), 'Figure 5. My hand over three rounds against a Pincer Earwig (seed 3), with the three new tags.'))
w(f"""
<table>
<thead><tr><th>Tag</th><th>The rule, exactly</th><th>What I saw</th></tr></thead>
<tbody>
<tr><td><b>Keeper</b><br>Cranberry Preserve, Quince Jelly (both Guard)</td><td>At the redraw a Keeper piece still in your hand is not thrown away. The hand is then filled <b>up to</b> 5, so you draw 4 new pieces, not 5. It stays until you play it, for the whole fight if you like. It keeps its flip.</td><td>Cranberry Preserve stayed in my hand for five rounds in one fight and four in another (there still flipped). I drew 4 new pieces each round. {P}</td></tr>
<tr><td><b>Plenty</b><br>Buckthorn Zing (Heal), Coffee Rush (Hurt)</td><td>Only when you <b>place</b> it. Next round the hand is filled to 6 (5 if you were tripped). The round after it is 5 again. Two Plenty pieces in one round still give 6. A Plenty piece fired again later by a chain gives nothing.</td><td>Round 2 hand: 6 pieces. Round 3: 5. {P} The "fired again" part: run on a set-up position. {C}</td></tr>
<tr><td><b>Simmer</b><br>Pecan Pie, Tea Leaf (both Heal)</td><td>Only when you place it. At the end of this round and of the next one you heal 2, or less if you are nearly full, or 0 at full health. It comes after the poison tick. The fight log says "Simmer: you heal 2 as your turn starts". Placing a second Simmer piece sets the count back to 2; it does not add.</td><td>18 to 20 health as turn 3 started, 16 to 18 as turn 4 started, nothing on turn 5. {P}</td></tr>
</tbody></table>
<div class="box"><h4>How to use them</h4>
<ul>
<li><b>Keeper</b> is the only way to plan a turn ahead. Keep the Guard for the round the aim is big, or for the round a Hurt of yours waits to its right (Riposte).</li>
<li>A Keeper in the hand costs a draw: you see 4 new pieces a round instead of 5. Play it when it is no longer worth that.</li>
<li><b>Plenty</b> pays next round, not now. Place it when this round's best move is small anyway.</li>
<li><b>Simmer</b> is worth 4 health on top of the piece's own heal, but only if you are hurt when the turns start. Do not place it at full health with a small aim coming.</li>
</ul></div>
<p class="small">Code: <code>pf_apply</code> sets the counters (<code>pfight.php</code> line 526), <code>pfb_end_round</code> uses them (<code>pfboard.php</code> lines 1398 to 1414). To see them I played with a copy of the harness whose test gnome owns the three pieces (<code>play/pf_play_legend.php</code>; the engine is untouched). The plain harness cannot deal them.</p>
{h3('2.10', 'Poison, in full')}
<table class="keep">
<thead><tr><th>Question</th><th>Your poison on the creature</th><th>The creature's poison on you</th></tr></thead>
<tbody>
<tr><td>How big is a tick?</td><td>Half the piece's printed number, rounded up. x0.8 on a gentle creature.</td><td>A third of the printed number for a Hurt piece, half for a Trick (Venom Spit). At least 1.</td></tr>
<tr><td>Do combos or Sun raise it?</td><td>No (since 2.6.988).</td><td>No.</td></tr>
<tr><td>When does it tick?</td><td>As each of the creature's next 2 turns starts, also on a turn it skips.</td><td>At the end of the round, after the environment's piece.</td></tr>
<tr><td>How many ticks?</td><td>2. A new Poison sets it back to 2 and keeps the larger tick.</td><td>Each poison adds 2, at most 3 wait. Venom cells count too.</td></tr>
<tr><td>What stops it?</td><td>Nothing. Not its guard, not its Evade: a Hurt that misses still sets the poison.</td><td>Not your guard. Your Evade does, if it is still unused when the round ends.</td></tr>
</tbody></table>
<p class="small">Seen: Sting 13 fired for 20 with Riposte against the Great Hawk; the ticks were 7. Sting 10 against the Wild Boar: ticks of 5, one of them on the turn it lost to Lull. {P} The other cells: <code>pf_apply</code> (lines 453, 464, 510), <code>pfb_foe_turn</code> (line 1042), <code>pfb_end_round</code> (line 1392), and runs on set-up positions. {C}</p>
{h3('2.11', 'Built-in knacks')}
<p>Sixteen of the 42 legendary crop pieces carry a knack: a second small effect that is part of the piece. The fight page shows it with the piece. The Puzzle box only shows the piece's own line ("Heals a bit more than it looks"). These are the same knacks a puzzle upgrade can give a piece. {C}</p>
<table class="keep">
<thead><tr><th>Knack</th><th>On</th><th>The page says</th><th>What the engine does</th></tr></thead>
<tbody>
<tr><td><b>Tender</b></td><td>Heal, Item</td><td>Heals 2 more</td><td>+2 to the heal.</td></tr>
<tr><td><b>Leech</b></td><td>Hurt</td><td>Heals you a little when it hits</td><td>1 plus a sixth of the hit, if any of it got past the guard. A Hurt 12 healed 3.</td></tr>
<tr><td><b>Spiky</b></td><td>Guard</td><td>Also pricks the creature for 2 when played</td><td>+2 hurt on the bar every time it fires for you, also when a later chain fires it. Its guard does not soak it.</td></tr>
<tr><td><b>Soft touch</b></td><td>Charm, Heal, Item</td><td>Also soothes 2: its next hits do 2 less</td><td>+2 to the soothe pool for this round.</td></tr>
<tr><td><b>Warm</b></td><td>Hurt</td><td>A quarter of its damage also counts as Charm</td><td>A quarter of the damage, times the charm factor: a hit of 12 added 1.8 charm on a wary creature.</td></tr>
<tr><td><b>Finisher</b></td><td>Hurt</td><td>+3 once its Yield bar is past 60%</td><td>+3 when the <b>hurt part</b> alone is at 60% of the bar. Charm does not count (10.15).</td></tr>
<tr><td><b>Hardy</b></td><td>Guard</td><td>+2 guard</td><td>+2 guard.</td></tr>
</tbody></table>
<p class="small">Texts: <code>PF_MODS</code> and <code>PF_MODS_V1</code>. Effects: <code>pf_apply</code>. Every row was run on a set-up position (<code>play/checks.php</code>); none was played in a whole fight. {C}</p>
""")

# ------------------------------------------------------------------ 3
w(h2('3', 'Setting up a fight'))
w(f"""
<p>Everything in this chapter is read from the page code (<code>pfdeck.php</code>, <code>pfdeck_view.php</code>). I did not open the live pages. {Q} The deck builder itself (<code>pfd_build</code>) I ran with made-up gnomes (<code>play/checks.php</code>); where a line rests on that, it says so.</p>
{h3('3.1', 'The Puzzle box and your deck')}
<ul>
<li>Your deck is built in the <b>Puzzle box</b>. It has three tabs: Kit, Belt, Pals.</li>
<li>The first time, you pack a <b>starter</b>: 4 fixed pieces (Swing, Dodge, Rest, Charm) plus 6 of 12 offered pieces. One tap picks a ready kit instead:
  <ul><li><b>Bold</b> (the default): your calling piece, Jab, a second Swing, Pierce, Snack, Oat Cake.</li>
  <li><b>Steady</b>: calling piece, Jab, second Swing, Pierce, Brace, your home region's piece.</li>
  <li><b>Kind</b>: calling piece, Jab, second Swing, Pierce, Hum, Soothe.</li></ul></li>
<li>Later you switch on more pieces you own: knacks (by level), crop pieces, legendary crop pieces, craft pieces, region pieces.</li>
<li><b>New in 2.6.989:</b> a piece you have just earned arrives switched <b>off</b>, with a NEW mark, until you switch it once. Before, crop, craft and region pieces arrived switched on. A gnome who already owned such pieces finds them marked NEW and off after the update. (Run: a gnome with a new crop piece and two new legendary pieces got all three "off, NEW".)</li>
<li>Limits: at least 8 kit pieces, at least 3 Hurt pieces in a custom starter, at least 1 Hurt piece in any deck, at most 3 Rare and 1 Masterwork (a Fine wearable counts as Rare, see 3.8), and the slots of 3.6. There is no maximum size.</li>
<li>If the deck as switched is not legal (under 8 kit pieces or no Hurt), the fight plays the default kit instead.</li>
<li>The deck bar shows "Hurt pieces: N of M". Under 3 in 10 it warns: "Few Hurt pieces: fights will be long".</li>
<li>The Kit tab has filter buttons: All, basic, crop, a crown for legendary crop pieces (new in 2.6.990), craft, region.</li>
</ul>
{h3('3.2', 'The belt')}
<ul>
<li>Each tool on your fight belt adds its one piece to the deck (axe: Chop; tilling tool: Hoe Hook; staff: Sweep; lantern: Glare; and so on).</li>
<li>Belt slots: 2 for every gnome, 3 with the Stitched Fight Belt (level 8), 4 with the Masterwork Fight Belt (level 18).</li>
<li>A tool has 20 durability, plus 4 per rank. Each play of its piece costs 2. A broken tool gives no piece. Fix it with a Tool Repair Kit, or Remove it from the belt.</li>
<li>Tool pieces are not slotted beyond the belt: they need no Larder or Keepsake slot.</li>
</ul>
{h3('3.3', 'Pals')}
<p>Pals in your party lend one piece each (for example Bark Badger, a Guard; Samara Spin, a Hurt). Pal pieces have body tops and bottoms.</p>
{h3('3.4', 'The pre-fight screen')}
<ul>
<li>When a creature stands in front of you, you see its <b>creature card</b>, your deck and your health, and the button <b>Let's fight</b>.</li>
<li>With <b>Auto deck</b> on, the deck is locked and you only press the button. With it off, tap a deck piece to take it out or a bench piece to add it.</li>
<li>"Nothing changes once the fight starts." The deck is locked during the fight.</li>
</ul>
{h3('3.5', 'Reading the creature card')}
<table class="keep">
<thead><tr><th>On the card</th><th>What it tells you</th></tr></thead>
<tbody>
<tr><td>Name and level</td><td>Higher level: longer bar, harder hits.</td></tr>
<tr><td>Class chip</td><td>Critter, Bird, Beast, Reptile/Amphibian, Water or Plant/Fungus. The class sets its 4 base pieces and its <b>class rule</b> (chapter 6).</td></tr>
<tr><td>Size chip</td><td>small, medium, large or boss, and "4x4". A boss always plays the boss rule.</td></tr>
<tr><td>Temper chip</td><td>"gentle" (Charm counts fully, Hurt x0.8), "wary" (Charm x0.6) or "cannot be charmed" (boss).</td></tr>
<tr><td>"leans body / mind / craft"</td><td>Three of every five of its pieces have that family on top and bottom. Your pieces of the same family can stack onto them.</td></tr>
<tr><td>The rule line</td><td>One sentence, for example "<b>Swarm:</b> Its Hurt hits +1 for every 2 of its other pieces on the board (up to +2). Use up or outlast its pieces to shrink it."</td></tr>
<tr><td>Its pieces</td><td>4 base pieces, 1 region piece (2 for large and boss), a size extra (large: Slam; boss: Scheme and Crush) and 3 pieces of its own. Tap one to read it.</td></tr>
</tbody></table>
<div class="box"><h4>What to check on the card before you press Let's fight</h4>
<ul>
<li><b>The class rule.</b> It changes how you answer the aim.</li>
<li><b>Tags on its pieces.</b> Quick means two pieces in one turn. Pierce goes through your guard. Poison keeps costing health. Evade makes your next Hurt miss. Thorns punish hitting its guard. Heal empties the bar, also the charm on it.</li>
<li><b>Temper.</b> Against a gentle creature Charm is the stronger type. Against a wary one it is the weaker.</li>
<li><b>Your Hurt count.</b> In my runs almost every win above small size was a hurt win.</li>
</ul></div>
<p class="small">The card prints "stays 3 rounds" and "plays x2" per piece. Both are right since 2.6.987 (<code>pfv_foe_card</code>, <code>pfdeck_view.php</code> line 262).</p>
{h3('3.6', 'Slots: the Larder and the Keepsakes')}
<p>New in 2.6.989. Some pieces need a free slot before they can be switched on.</p>
<table class="keep">
<thead><tr><th>Slots</th><th>Holds</th><th class="num">Level 1 to 9</th><th class="num">10 to 14</th><th class="num">15 to 19</th><th class="num">20 and up</th></tr></thead>
<tbody>
<tr><td><b>Larder</b></td><td>Crop pieces and legendary crop pieces (and food pieces, which do not exist yet)</td><td class="num">3</td><td class="num">4</td><td class="num">4</td><td class="num">5</td></tr>
</tbody></table>
<p><b>Keepsakes (changed in 2.7.00).</b> Friend, Gourmand and lair-trophy pieces (none exist yet) and <b>wearables</b> (3.8). The count now follows its own levels: <b>1</b> slot from level 1, <b>2</b> from level 15, <b>3</b> from level 25, <b>4</b> from level 40. {C} (The 2.6.990 edition said 2, 2, 3, 3 for the four bands above.) A switched-on wearable takes one Keepsake slot; one over the count stays out of the deck ("left out").</p>
<ul>
<li>Every switched-on crop piece and legendary crop piece takes one Larder slot. A crop piece in your <b>starter</b> counts too: the Bold kit's Oat Cake takes one of your three.</li>
<li>Switching on one too many is refused: "Your Larder holds 3 crop pieces. Take one out first."</li>
<li>If more are on than the Larder holds (for example after losing a slot rule), the extra ones stay out of the deck. Their note reads "left out: your Larder is full".</li>
<li>The Puzzle box head shows pips: Rare, Masterwork, and now "Larder (crop pieces)". Keepsake pips only appear once you own a Keepsake piece (a wearable is one).</li>
<li>Region pieces, craft pieces, knacks, tool pieces and pal pieces are <b>not</b> slotted.</li>
</ul>
<p class="small">Code: <code>pfd_slots</code> (<code>pfdeck.php</code> line 22), <code>PFD_LARDER_SRC</code>, <code>PFD_KEEP_SRC</code>, the count in <code>pfd_build</code> (lines 298, 299), the refusal in <code>pfd_validate</code> (line 321), the pips in <code>pfv_box_html</code> (<code>pfdeck_view.php</code> line 171), the NEW mark in <code>pfv1.css</code> (class <code>isnew</code>). Run on <code>pfd_build</code>: a level 4 gnome with four legendary pieces on had the fourth left out; a level 9 gnome with the Bold kit could switch on two, and the third was refused. {C} I did not see the page. {Q}</p>
{h3('3.7', 'Legendary crop pieces')}
<p>New in 2.6.990. There are 42, one for each treasure crop (three per region). The full list is appendix C.</p>
<ul>
<li><b>How you get one:</b> harvest that crop 3 times (<code>PFD_LEGEND_HARVESTS</code>). The piece is then yours for good.</li>
<li><b>Its rank</b> follows your food mastery of that one crop (harvests plus meals), from Common to Masterwork. Rank adds to its number: +2, +4, +5.</li>
<li>It arrives switched off with a NEW mark, like every new piece, and it needs a <b>Larder</b> slot. So a gnome under level 10 fields at most three crop and legendary pieces together.</li>
<li>Rare and Masterwork ranks count toward the deck's caps (3 Rare, 1 Masterwork).</li>
<li>Its top and bottom edges are mind, like a crop piece. Its right knob is body for 20 pieces, mind for 11, craft for 11.</li>
<li>23 of them carry a tag (among them the only Keeper, Plenty and Simmer pieces), 16 carry a built-in knack (2.11). Wasabi Burn carries both: Poison and Finisher. Four are plain: Macadamia Smash, Mangosteen Gold and the two Soothe pieces.</li>
<li>In the fight a legendary piece is an ordinary piece of yours: it stays 3 rounds, it can be used up, it comes back from the discard.</li>
</ul>
<p class="small">Code: source <code>legend</code>, keys <code>g:SLUG</code> in <code>data/pf_pieces.txt</code>; ownership and rank in <code>pfd_sources</code> (<code>pfdeck.php</code> lines 501 to 507, needs the database: not run); the crown in <code>pfdeck_view.php</code> lines 15 and 180. I counted the 42 in the data file against the 14 treasure rows of <code>region_crops.txt</code>. {C} Three of them (Cranberry Preserve, Buckthorn Zing, Pecan Pie) I played. {P} The changelog says each piece matches its crop's stat (luck, lore, charm, grit); I could not check that. {Q}</p>
{h3('3.8', 'Wearables and the Tailor')}
<p>New in 2.7.00. Read in the code only (<code>wearables.php</code>, <code>pfdeck.php</code>) {C}. Everything about wearables is behind the same admin setting as puzzle combat v1: with <code>pfight_v1</code> Off there is no Tailor, no tile and no shop stock (<code>wear_live</code>).</p>
<ul>
<li>A wearable is a thing your gnome wears and also <b>one puzzle piece</b>. It is a <b>Keepsake</b> piece: it needs a Keepsake slot (3.6), is off until you switch it on, and is not counted as a kit piece of the starter. Source "wear", family "body", key <code>w:&lt;wearable&gt;</code> (<code>-b</code> for the second cut).</li>
<li>Six wearables, each with one or two cuts, 11 cuts in all. Each cut comes in three ranks, Common, Lined and Fine: 33 items.</li>
</ul>
<table class="keep">
<thead><tr><th>Wearable</th><th>Cut</th><th>Type</th><th class="num">Base</th><th>Tag</th><th>How you get it</th></tr></thead>
<tbody>
<tr><td rowspan="2"><b>Flood Boots</b></td><td>Puddle Hop</td><td>Guard</td><td class="num">3</td><td>Evade</td><td rowspan="2">Tailor (craft)</td></tr>
<tr><td>Sure Foot</td><td>Guard</td><td class="num">3</td><td>Hold</td></tr>
<tr><td rowspan="2"><b>Wayfarer's Hat</b></td><td>Brim Down</td><td>Guard</td><td class="num">2</td><td>Thorns</td><td rowspan="2">Shop, level 5, 300 Petals</td></tr>
<tr><td>Tip Back</td><td>Soothe</td><td class="num">3</td><td>none</td></tr>
<tr><td rowspan="2"><b>Work Gloves</b></td><td>Firm Grip</td><td>Hurt</td><td class="num">3</td><td>Leech (knack)</td><td rowspan="2">Tailor (craft)</td></tr>
<tr><td>Knuckle Down</td><td>Hurt</td><td class="num">3</td><td>Bash</td></tr>
<tr><td rowspan="2"><b>Travel Cloak</b></td><td>Wrap Up</td><td>Guard</td><td class="num">3</td><td>Mend</td><td rowspan="2">Tailor (craft)</td></tr>
<tr><td>Hood Up</td><td>Guard</td><td class="num">3</td><td>Thorns</td></tr>
<tr><td rowspan="2"><b>Trail Pack</b></td><td>Rummage</td><td>Trick</td><td class="num">2</td><td>Pluck</td><td rowspan="2">Shop, level 15, 800 Petals</td></tr>
<tr><td>Tidy Up</td><td>Trick</td><td class="num">2</td><td>none (plain)</td></tr>
<tr><td><b>Yarn Scarf</b></td><td>Yarn Wrap</td><td>Charm</td><td class="num">3</td><td>none</td><td>Cat Fish</td></tr>
</tbody></table>
<ul>
<li><b>Ranks.</b> A Lined wearable and a Fine wearable play the same cut at a higher rank. <b>Fine is +4 value over Common</b> and counts as a <b>Rare</b> piece (the deck holds at most 3 Rare, 3.1). If you own two ranks of the same cut, the best one is the piece. You can choose to wear a Fine piece <b>as Lined</b> (the toggle writes the table <code>wear_lined</code>), so it is not Rare and a little weaker. The piece keeps its key when its rank changes, so its on/off switch stays as you set it.</li>
<li>Two copies of the same cut are one piece. The two cuts of one wearable are two pieces.</li>
<li><b>The Tailor</b> is a garden building: garden level 6, 1800 Petals. You need one in at least one garden to craft Flood Boots, Work Gloves and a Travel Cloak, to line a wearable and to re-cut one.</li>
<li><b>Lining</b> (Common to Lined, then Lined to Fine): the chance is 30%, plus 8% for each Tailor power point (the sum of the levels of all your Tailors, each at most 3), up to 78%. Only the first 6 power points help; power above 6 pays commission Petals instead (5% of the base price for each point). A lining that fails gives you a <b>Tailor's Thread</b>. <b>5 Threads make the next lining a sure thing.</b> Re-cutting costs 1 Thread (free at a level 2 Tailor).</li>
<li>The Puzzle box deck has a 🧵 filter for wearables. They also show on the 2.5D gnome (layers for boots, gloves, cape, brim and pack).</li>
</ul>
<p class="small"><b>Not done in 2.7.00</b> (the changelog says so): the bots (<code>pfb_score</code>) do not value wearables or the new firing order, and there is no balance run with wearables in the deck. I did not run one either. {Q} The base values above come from the data table <code>WEAR_DEFS</code>; I did not check the rank bonus on a live piece beyond the "+4" in the code notes. {Q}</p>
""")

# ------------------------------------------------------------------ 4
w(h2('4', 'The opening'))
w(fig(figs.fig_opening(), 'Figure 6. The start of my first fight. Cells are named x,y from the top left: the Blank is on 1,1.'))
w(f"""
{h3('4.1', 'The board and the Blank')}
<ul>
<li>The board is 4 by 4 for every creature. {P}</li>
<li>One <b>Blank</b> piece starts on a random one of the four inner cells. In my four fights: 1,1, 1,1, 1,2 and 2,2. {P}</li>
<li>The Blank fits every edge. It is inert: it never fires and a chain never passes through it. It leaves at the end of round 1. {P}</li>
</ul>
{h3('4.2', 'The start pieces')}
<ol>
<li>You get your first hand of 5.</li>
<li>You pick one hand piece and one side of the Blank (left, right, above, below).</li>
<li>The creature has already picked: its gentlest piece that is not a Hurt, and a random side. If you chose the same side, yours stays and its piece moves to the next free side {C}. A boss puts out two pieces. {P}</li>
<li>Nothing fires. Turn 1 begins with your other 4 pieces still in hand.</li>
</ol>
{h3('4.3', 'Choosing your start piece')}
<div class="box"><h4>Guideline: start with a Hurt, and check its partner</h4>
<ul>
<li>Put a <b>Hurt</b> out. On turn 1 you can then place a Trick or a Guard next to it and fire it with a combo.</li>
<li>Before you confirm, find the partner in your hand and the side it must go on. Leave that cell free: do not put the Hurt where the partner's cell is off the board or is the Blank.</li>
<li>The start piece is not wasted if it is used up later. It usually fires two or three times.</li>
</ul></div>
<div class="box ex"><h4>Example with numbers</h4>
<p>Earwig, seed 11. Hand: Chop (Hurt 5), Hoe Hook, Dodge (Guard 5), Pierce, Bark Badger. I put Chop below the Blank. A Guard goes on its right. Turn 1: Dodge right of Chop, Riposte, 8 of 42.8 on the bar and 5 guard against a hit of 5. Turn 2: Slip Past below Chop, Ambush, 14 more. Chop fired twice before it was used up. {P}</p>
<p>Wild Boar, seed 3. Hand: Chop (Hurt 16), Smash 14, Jab 10, Oat Cake (Guard 11), Glare. Chop below the Blank. Turn 1: Oat Cake to its right: Riposte 24 of 171.8, and the Boar's 7 was blocked. Turn 2: Lull linked both: 30.6 more. {P}</p></div>
{h3('4.4', 'What the creature does in the opening')}
<ul>
<li>Its start piece is harmless when placed. But it stays, and it fires for the creature if a chain reaches it.</li>
<li>Its first aim is shown as soon as both start pieces are down. Read it before your first move.</li>
<li>During the start pick an aim mark is already on the board. It is worked out before the start pieces exist and is replaced once they are down. Ignore it. {P}</li>
</ul>
""")

# ------------------------------------------------------------------ 5
w(h2('5', 'Your turn, step by step'))
w(f"""
<p>A turn is: <b>look, pick, (flip), place, read the plan, End turn</b>. Three or four taps. The thinking is in "look" and "read the plan".</p>
{h3('5.1', 'Step 1: look')}
<p>Before you touch a piece, read the board in this order.</p>
<table class="keep">
<thead><tr><th>Look at</th><th>Ask</th></tr></thead>
<tbody>
<tr><td>The Yield bar</td><td>How much is missing? Can any piece end it this turn?</td></tr>
<tr><td>The aim chip and the red mark</td><td>What will it play, where, and for how much ("hits you for 9")? Does the chip say "fires Sun", "fires Bramble" or "2 pieces"?</td></tr>
<tr><td>The lit rings</td><td>Which environment pieces and which of your pieces would its chain fire?</td></tr>
<tr><td>Its status chips</td><td>"its guard 6": your Hurt loses 6 first. "dodges next hit": your first Hurt misses. "thorny guard", "bash waits".</td></tr>
<tr><td>The class rule chip</td><td>Swarm, Two aims, Grudge x2, Current, Grows, Venom trail, Two turns. For Swarm: count its pieces on the board.</td></tr>
<tr><td>Environment pieces on the board and NEXT</td><td>Can I fire Sun, Rain or Bramble? Can the creature? Where is Thornburst?</td></tr>
<tr><td>Your health and your own chips</td><td>"poisoned 2", "tripped -1 draw", "you dodge next", held guard.</td></tr>
<tr><td>Your hand</td><td>Is a Keeper piece waiting? Is this the 6-piece round after a Plenty?</td></tr>
</tbody></table>
{h3('5.2', 'Step 2: pick a piece')}
<ul>
<li>Tap a hand piece. The cells where it may go light up. Each lit cell carries numbers: what the chain adds to the bar, and what it costs you.</li>
<li>Tap Flip and look again. Every piece has two shapes.</li>
<li>Check <b>every</b> piece. Hands are small, and the best cell is often on a piece you did not expect. In my Wild Boar fight the best move was a Charm with the number 11 (Lull) that read "+30.6" and cost the Boar its turn.</li>
</ul>
<div class="box warn"><h4>Read the health cost on the cell</h4>
<p>A lit cell can cost you health. Two things cause it: your chain reaches a <b>creature Hurt</b> (it fires for the creature, at you), or your chain reaches a <b>Thornburst</b> (you lose a tenth of your health). In my 114 "biggest number" fights the player lost 12% of its health this way; the careful player 6%.</p></div>
{h3('5.3', 'Step 3: place it and read the plan')}
<ul>
<li>Tap a lit cell. The piece is down but the turn is not over.</li>
<li>The plan line lists your chain in firing order and the result ("Yield 12 to 23 of 40 (hurt +11)").</li>
<li>The aim chip updates: it now says what the creature's move would do <b>after</b> your placement. It may say the aim is broken.</li>
<li>Not happy? Pick again. Nothing counts until End turn.</li>
</ul>
{h3('5.4', 'How a chain fires')}
<ol>
<li>First the chain is worked out: the piece you placed, then every piece linked to it, the <b>newest first</b>. From each of those the chain goes on through its own links before it comes back. A piece is in a chain once.</li>
<li><b>New fights since 2.7.00 fire that chain in rank order</b> (Josh's vote). {C}
<table class="keep"><thead><tr><th>Rank</th><th>Pieces</th></tr></thead><tbody>
<tr><td class="num">1</td><td>Environment pieces in the chain (Sun, Rain, Bramble, Thornburst, Mud, Wind)</td></tr>
<tr><td class="num">2</td><td>Defence: Guard and Soothe</td></tr>
<tr><td class="num">3</td><td>Augments: Tricks</td></tr>
<tr><td class="num">4</td><td>Hurt and Charm (and any piece not named here)</td></tr>
<tr><td class="num">5</td><td>Healing: Heal and Item pieces</td></tr>
</tbody></table>
Inside one rank the old order holds (newest first, depth first). This is the same for the creature's chain. The placed piece is not first any more: a Hurt you place fires after a Guard that is linked to it.</li>
<li>Combos did not move: a piece still reads the piece it <b>linked to</b> as its parent (Ambush, Riposte, Double Swing, Bait), not the piece that fired just before it.</li>
<li>Each piece fires <b>for its owner</b>: yours for you, the creature's for the creature.</li>
<li>An environment piece fires for the side that <b>started</b> the chain.</li>
<li>If the fight ends in the middle, the rest of the chain does not fire. (Earwig, turn 8: my Pierce filled the bar, the Rain linked to it never fired. {P} That was the old order. Environment pieces fire first now, so the Rain would have fired before the Pierce.)</li>
<li>Fights from before 2.7.00 keep the old order: the placed piece first, then the links. (Rule <code>order</code> 0 in <code>PFB_V1_PRE</code>.)</li>
</ol>
""")
w(fig(figs.fig_chain(), 'Figure 7. Turn 1 against the Pincer Earwig (seed 11). Played on 2.6.990, in the old firing order.'))
w(fig(figs.fig_useup(), 'Figure 8. A creature\'s chain that I set up on purpose: see "Bait" below.'))
w(f"""
<h4>What it means when a creature piece is in your chain</h4>
<ul>
<li>Its Hurt hits you. Its Guard gives the creature guard that soaks your later Hurt. Its Heal empties the bar. Its tag works for it (Evade, Thorns, Poison, Trip).</li>
<li>A Critter's Hurt gets its Swarm bonus there too.</li>
<li>But it also spends one of that piece's two firings. A creature piece that has fired twice falls off the board.</li>
<li>So firing a harmless creature piece (a Trick with no tag, a small Guard when you play Charm or Pierce) is a cheap way to remove it. Against a Critter it also shrinks the Swarm.</li>
</ul>
<h4>Bait: what it means when your piece is in the creature's chain</h4>
<ul>
<li>Your piece fires <b>for you</b>, with your combos, in the creature's turn. {P}</li>
<li>The aim is fixed before you move. If you put a piece next to the aim cell with an edge that fits, the creature's piece will link to it and fire it. An environment piece between the two works as a bridge (figure 8).</li>
<li>In the Great Hawk fight the creature's own chain gave me 19, in the Wild Boar fight 11.</li>
<li>The aim chip shows it after you place: "fires your Pierce: 11 to it". {C}</li>
<li>It works for Heal pieces too: the Crow's chain fired my Snack and healed me 4. {P}</li>
<li>Bait fails when the creature has Evade up or gets it earlier in that chain: your Hurt misses. {C}</li>
</ul>
{h3('5.5', 'The chain of 3 rule (use-up)')}
<ul>
<li>A chain that fires <b>3 or more</b> pieces <b>uses up every piece that fired</b>. They leave the board at once. {P}</li>
<li>It does not matter who started the chain or who owns the pieces. Environment pieces count and are used up too.</li>
<li>A chain of 1 or 2 uses nothing up. The pieces stay and can fire again next turn.</li>
<li>Used-up pieces of yours go to your discard pile. You will draw them again later.</li>
</ul>
<div class="box"><h4>When is a chain of 3 worth it?</h4>
<p><b>Usually yes.</b> The board empties all the time anyway: in my careful runs I had no piece of my own on the board at the start of 50% of my turns. A piece you "save" is often used up by the creature's chain, or it expires. Take the 3-chain when one of these is true:</p>
<ul>
<li>It adds clearly more to the bar than the best chain of 2. In the Boar fight, turn 2: 30.6 against 15.</li>
<li>Your pieces in it are in their last round ("leaves this round").</li>
<li>It uses up a creature piece you want gone (a Hurt next to the aim, an Evade piece, a Critter's extra pieces).</li>
<li>It uses up a Rain or a Sun before the creature fires it. In the Hawk fight, turn 3, that kept 32 guard out of its hands.</li>
<li>It ends the fight.</li>
</ul>
<p><b>Keep the chain at 2</b> when it fires a Bramble, Sun or Rain that you can fire again next turn and the creature cannot easily reach. A Bramble fired in a chain of 2 stays: in the Crow fight I fired the same Bramble on turns 7 and 9, a tenth of the bar each time.</p>
<p><b>Never count pieces for their own sake.</b> A chain of 6 I was offered against the Carrion Crow (turn 2) added 0 to the bar: three of the six pieces were the creature's or the environment's, and the one Hurt in it missed.</p></div>
{h3('5.6', 'Passing')}
<ul>
<li>You may always pass. It costs nothing. The creature and the environment still play. {P}</li>
<li>A pass makes no progress, and every extra round is one more creature turn. Pass only when every move is worse than doing nothing.</li>
<li>A pass keeps a Keeper piece, like any other round.</li>
</ul>
<table class="keep">
<thead><tr><th>Pass when</th><th>Do not pass when</th></tr></thead>
<tbody>
<tr><td>Every lit cell costs health and adds little, and the aim is small.</td><td>Any move adds to the bar at no cost.</td></tr>
<tr><td>The creature "dodges next hit" and you hold only Hurt pieces with bad cells.</td><td>You could place a Guard, a Heal or a Charm instead. Evade does not stop those.</td></tr>
<tr><td>Your only moves would link a creature Hurt or a Thornburst into your chain.</td><td>You could take the aim cell or fire a Rain for guard.</td></tr>
</tbody></table>
<p class="small">My careful player passed in 0.05 turns a fight; the most cautious one in 0.25. Passing is rare.</p>
{h3('5.7', 'End turn')}
<ul>
<li>End turn locks the move. There is no undo after it.</li>
<li>Then you watch the replay: your chain, the creature's turn, the environment. A Skip button and a speed chip (1x, 2x, Skip) shorten it. {Q}</li>
</ul>
{h3('5.8', 'Guidelines for choosing')}
<ol>
<li><b>Can I win now?</b> If a cell ends the fight, take it. Nothing else matters.</li>
<li><b>Gain against loss.</b> For each candidate: bar gained, minus health lost in my own chain, minus what the aim does afterwards. Compare shares: 10% of the bar for 10% of my health is a fair trade early and a bad one when I am low.</li>
<li><b>Free guard first.</b> A Guard placed next to a Hurt both blocks and attacks (Riposte). Firing Rain gives guard worth 15% of your health on top of your chain.</li>
<li><b>Use what is about to leave.</b> Pieces in their last round, and a Sun or Rain the creature would fire this turn.</li>
<li><b>Mind the creature's guard and Evade.</b> With "its guard 38" up (Great Hawk after a Rain), my Swing 15 and Chop 19 read 0 and only the Pierce piece counted: play Pierce or Charm. With "dodges next hit" up, your first Hurt is wasted: lead with a weak Hurt, or play another type.</li>
<li><b>Do not block for its own sake.</b> Taking the aim cell only makes the creature pick again, at full strength. Block when the aim is unusually big (Sun, a combo, Bramble), or when your piece wants that cell anyway.</li>
<li><b>Against a Critter, count its pieces.</b> Two others out: +1 on each of its Hurts. Four: +2. A chain that uses its pieces up is worth more than its bar number says.</li>
</ol>
{h3('5.9', 'Common mistakes and what they cost')}
<table>
<thead><tr><th>Mistake</th><th>What happens</th><th>Cost in my play</th></tr></thead>
<tbody>
<tr><td>Always taking the biggest bar number</td><td>You link creature Hurts and Thornbursts into your chain and ignore the aim.</td><td>63% of health lost a fight, 89% wins. The careful player: 29% lost, 99% wins.</td></tr>
<tr><td>Always making the longest chain</td><td>Long chains are mostly the creature's pieces.</td><td>80% of health lost, 63% wins. 25% of health went to its own chains.</td></tr>
<tr><td>Reading the aim number as the whole loss against a poisoner</td><td>Poison ticks and venom are not in the number.</td><td>Against Reptiles 18% of my health a fight went to poison. On 64% of turns I lost more than the chip said.</td></tr>
<tr><td>Swinging into "dodges next hit"</td><td>The Hurt adds 0. Its combo is wasted too.</td><td>Crow, turn 2: the Riposte of 8 added 0. I had placed the Guard for its guard, knowing that.</td></tr>
<tr><td>Placing the Hurt next to the Trick</td><td>The Hurt fires first: no Ambush.</td><td>5 instead of 14 in the Earwig fight, turn 2.</td></tr>
<tr><td>Blocking a Beast's small aim</td><td>Grudge: its next Hurts are 25% stronger.</td><td>Boar, turn 5: the blocked 6 came back as 8, and the next aim read 9 + 10 instead of 7 + 8.</td></tr>
<tr><td>Leaving a Sun next to its aim cell</td><td>Its whole chain counts double.</td><td>Crow, turn 4: Talon Dive 4 and Peck 4 read 16. Hawk, turn 5: Talon Grip 8 hit for 16.</td></tr>
<tr><td>Leaving a Rain to a big creature</td><td>It gets guard worth 15% of its bar.</td><td>Hawk, turn 2: 32 guard. Next turn two of my three Hurt pieces read 0.</td></tr>
<tr><td>Letting a Critter collect pieces</td><td>Every Hurt of its gets +1 or +2.</td><td>Earwig, turn 3: an aim of 17 from two Hurts printed 5 (an Ambush, and +1 each).</td></tr>
<tr><td>Healing at full health</td><td>The heal is lost. The move still takes your turn.</td><td>A wasted round. A Simmer placed then also wastes its first tick.</td></tr>
</tbody></table>
{h3('5.10', 'When to flip')}
<ul>
<li>Flip <b>every</b> piece once while you look. It costs nothing and often opens a cell above or below.</li>
<li>A piece with no lit cell at all may have several when flipped. In the Crow fight, turn 3, Oat Cake and both Swings had "no cells" unflipped and two cells each flipped.</li>
<li>Flipping never changes the left and right edges. If a piece cannot go beside a neighbour, flipping will not help.</li>
</ul>
""")

# ------------------------------------------------------------------ 6
w(h2('6', "The creature's turn"))
w(f"""
{h3('6.1', 'What happens, in order')}
<ol>
<li><b>Its old guard drops.</b> Guard the creature got on its last turn (or inside your chain) lasted through your turn. Now it is gone, unless a Hold piece keeps it. Its Evade drops too.</li>
<li><b>Your poison on it ticks.</b> The bar moves, also on a turn it will skip. {P} If that fills it, you win before it acts. {C}</li>
<li><b>It plays its aim</b>: the piece and the cell it showed you. If it cannot, it picks its best move now. If it is slowed (Trip, Lull) it plays nothing.</li>
<li><b>Its chain fires</b>, by the same rules as yours. A chain of 3 or more uses up what fired.</li>
<li><b>Extras</b>: one more piece after a Quick piece, a Water creature's push, a Plant's Bramble. (A Critter no longer plays a second piece.)</li>
<li><b>The environment</b> places one piece (chapter 7).</li>
<li><b>Poison on you ticks</b>, unless your Evade is still up. Then <b>Simmer</b> heals you 2 if it is running. A trip takes effect.</li>
<li><b>Old pieces leave</b> (3 rounds old). Venom cells fade.</li>
<li><b>You draw a new hand</b>: Keeper pieces stay, everything else is thrown away, and the hand is filled to 5 (4 if you were tripped, one more after a Plenty). Your guard fades, except what a Hold guard keeps.</li>
<li><b>The free piece: gone in new fights (2.7.00).</b> Before 2.7.00, if the creature had fewer than 2 pieces on the board, the board put out one for it just before your turn: its gentlest piece that is not a Hurt, on a random cell where it fits. It did not fire. Josh called an enemy piece appearing at the end of your resolution a bug. New fights (rule <code>spawn</code> 0) get no such piece. Saved fights still do (<code>pfb_end_round</code> gates <code>pfb_spawn</code>). {C} Everything in this book that says "the board hands it a free piece" is about saved fights only.</li>
<li><b>The new aim</b> is shown.</li>
</ol>
<p class="small">Code: <code>pfb_foe_turn</code>, <code>pfb_end_round</code>, <code>pfb_spawn</code>, <code>pfb_intent</code>. The replay on the page follows the same order. {Q}</p>
{h3('6.2', 'The aim')}
<ul>
<li>The red mark is the cell. The chip names the piece and what it would do <b>right now</b>: "Peck: hits you for 9".</li>
<li>The number is a real dry run of its <b>whole turn</b>: its chain, combos, Sun, the Swarm bonus, your guard, your pieces it fires, and since 2.6.987 the extra piece after a Quick piece. {P}</li>
<li>The aim is a promise. The piece lands on that cell even if a use-up has left the cell touching nothing. (Great Hawk, turn 3: Peck landed alone on 0,1.) {P}</li>
</ul>
<h4>What breaks the aim</h4>
<table class="keep">
<thead><tr><th>You do this</th><th>What the creature does</th></tr></thead>
<tbody>
<tr><td>Put a piece on the aim cell</td><td>It picks again: its best move on the board as it is now, at full strength. Your piece is not harmed. {P} If your own chain of 3 uses that piece up, the cell is free again and the aim lands. {P}</td></tr>
<tr><td>Put a piece <b>next to</b> the aim cell whose edge does not fit the aimed piece</td><td>Same: it picks again. The chip reads "broken" after you place. {P}</td></tr>
<tr><td>Play Trip or Lull</td><td>It loses the turn. The chip reads "is slowed: no move". {P}</td></tr>
</tbody></table>
<p class="small">"Aim strike" (the aimed Hurt breaks your piece on its cell) is built but switched <b>off</b> in new fights since 2.6.984. Since 2.6.987 the help sheet only describes it when it is on (10.4).</p>
<h4>What the number still leaves out</h4>
<ul>
<li><b>Poison</b> ticks on you and a Reptile's venom.</li>
<li>Turns on which it shows <b>no aim</b>: there is no number, and it may still find a move.</li>
<li>Anything after it picks again.</li>
</ul>
<p>The chip still adds "2 pieces" for a Quick piece. The second piece is now inside the number; when it changes the number, the reasons add "Quick: its second piece is in the number". {P}</p>
<p>In my careful runs the health I really lost on the creature's turn was more than the chip said on 1% of turns against small creatures, 39% against medium, 19% against large and 16% against bosses. Nearly all of it is poison: with the poison ticks taken out it is 1% to 2% in every size, and the cases I looked at were "no aim" turns. In the 2.6.986 edition these figures were 40%, 51%, 20% and 21%, and the cause was the second piece.</p>
{h3('6.3', "The creature's pieces")}
<ul>
<li>The creature holds 3 pieces (a boss 4) and plays one a turn. A boss plays its deck in a fixed order: one set-up piece, then two Hurts, again and again. {C}</li>
<li>The creature must make a link if any of its pieces can. For you, touching and fitting is enough (beside the Blank, for example). {C}</li>
<li>Every creature piece falls away after it has fired twice. The piece view says "plays x2". {P}</li>
<li>Above small size its single pieces are small next to yours: the Boar's 6 to 7 against your 10 to 16. A small creature's are not: the Earwig's 4 to 5 against your 3 to 5. Most of its damage comes from <b>re-firing</b> an older Hurt with a new one (Double Swing), from Sun and Bramble, and for a Critter from the Swarm bonus.</li>
</ul>
{h3('6.4', 'Tags on creature pieces')}
<table class="keep">
<thead><tr><th>Tag</th><th>What it does to you</th></tr></thead>
<tbody>
<tr><td>Quick</td><td>It plays one more piece this turn (once a turn). {P}</td></tr>
<tr><td>Pierce</td><td>Ignores your guard. Seen: the Earwig's Pincer took 5 through 8 guard. {P}</td></tr>
<tr><td>Poison</td><td>2 ticks on your health: a third of the piece's printed number for a Hurt, half for a Trick, at least 1. At most 3 ticks wait. Your Evade, if still up at the end of the round, stops a tick. {C}</td></tr>
<tr><td>Trip</td><td>You draw 4 pieces next round instead of 5. {P}</td></tr>
<tr><td>Bash</td><td>Adds its guard to the hit. A Trick with Bash lends the guard to its next Hurt. {C}</td></tr>
<tr><td>Evade</td><td>Your next Hurt misses. The chip reads "dodges next hit". It lasts until its next turn starts. {P} A Hurt of yours that misses still sets its Poison. {C}</td></tr>
<tr><td>Thorns</td><td>While its guard is up, each of your hits that the guard soaks pricks you (2, or 4% of your health if that is more). {C}</td></tr>
<tr><td>Hold</td><td>Its guard lasts a turn longer. Seen: the Hawk's Island Time 6 was still there a turn later, on top of its Rain guard. {P}</td></tr>
<tr><td>Heal (on a Trick)</td><td>Empties the Yield bar by its number: the hurt part first, then the charm part. {C}</td></tr>
</tbody></table>
{h3('6.5', 'Class rules')}
<p>Every creature has one extra rule from its class. A boss has the boss rule instead. The numbers under "careful player" are from 12 fights per class (24 for Critter, 30 for Boss) on 2.6.990, so they are rough.</p>
""")

classes = [
    ('6.5.1', 'Critter: Swarm', 'Its Hurt hits +1 for every 2 of its other pieces on the board (up to +2). Use up or outlast its pieces to shrink it.',
     ['<b>New rule since 2.6.988.</b> A Critter plays <b>one</b> piece a turn, like everyone else, and its pieces have their full number (the old rule was two pieces a turn at x0.6).',
      'When one of its Hurt pieces fires, count its <b>other</b> pieces on the board at that moment: 2 or 3 give +1, 4 or more give +2. Guards, Tricks, the free piece and the start piece all count. ' + C + ' (run: a Hurt 4 fired for 4, 4, 5, 5, 6, 6, 6 with 0 to 6 others)',
      'The bonus is added to every Hurt in its chain, after its combo and before a Sun doubles it. It is in the aim number. ' + P,
      'It also applies when its Hurt fires inside <b>your</b> chain. ' + C,
      'Its base Trick, Skitter, is Quick: that turn it still plays a second piece.'],
     ['Count its pieces before you read the aim. With two others out, a Double Swing of two Hurts printed 5 and 4 read 13.',
      'Shrink it: a chain of 3 that runs through its pieces uses them up. Its pieces also fall after two firings and leave after 3 rounds.',
      'Before 2.7.00 it could not go below one piece for long: the board handed it a free piece whenever it had fewer than 2 out. That piece is gone in new fights, so its count can stay at 0 or 1 after a clean-out. I did not re-measure how often +1 and +2 happen. ' + Q,
      'Trip and Lull cancel its piece.',
      'Small Critters are the one place where Charm wins fights: the gentle ones take Charm at full value.'],
     '28% of health lost, 100% wins, 6.9 turns. 38% of the wins were by charm. The real loss was above the chip on 12% of turns (it was 52% under the old rule).'),
    ('6.5.2', 'Bird: Two aims', 'It shows two moves on different cells. Take the first cell and it plays the second; take both and it picks again.',
     ['The second aim can be a different piece. The chip adds it: "or Wing Cover 2 at B4".', 'After you place, the chip shows the total of whichever aim will play ("its second aim").',
      'Its base Trick, Flutter Off, gives it Evade whenever it fires, also inside its own chain. In my Crow fight "dodges next hit" was up on 4 of my 10 turns. ' + P],
     ['Taking a cell rarely saves you, and it can cost you: in the Crow fight a piece on aim 1 would have turned a 3 into a 9 (figure 10). Guard helps. So does a misfit next to the aim: that breaks it without a second aim.',
      'Look at both cells for Sun. In the Crow fight, turn 3, both aims stood next to the same Sun.',
      'When it "dodges next hit", play Guard, Heal or Charm that turn. I did so three times.'],
     '40% of health lost, 92% wins: the only class that beat my careful player this time (Carrion Crow, seed 1).'),
    ('6.5.3', 'Beast: Grudge', 'Each time you block its aim, its Hurt hits 25% harder (up to 3 times). A hit that lands on you clears it.',
     ['"Block" means: a piece stands on its aim cell when its turn comes. The chip shows "Grudge x1", "x2", "x3".', 'A misfit next to the cell also makes it pick again, and does <b>not</b> add Grudge. ' + C,
      'Grudge ends when you lose health on its turn. A hit your guard fully soaks does not clear it. (Boar, turn 5: the 8 was blocked, Grudge x1 stayed.) ' + P],
     ['Let small aims land. A 6 that lands clears the Grudge.', 'Block only the big ones, and prefer breaking the aim with a misfit.',
      'Do not sit behind guard for many turns with Grudge x3 up: it never clears, and Bash and Pierce pieces get through.'],
     '24% of health lost, 100% wins.'),
    ('6.5.4', 'Water: Current', 'After its piece lands, one of your pieces touching it slides a cell away, if that cell is free.',
     ['Only one piece moves, one cell, straight away from the creature’s piece. Checked in the order left, right, above, below. ' + C, 'A moved piece keeps its edges. Its old links are gone; it may make new ones where it lands.'],
     ['Do not count on a link next to the aim cell lasting.', 'A piece with a wall or another piece behind it cannot be pushed.', 'Its Trick, Undertow, trips you: a hand of 4 next round.'],
     '19% of health lost, 100% wins.'),
    ('6.5.5', 'Plant: Grows', 'After its turn it grows a Bramble beside its piece (one of its own at a time). Whoever chains the Bramble fires it.',
     ['The Bramble has wild edges: it links to anything next to it. ' + C, 'It appears beside the piece the Plant just placed, so the Plant is first in line to fire it next turn: you lose a tenth of your health.',
      'Its guard, Bramble Coat, has Thorns. Sap Mend empties the bar: the hurt part first, then your charm.'],
     ['Fire the Bramble yourself first: a tenth of the bar for you, and in a chain of 2 it stays for another go.', 'Or take the cell that would link its next piece to the Bramble.', 'Hit its guard with Pierce or Charm, not with small Hurts.'],
     '19% of health lost, 100% wins, the shortest fights (6.2 turns): its Brambles fed my bar.'),
    ('6.5.6', 'Reptile: Venom trail', 'When one of its pieces leaves the board, that cell is venom for 2 turns. A piece of yours put there poisons you (2 a round, 2 rounds).',
     ['Venom cells are marked on the board. Any way of leaving counts: use-up, firing twice, old age. ' + C, 'Its Trick, Venom Spit, also poisons. Poison is not in the aim number.',
      'Since 2.6.989 venom cannot push your poison above 3 waiting ticks. ' + C],
     ['Read the mark before you place. The lit number does not show the venom.', 'Stepping on venom can still be right, for a win or a big chain: it costs 4 health in all.',
      'Long fights are dangerous here: poison ignores guard. An Evade guard that is not used up stops that round’s tick.'],
     '47% of health lost, 100% wins. 18% of my health a fight went to poison alone.'),
    ('6.5.7', 'Boss: Two turns', 'It also shows the piece it will play next round. That piece is forced; its cell is chosen then.',
     ['The chip adds "then Talon Dive 9". The piece is fixed, the cell is not. In the Hawk fight every preview came true. ' + P, 'A boss starts with two pieces, holds 4, cannot be charmed or run from, and wins if the fight reaches 24 turns.',
      'Charm still fills its bar at x0.6. The ending is always "backs off".', 'A Lull or Trip does not change the forced piece: it showed the same Talon Grip again the turn after my Lull. ' + P],
     ['Use the preview to time your guard: an Evade or Hold guard the turn before its Crush.',
      'Its bar is long (215 for the Great Hawk). Sun, Bramble and Lull did the heavy work for me: one Sun turn was worth 57, and two Lulls cost it two turns.', 'Do not block out of habit. It re-picks at full strength.',
      'Keep Rain away from it: 15% of a 215 bar is 32 guard.'],
     '28% of health lost, 100% wins.'),
]
for num, title, rule, how, counter, stat in classes:
    w(f'<div class="box" style="background:#fbfaf5;border-color:#b9b6a8;{"break-inside:auto;page-break-inside:auto;" if num == "6.5.1" else ""}">{h4(num, title)}<p><i>Rule text in the game:</i> "{rule}"</p>'
      f'<p><b>How it plays.</b></p><ul>{"".join("<li>" + x + "</li>" for x in how)}</ul>'
      f'<p><b>Counter-play.</b></p><ul>{"".join("<li>" + x + "</li>" for x in counter)}</ul>'
      f'<p class="small"><b>Careful player:</b> {stat}</p></div>')
    if num == '6.5.1':
        w(fig(figs.fig_swarm(), 'Figure 9. Swarm since 2.6.988. The dark square is the Hurt that fires, the white ones are its other pieces on the board.'))
    if num == '6.5.2':
        w(fig(figs.fig_bird(), 'Figure 10. Two aims.'))

# ------------------------------------------------------------------ 7
w(h2('7', 'The environment'))
w(f"""
{h3('7.1', 'How it works')}
<ul>
<li>The environment is a third player. After the creature's turn it places <b>one</b> piece. {P}</li>
<li>Its next piece lies face up all round in the NEXT strip. You know what is coming, not where.</li>
<li>It puts the piece on an empty cell with <b>nothing on any side</b>, among the three such cells farthest from all pieces. Nothing fires when it lands. {C}</li>
<li>If no lonely cell exists it takes a cell where the piece fits. If 12 or more of the 16 cells are taken it places nothing. {C}</li>
<li>Its pieces belong to nobody. Link one into your chain and it fires <b>for you</b>. The creature can do the same. {P}</li>
<li>They count for the chain length and are used up by a chain of 3. Otherwise they stay 3 of your turns. {P}</li>
<li>Wind and Mud exist in the code but are <b>not</b> in the deck of a new fight. {C}</li>
</ul>
""")
w(fig(figs.fig_env(), 'Figure 11. The four environment pieces. Each has all three families on its edges, so most decks can link to it from some side.'))
w(f"""
{h3('7.2', 'The four pieces')}
<table>
<thead><tr><th>Piece</th><th>If your chain fires it</th><th>If the creature's chain fires it</th><th>How to use it</th></tr></thead>
<tbody>
<tr><td><b>Sun</b></td><td>Every piece of yours in that chain counts double: hurt, charm, guard and healing.</td><td>Every piece of its in that chain counts double.</td><td>Bring your biggest chain to it. Seen: Chop 19 read 38; Lull 14 read 28 (16.8 on the bar); Snack 8 healed 16. If its aim cell touches a Sun, take the Sun first or take the cell.</td></tr>
<tr><td><b>Bramble</b></td><td>A tenth of the Yield bar is added.</td><td>You lose a tenth of your maximum health. Guard does not help.</td><td>The best piece on the board for you against long bars: 17.2 on the Boar, 21.5 on the Hawk. Fire it in a chain of 2 and it stays.</td></tr>
<tr><td><b>Rain</b></td><td>You get guard worth 15% of your maximum health.</td><td>It gets guard worth 15% of its <b>Yield bar</b>.</td><td>Free guard on top of your move. Do not leave it for the creature: on a long bar its Rain guard is huge (26 on the Boar, 32 on the Hawk, 10.7).</td></tr>
<tr><td><b>Thornburst</b></td><td>You lose a tenth of your maximum health.</td><td>5% of the Yield bar is added.</td><td>Link around it. Lit cells that touch it show the cost. Let the creature run into it: the Boar's own chain fired one and gave me 8.6.</td></tr>
</tbody></table>
<p class="small">All four rows, both sides, were seen in the four hand-played fights. {P}</p>
{h3('7.3', 'The deck')}
<table class="keep">
<thead><tr><th>Creature size</th><th class="num">Sun</th><th class="num">Bramble</th><th class="num">Rain</th><th class="num">Thornburst</th><th class="num">Pieces</th></tr></thead>
<tbody>
<tr><td>small</td><td class="num">2</td><td class="num">1</td><td class="num">2</td><td class="num">1</td><td class="num">6</td></tr>
<tr><td>medium, large</td><td class="num">2</td><td class="num">2</td><td class="num">2</td><td class="num">2</td><td class="num">8</td></tr>
<tr><td>boss</td><td class="num">2</td><td class="num">3</td><td class="num">2</td><td class="num">2</td><td class="num">9</td></tr>
</tbody></table>
<p>The region adds one copy of one kind: Sun in CA, CB and SE; Rain in SA, NWE, EA and SEA; Bramble in EE and WCA; Thornburst in ESA. The deck is shuffled, and reshuffled when it runs out. {C} (The table: run of <code>pfb_env_deck</code>.)</p>
{h3('7.4', 'How the creature uses it')}
<ul>
<li>The creature looks for its best move like you do. A Sun, Rain or Bramble next to a cell it can reach raises that move's value, so its aim often points there.</li>
<li>The aim chip names it: "hits you for 16, fires Bramble". The piece gets a ring on the board.</li>
<li>In my four hand-played fights the first aim of a round pointed at an environment piece on 21 of 32 turns. {P}</li>
<li>The owner measured this before 2.6.97: the creature's chain fired an environment piece in 43% of rounds. I did not re-measure it. {Q}</li>
</ul>
<div class="box"><h4>Guidelines for the environment</h4>
<ul>
<li>Each turn ask: which side reaches each environment piece first?</li>
<li>A Sun or Rain that the aim would fire can be denied in three ways: fire it yourself in a chain of 3 (it is used up), take the aim cell, or break the aim with a misfit.</li>
<li>Prefer a chain of 2 on Bramble. Prefer a chain of 3 on a Sun or Rain the creature can reach.</li>
<li>Thornburst is only bad for the side that fires it. But any piece of yours that touches it links to it (a touching edge must fit), so it will fire in that chain. Stay off cells that touch it, unless the lit number says the cost is worth it, or the move ends the fight before the Thornburst fires.</li>
</ul></div>
""")

# ------------------------------------------------------------------ 8
w(h2('8', 'Winning and losing'))
w(f"""
{h3('8.1', 'The hurt route')}
<ul>
<li>Hurt counts fully against wary creatures and bosses, x0.8 against gentle ones.</li>
<li>Combos, Sun, Bramble and Poison all feed the hurt share.</li>
<li>It is slowed by the creature's guard, Evade and healing. Pierce answers guard. Nothing answers Evade except not swinging.</li>
</ul>
{h3('8.2', 'The charm route')}
<ul>
<li>Charm fills the same bar. Guard and Evade cannot touch it. {P}</li>
<li>Healing can, since 2.6.989: a creature's heal empties the hurt part first and then the charm part. A bar filled only by Charm is no longer safe from Sap Mend and other heal pieces. {C}</li>
<li>It counts x0.6 against wary creatures and bosses. Bond raises that by 0.1 per use, three times at most.</li>
<li>You are "won over" only if charm is the <b>larger share</b> when the bar fills. Bramble, Thornburst and Poison count as hurt, so they pull the ending toward "backs off".</li>
<li>The reward differs: a charm win gives a gift and the creature's seed or guide drops, but not its ordinary drops. A hurt win gives the ordinary drops. Both give full XP. {C}</li>
</ul>
<p>How often my fights ended by charm, by creature size:</p>
<table class="keep">
<thead><tr><th>Player</th><th class="num">small</th><th class="num">medium</th><th class="num">large</th><th class="num">boss</th></tr></thead>
<tbody>
<tr><td>Careful (no preference)</td><td class="num">50%</td><td class="num">6%</td><td class="num">3%</td><td class="num">0%</td></tr>
<tr><td>Charmer (counts charm double when choosing)</td><td class="num">50%</td><td class="num">11%</td><td class="num">7%</td><td class="num">0%</td></tr>
</tbody></table>
<p class="small">18 small, 36 medium, 30 large and 30 boss fights per row, on 2.6.990. Two of the three small creatures in my set are gentle. Every charm ending of the careful player was against a gentle creature. Above small size a charm ending is rare even when you want it.</p>
<div class="box"><h4>Guideline</h4>
<p>Play Charm when the creature is gentle, when its guard is high, or when it dodges your next hit. Do not plan a charm win against a medium or larger creature unless your deck is built for it.</p></div>
{h3('8.3', 'Bosses')}
<ul>
<li>A boss cannot be charmed and you cannot run. Its ending is always "backs off".</li>
<li>If the fight goes past turn 24 you lose. My longest boss fight took 15 turns (13 for the careful player, whose average was 8.7).</li>
<li>Its rule shows you the next round's piece. Its deck order repeats: set-up, Hurt, Hurt.</li>
<li>Your Charm pieces are not dead: they add x0.6 to the bar and ignore its guard. In the Hawk fight Charm pieces added 43 of the 232 I scored.</li>
</ul>
{h3('8.4', 'Health carries over')}
<ul>
<li>You start the fight with the health your expedition has (at least 1). You leave with what is left. {C}</li>
<li>So a fight won at 20% health makes the next fight on the same trip much harder. Health lost is the real score of a fight.</li>
<li>Heal and Item pieces, Mend, Simmer, Leech and a Rest outside the fight bring it back. A Master Thornblade heals fully after a win. {C}</li>
<li>After a knock-out you wake where you set out, with half your health and 2 energy less. You keep your things. {C}</li>
</ul>
{h3('8.5', 'The reward')}
<ul>
<li>After the last replay a result card shows. One tap, "Collect the reward", ends the fight. {Q}</li>
<li>XP is the creature's XP, less in an area you have outgrown.</li>
<li>Pluck, if it worked, already gave its item during the fight.</li>
<li>Tool wear is saved when the fight ends, however it ended.</li>
</ul>
<p class="small">8.3 to 8.5 rest on <code>adventure.php</code> and <code>pfight_game.php</code>. Neither changed in these parts between 2.6.986 and 2.6.990 (the only changes in <code>pfight_game.php</code> are the Simmer log line and one opening text). {C}</p>
""")

# ------------------------------------------------------------------ 9
w(h2('9', 'Quick reference'))
w(f"""
{h3('9.1', 'Types')}
<table class="keep">
<thead><tr><th>Type</th><th>Left hole</th><th>Knob on top?</th><th>Fires for you</th><th>Fires for the creature</th></tr></thead>
<tbody>
<tr><td>Hurt</td><td>body</td><td>yes</td><td>+N hurt on the bar (after its guard)</td><td>-N health (after your guard)</td></tr>
<tr><td>Guard</td><td>body</td><td>no</td><td>+N guard until your next turn</td><td>+N guard until its next turn</td></tr>
<tr><td>Heal</td><td>mind</td><td>no</td><td>+N health</td><td>-N on the bar: hurt first, then charm</td></tr>
<tr><td>Charm</td><td>mind</td><td>yes</td><td>+N charm on the bar (x0.6 wary, boss)</td><td>nothing</td></tr>
<tr><td>Soothe</td><td>mind</td><td>no</td><td>its hits this round do N less in all</td><td>nothing</td></tr>
<tr><td>Trick</td><td>craft</td><td>yes</td><td>sets up Ambush or Bait</td><td>its tag (Quick, Evade, Bash, Thorns, Poison, Trip, Heal)</td></tr>
<tr><td>Item</td><td>craft</td><td>no</td><td>+N health</td><td>nothing</td></tr>
</tbody></table>
{h3('9.2', 'Your tags')}
<table class="keep">
<thead><tr><th>Tag</th><th>In one line</th><th>Example pieces</th></tr></thead>
<tbody>
<tr><td>Keeper</td><td>not played: stays in your hand, you draw up to 5 around it</td><td>Cranberry Preserve, Quince Jelly</td></tr>
<tr><td>Plenty</td><td>placed: next round a hand of 6</td><td>Buckthorn Zing, Coffee Rush</td></tr>
<tr><td>Simmer</td><td>placed: heal 2 at the start of your next 2 turns</td><td>Pecan Pie, Tea Leaf</td></tr>
<tr><td>Quick</td><td>no extra effect for you</td><td>Jab, Dibber Poke, Pickle Splash</td></tr>
<tr><td>Pierce</td><td>ignores its guard</td><td>Pierce, Hoe Hook, Nut Crack, Almond Crack, Walnut Crack</td></tr>
<tr><td>Poison</td><td>half its printed number on each of its next 2 turns</td><td>Sting, Compost Lob, Pepper Puff, Pepper Sting, Wasabi Burn</td></tr>
<tr><td>Trip</td><td>it skips its turn</td><td>Trip, Net Toss, Clove Prick</td></tr>
<tr><td>Bash</td><td>adds your guard to the hit, uses it up</td><td>Shield Bash, Rock Chip, Brazil Nut Bash</td></tr>
<tr><td>Heavy</td><td>nothing here</td><td>Smash, Fork Lift, Windfall</td></tr>
<tr><td>Hold</td><td>what is left of the guard stays one more turn</td><td>Brace, Oat Cake, Spare Handle, Frost Bark, Hazelnut Hide, Baobab Bark</td></tr>
<tr><td>Thorns</td><td>a blocked hit adds 2 to the bar</td><td>Thorn Hide, Thornbush, Laterite Crust, Durian Stink</td></tr>
<tr><td>Evade</td><td>its next Hurt misses; an unused Evade stops a poison tick</td><td>Roll, Sweep, Mist Veil, Heat Shimmer, Caper Pop, Snakeskin Plate</td></tr>
<tr><td>Mend</td><td>also heals 2</td><td>Mending</td></tr>
<tr><td>Hum</td><td>also soothes 2</td><td>Hum, Wind Chime, Cardamom Hum, Nutmeg Whisper</td></tr>
<tr><td>Lull</td><td>it skips its turn</td><td>Lull, Glare, Paradise Lull</td></tr>
<tr><td>Bond</td><td>Charm +10%, up to 3 times</td><td>Bond, Sweet Pea, Saffron Thread, Cacao Bite</td></tr>
<tr><td>Pluck</td><td>small chance of an item, once</td><td>Pluck, Pistachio Pop</td></tr>
</tbody></table>
<p class="small">Knacks built into legendary pieces: Tender (+2 heal), Leech (heals you 1 + a sixth of the hit), Spiky (+2 hurt on the bar), Soft touch (soothes 2), Warm (a quarter of the damage also as charm), Finisher (+3 once the hurt part is at 60%), Hardy (+2 guard). See 2.11.</p>
{h3('9.3', 'Class rules')}
<table class="keep">
<thead><tr><th>Class</th><th>Rule</th><th>Base pieces</th><th>Remember</th></tr></thead>
<tbody>
<tr><td>Critter</td><td>Swarm: its Hurt +1 per 2 of its other pieces out, up to +2</td><td>Nip, Sting, Chitin Shell, Skitter (Quick)</td><td>Count its pieces. Use them up.</td></tr>
<tr><td>Bird</td><td>Two aims</td><td>Peck, Talon Dive, Wing Cover, Flutter Off (Evade)</td><td>Guard, do not chase cells.</td></tr>
<tr><td>Beast</td><td>Grudge: +25% Hurt per block, up to 3</td><td>Claw, Maul, Brace, Shoulder Barge (Bash)</td><td>Let small hits land.</td></tr>
<tr><td>Water</td><td>Current: pushes one of your pieces</td><td>Snap, Splash, Slick Hide, Undertow (Trip)</td><td>Links next to its aim may not last.</td></tr>
<tr><td>Plant, Fungus</td><td>Grows: a Bramble beside its piece</td><td>Lash Vine, Spore Puff, Bramble Coat (Thorns), Sap Mend (Heal)</td><td>Fire its Bramble first.</td></tr>
<tr><td>Reptile, Amphibian</td><td>Venom trail: venom where its pieces leave</td><td>Bite, Tail Lash, Scale Guard, Venom Spit (Poison)</td><td>Check the cell for venom.</td></tr>
<tr><td>Boss</td><td>Two turns: shows next round's piece</td><td>its class pieces plus Scheme and Crush</td><td>Cannot be charmed. 24 turns.</td></tr>
</tbody></table>
{h3('9.4', 'Environment pieces')}
<table class="keep">
<thead><tr><th>Piece</th><th>For the side that fires it</th><th>Edges: left, right, top, bottom</th></tr></thead>
<tbody>
<tr><td>Sun</td><td>its pieces in that chain count x2</td><td>body hole, mind knob, craft knob, craft hole</td></tr>
<tr><td>Bramble</td><td>the other side loses a tenth (your health; its bar)</td><td>mind hole, craft knob, body knob, body hole</td></tr>
<tr><td>Rain</td><td>guard: 15% of your health, or 15% of its bar</td><td>craft hole, body knob, mind knob, mind hole</td></tr>
<tr><td>Thornburst</td><td>it is hurt: you a tenth of health, it 5% of the bar</td><td>mind hole, body knob, craft hole, craft knob</td></tr>
</tbody></table>
{h3('9.5', 'Chips and marks on the fight page')}
<p>Read from <code>tools/pfboardv1_part.js</code>, <code>pfight_game.php</code> and <code>pfdeck_view.php</code>. I did not see the pages. {Q}</p>
<table>
<thead><tr><th>You see</th><th>It means</th></tr></thead>
<tbody>
<tr><td>"R3 · You" / the creature's name / "Environment"</td><td>The round number and whose step it is.</td></tr>
<tr><td>Dots after a chain</td><td>How many pieces your chain fires. 3 or more: everything that fired is used up.</td></tr>
<tr><td>Red target mark on a cell</td><td>The aim cell. A Bird shows a second, smaller mark.</td></tr>
<tr><td>"Aims Nip hurt 5", "Peck: hits you for 9"</td><td>The aim and its total now, for its whole turn. Tap it for the reasons.</td></tr>
<tr><td>"· fires Sun", "· fires Bramble"</td><td>Its chain would fire that environment piece.</td></tr>
<tr><td>"· 2 pieces"</td><td>The aimed piece is Quick: a second piece follows. Since 2.6.987 it is in the number.</td></tr>
<tr><td>"is blocked by your guard", "does no damage", "heals 4"</td><td>Other aim results. "does no damage" also shows when its chain would heal you by firing your Heal piece (10.19).</td></tr>
<tr><td>Solid pulsing ring on an environment piece</td><td>The aim's chain would fire it. A badge says what it gives ("Sun x2 for it").</td></tr>
<tr><td>Dotted amber ring on your piece</td><td>The aim's chain would fire it: "it fires this". Your piece works for you.</td></tr>
<tr><td>"no aim"</td><td>It shows no move. It will look for a spot on its turn.</td></tr>
<tr><td>"... is slowed: no move"</td><td>Trip or Lull landed. It skips this turn.</td></tr>
<tr><td>"Swarm", "Two aims", "Grudge x2", "Current", "Grows", "Venom trail", "Two turns"</td><td>The class rule. Tap or hover for the sentence. The Swarm chip does not show the bonus it has right now.</td></tr>
<tr><td>"its guard 6"</td><td>Your Hurt pieces lose 6 before they reach the bar. Pierce and Charm do not.</td></tr>
<tr><td>"dodges next hit"</td><td>The creature has Evade: your next Hurt misses.</td></tr>
<tr><td>"thorny guard"</td><td>Hits its guard soaks will prick you.</td></tr>
<tr><td>"bash waits"</td><td>Its next Hurt adds its guard to the hit.</td></tr>
<tr><td>"poisoned 2"</td><td>Poison ticks waiting on you.</td></tr>
<tr><td>"tripped -1 draw"</td><td>You drew, or will draw, one piece fewer.</td></tr>
<tr><td>"you dodge next"</td><td>Your Evade is up. It also stops this round's poison tick if it is not used.</td></tr>
<tr><td>"Simmer +2" in the round's chips; log line "Simmer: you heal 2 as your turn starts"</td><td>A Simmer heal landed. No chip shows that a Simmer or a Plenty is still running.</td></tr>
<tr><td>Three new tag marks on pieces</td><td>Keeper, Plenty and Simmer. Tap the piece for the sentence.</td></tr>
<tr><td>Venom mark on an empty cell</td><td>A Reptile's piece left from here. Placing there poisons you.</td></tr>
<tr><td>Wrench chip with a number</td><td>Tool pieces in play and their durability.</td></tr>
<tr><td>NEXT strip</td><td>The environment's next piece. Tap it to read it. It now reads "stays 3 rounds".</td></tr>
<tr><td>"?" and "1x"</td><td>The help sheet, and the replay speed (1x, 2x, Skip).</td></tr>
<tr><td>In the Puzzle box: NEW on a piece</td><td>You earned it and have never switched it. It is off.</td></tr>
<tr><td>In the Puzzle box: Larder pips; "left out: your Larder is full"</td><td>Crop and legendary pieces switched on, against your slots. A piece over the count stays out of the deck.</td></tr>
<tr><td>In the Puzzle box: the crown button</td><td>Shows only legendary crop pieces.</td></tr>
</tbody></table>
""")

# cheat sheet (one page)
w('<div class="cheat">' + h2('9.6', 'Cheat sheet') + f"""
<div class="cols">
<div class="blk"><h4>Goal</h4><ul><li>Fill the Yield bar. Hurt and Charm both fill it. Its heal empties it.</li><li>Do not let your health reach 0. It carries over to the next fight.</li></ul></div>
<div class="blk"><h4>A round</h4><ul><li>You: one piece (or pass). Flip is free.</li><li>The creature: its aim, its chain, class extras.</li><li>The environment: one piece on a lonely cell.</li><li>Clean-up: poison, Simmer, old pieces leave, new hand of 5.</li></ul></div>
<div class="blk"><h4>Fitting</h4><ul><li>Knob into hole, same family (round, keyhole, triangle).</li><li>Every touching edge must fit. A fit is a link.</li><li>Left is a hole, right is a knob. Flip swaps top and bottom.</li></ul></div>
<div class="blk"><h4>Chains</h4><ul><li>The chain is the placed piece and what links to it, newest first. It fires in rank order: environment, Guard / Soothe, Tricks, Hurt / Charm, healing.</li><li>Each piece fires for its owner. Environment pieces fire for the side that started the chain.</li><li>3 or more pieces fired: all of them leave the board.</li><li>Pieces stay 3 rounds. Creature pieces fall after 2 firings.</li></ul></div>
<div class="blk"><h4>Combos (your two pieces, one after the other)</h4><ul><li>Trick then Hurt: x1.5 + the Trick's number (Ambush).</li><li>Guard then Hurt: x1.5 (Riposte).</li><li>Hurt then Hurt: +2 (Double Swing).</li><li>Trick then Guard: + the Trick's number (Bait).</li><li>Place the <b>first</b> piece of the pair. The second must already be on the board.</li></ul></div>
<div class="blk"><h4>Before you place: seven checks</h4><ul><li>1. Can a cell end the fight?</li><li>2. Aim chip: how much, where, "fires ..."? Poison on top?</li><li>3. Its chips: guard, dodges next hit, thorny, Grudge, Swarm.</li><li>4. Lit cell: what does it cost me? (creature Hurt, Thornburst, venom)</li><li>5. Flipped: is there a better cell?</li><li>6. Sun, Rain, Bramble: who fires them first?</li><li>7. After placing: what does the aim chip say now?</li></ul></div>
<div class="blk"><h4>The aim</h4><ul><li>It lands on its cell unless: your piece is on the cell, a misfit stands beside it, or it is slowed.</li><li>Then it picks again at full strength. No free turn.</li><li>The number is its whole turn. It leaves out poison and venom.</li><li>A fitting piece of yours beside the aim cell gets fired, for you (bait).</li></ul></div>
<div class="blk"><h4>Environment</h4><ul><li>Sun: the chain's owner counts double.</li><li>Bramble: the other side loses a tenth. Fire it in a chain of 2 to keep it.</li><li>Rain: guard for whoever fires it. Do not leave it to the creature.</li><li>Thornburst: hurts whoever fires it. Stay off it.</li></ul></div>
<div class="blk"><h4>Class rules</h4><ul><li>Critter: its Hurt +1 per 2 other pieces it has out (max +2).</li><li>Bird: two aims. Guard instead of chasing.</li><li>Beast: blocking makes it hit harder. Let small hits land.</li><li>Water: pushes your piece away.</li><li>Plant: grows a Bramble. Fire it first.</li><li>Reptile: venom cells and poison. Finish fast.</li><li>Boss: shows next round's piece. No charm win, no running, 24 turns.</li></ul></div>
<div class="blk"><h4>New tags and slots</h4><ul><li>Keeper: stays in your hand until played.</li><li>Plenty: next round a hand of 6. Simmer: heal 2, twice.</li><li>Poison ticks are flat: half the printed number, 2 turns.</li><li>New pieces arrive off, marked NEW. Larder: 3 crop pieces (4 at level 10, 5 at 20).</li></ul></div>
<div class="blk"><h4>Do not</h4><ul><li>Take the biggest number without reading the cost.</li><li>Count chain length. Count bar and health.</li><li>Swing into "dodges next hit". Hit "its guard" with small Hurts.</li><li>Heal at full health. Pass when a free move exists.</li></ul></div>
<div class="blk"><h4>Numbers</h4><ul><li>Board 4 by 4. Hand 5. One action. Fight limit 24 turns.</li><li>Charm x0.6 on wary creatures and bosses. Hurt x0.8 on gentle ones.</li><li>Sun x2. Bramble 10%. Rain 15%. Thornburst 10% (you), 5% (it).</li><li>Grudge +25% a block, up to 3. Venom 2 a round for 2 rounds. Poison on you: at most 3 ticks.</li></ul></div>
</div></div>
""")

# ------------------------------------------------------------------ 10
OK = '<span class="st ok">resolved</span>'
CH = '<span class="st ch">changed</span>'
OP = '<span class="st op">still open</span>'
NW = '<span class="st nw">new</span>'
w(h2('10', 'Open questions and confusing places'))
w(f"""
<p>These are the places where the rules, the texts or the numbers did not agree while I played, or where a rule works but will surprise a player. Each has a code place or a fight you can replay with <code>php tests/pf_play.php new STATE SLUG LEVEL SEED v1</code>.</p>
<p>Items 10.1 to 10.14 are the list of the 2.6.986 edition, in the same order, each with its state on 2.6.990: {OK} the game was changed and the point is gone, {CH} the game was changed and part of the point remains, {OP} nothing changed. Items 10.15 to 10.21 are {NW}: found while checking 2.6.987 to 2.6.990. Line numbers are those of <code>origin/main</code> at 2.6.990.</p>
<table class="keep">
<thead><tr><th>Item</th><th>State</th><th>In one line</th></tr></thead>
<tbody>
<tr><td>10.1 Aim number and the second piece</td><td>{OK}</td><td>The number is the whole turn now. Poison and "no aim" turns are still outside it.</td></tr>
<tr><td>10.2 Quick on your pieces</td><td>{CH}</td><td>The text is honest now. The piece still does nothing extra.</td></tr>
<tr><td>10.3 "Stays N rounds"</td><td>{OK}</td><td>All three places print 3.</td></tr>
<tr><td>10.4 Help sheet and the aim strike</td><td>{OK}</td><td>The sentence is behind the switch.</td></tr>
<tr><td>10.5 Trip and Lull</td><td>{OP}</td><td>Kept on purpose. Still the strongest cheap effect I played.</td></tr>
<tr><td>10.6 Poison</td><td>{CH}</td><td>Ticks are flat. Poison still lands through the creature's Evade, and the text still gives no number.</td></tr>
<tr><td>10.7 Rain</td><td>{OP}</td><td>15% of your health against 15% of its bar.</td></tr>
<tr><td>10.8 Grudge</td><td>{OP}</td><td>"Block" means a piece on the cell, nothing else.</td></tr>
<tr><td>10.9 Hidden multipliers</td><td>{OP}</td><td>x0.6 and x0.8 are not on the piece.</td></tr>
<tr><td>10.10 What a new player will not guess</td><td>{OP}</td><td>Trick order, bait, Heavy, the free piece.</td></tr>
<tr><td>10.11 The board does not last</td><td>{OP}</td><td>Half my turns start with none of my pieces out. Keeper is a first answer, in the hand.</td></tr>
<tr><td>10.12 Charm route</td><td>{CH}</td><td>Still a small-creature route, and a creature's heal now eats charm too.</td></tr>
<tr><td>10.13 Smaller slips</td><td>{CH}</td><td>One of six fixed, five new ones.</td></tr>
<tr><td>10.14 What I could not verify</td><td>{CH}</td><td>The list for this edition.</td></tr>
</tbody></table>

{h3('10.1', 'The aim number leaves out the second piece', OK)}
<ul>
<li><b>Was:</b> the chip was a dry run of the first piece only. A Critter's second piece and a Quick piece's extra piece were not in "hits you for N".</li>
<li><b>Now (2.6.987):</b> when the aimed piece is Quick, <code>pfb_aim_total</code> plays the creature's whole turn on a copy and shows that loss (<code>pfboard.php</code> lines 1265 to 1267). And since 2.6.988 a Critter plays one piece, so there is no second piece to miss (<code>pfb_foe_len</code>, line 1001).</li>
<li><b>Evidence in play:</b> Carrion Crow, seed 5, turn 10: the chip read "hits you for 11 (combo Double Swing, Quick: plays again, Quick: its second piece is in the number)". Turn 1: chip 3, loss 3, with a Quick extra piece that did no damage. In 684 policy fights the loss was above the chip, poison ticks taken out, on 1% to 2% of turns (it was 20% to 51% with them in, on 2.6.986).</li>
<li><b>What is left:</b> poison ticks and venom are not in the number (6.2). On a "no aim" turn there is no number at all. The doc comment above <code>pfb_aim_total</code> (line 1220) still says "Quick's extra piece ... not in the numbers".</li>
<li><b>Small point:</b> the chip still says "2 pieces" for every Quick aim. The reason "its second piece is in the number" only appears when the second piece changes the number. A player cannot tell "in it, and it added 0" from "not in it".</li>
</ul>

{h3('10.2', 'Quick on your own pieces does nothing', CH)}
<ul>
<li><b>Was:</b> the text promised "draws you a piece when you place it", and the redraw threw that piece away.</li>
<li><b>Now (2.6.987):</b> the text reads "Quick: no extra effect for you (one piece a turn)" (<code>PF_TAGS_V1</code>, <code>pfight.php</code> line 58).</li>
<li><b>The rule itself is unchanged:</b> the engine still draws the piece (<code>pf_apply</code>, line 466; run: 4 in hand became 5) and <code>pfb_end_round</code> discards it. Jab is still in every ready kit, with Dibber Poke and Pickle Splash beside it. The "Sticky" upgrade draws in the same dead way (line 527). {C}</li>
<li>For the creature, Quick is strong: one more piece that turn.</li>
<li><b>Question, still open:</b> what should Quick do for the player? Keeper, Plenty and Simmer show the direction the owner chose for hand effects; Quick could join them.</li>
</ul>

{h3('10.3', '"Stays N rounds" is printed in three places and is wrong in two', OK)}
<ul>
<li><b>Now (2.6.987):</b> the NEXT strip takes 3 unless per-piece life is on (<code>pfb_view</code>, <code>pfboard.php</code> line 1467). The creature card prints <code>PFB_LIFE</code> (<code>pfv_foe_card</code>, <code>pfdeck_view.php</code> line 262). The hand piece already said 3.</li>
<li><b>Evidence:</b> in all my fights every piece showed "stays 3" and stayed 3 rounds. {P} The two page texts: code. {C}</li>
<li><b>Left over, harmless:</b> the deck entry still carries the old life (Quick 2, Hold 4, Masterwork 4; <code>pfd_build</code>, <code>pfdeck.php</code> line 272), and the data file comments still describe it. Nothing shows it while per-piece life is off.</li>
</ul>

{h3('10.4', 'The help sheet explains a rule that is off', OK)}
<ul>
<li><b>Now (2.6.987):</b> the strike sentence is only added when <code>V1.aimhit</code> is on (<code>tools/pfboardv1_part.js</code> line 387). In a new fight the row reads: "The red mark is where its next piece goes. Take the cell and it has to pick again." {C}</li>
</ul>

{h3('10.5', 'Trip and Lull remove a whole creature turn', OP)}
<ul>
<li>The owner decided to keep this (changelog 2.6.988). The rule is one line: <code>pfb_foe_len</code> returns 1 minus slow.</li>
<li>It applies the same round, also to a boss, also to a Quick extra piece.</li>
<li><b>New evidence:</b> I placed a Lull piece four times in two fights, and each time it was the best move on the board. Wild Boar, turn 2: Lull 11 linked two of my pieces for 30.6 and stopped an aim of 11. Turn 6: Glare stopped an aim of 19. Great Hawk, turns 4 and 6: an aim of 19 and an aim of 20 never happened.</li>
<li>These are cheap pieces (Trip, Net Toss: Hurt base 2; Lull, Glare: Charm base 3). 2.6.990 adds two more carriers: Paradise Lull (Charm 5) and Clove Prick (Hurt 4).</li>
<li>Your poison still ticks on the turn it skips, so Lull also buys a free tick.</li>
<li>The creature's Trip does something quite different to you: you draw 4 instead of 5. One word, two effects.</li>
<li><b>Question, as before:</b> is a full skip, with no limit on how often, the intended strength?</li>
</ul>

{h3('10.6', 'Poison follows the boosted hit, and works through Evade', CH)}
<ul>
<li><b>Was:</b> a tick was half of the fired value, after combos and Sun (a tick of 44 ended a boss fight).</li>
<li><b>Now (2.6.988):</b> the tick is half of the piece's printed number (<code>pf_apply</code>, <code>pfight.php</code> line 464; a third or a half for the creature's, lines 453 and 510). Seen: Sting 13 fired for 20 with Riposte, ticks of 7. {P}</li>
<li><b>Now (2.6.988):</b> on your side an Evade that is still up at the end of the round makes the tick do nothing (<code>pfb_end_round</code>, <code>pfboard.php</code> line 1392). {C}</li>
<li><b>Still open:</b> your Poison Hurt that the creature dodges deals 0 and still sets the poison (run: damage 0, tick 5). The creature's Evade stops nothing of yours. The two sides now follow different rules, and the tag text only says the player's half.</li>
<li><b>Still open:</b> the text says "hits again each of the next 2 turns". How much is not said. A new Poison keeps the larger tick and restarts the count instead of adding, which the text does not say either. Against a gentle creature a tick counts x0.8.</li>
<li><b>Careful with Evade:</b> the creature's Hurt uses your Evade up. So the tick is only stopped on a round in which nothing hit you. The text "poison ticks do nothing" reads as if Evade always stops them.</li>
</ul>

{h3('10.7', 'Rain is not the same piece for both sides', OP)}
<ul>
<li>Your Rain guard is 15% of your health. The creature's is 15% of its <b>Yield bar</b> (<code>pfb_env_fire</code>, <code>pfboard.php</code> line 282).</li>
<li><b>New evidence:</b> Great Hawk: 17 guard for me, 32 for it. With its Hold guard on top it stood at 38, and my Swing 15 and Chop 19 read 0. Wild Boar: 13 for me, 26 for it. Earwig: 5 for me, 6 for it.</li>
<li>Its guard also soaks every Hurt in my chain until its next turn. Only Pierce and Charm get past.</li>
<li>The help text says "it gets the guard" but not how much. The ring badge does show the number.</li>
</ul>

{h3('10.8', 'Grudge: what counts as a block', OP)}
<ul>
<li>Rule text: "Each time you block its aim".</li>
<li>Code: Grudge goes up only when a piece stands <b>on</b> the aim cell (<code>pfb_foe_turn</code>, <code>pfboard.php</code> line 1063). Breaking the aim with a misfit beside the cell makes it pick again and adds no Grudge. {C}</li>
<li>If your chain of 3 uses up the piece you put on the cell, the cell is free again, the aim lands, and there is no Grudge. {C} (The same thing seen without a Beast: Great Hawk, turn 3.)</li>
<li>Grudge also raises a Beast Hurt that fires inside <b>your</b> chain: the Boar's Maul 6 hit me for 8 in my own chain on turn 6. {P}</li>
<li>"A hit that lands" means you lost health during its turn. A fully guarded hit keeps the Grudge (Boar, turn 5). {P}</li>
</ul>

{h3('10.9', 'Hidden multipliers', OP)}
<ul>
<li>A Charm 5 adds 3 to the bar of a wary creature. A Hurt 10 adds 8 to a gentle one. The piece shows 5 and 10.</li>
<li>The lit cell shows the true number, so the page is honest at the moment of choice. The deck screen is not: there Charm looks as strong as Hurt.</li>
<li>Bond does nothing against a gentle creature (Charm is already x1).</li>
<li>New, same kind: Warm's "a quarter of its damage also counts as Charm" is a quarter times 0.6 on a wary creature. Poison ticks and Spiky count x0.8 on a gentle one.</li>
</ul>

{h3('10.10', 'Things a new player will not guess', OP)}
<ul>
<li><b>Trick order.</b> "Boosts a Hurt or Guard fired right after it" is true, but only if you place the Trick. Nothing says so.</li>
<li><b>Bait.</b> The help says "If its aim fires one of your pieces, your piece works for you". In play this is one of the strongest moves, and the creature cannot avoid it, because its aim is fixed before you move. Is that intended? (Hawk, turn 5: 19 of bait. Boar, turn 3: 11.)</li>
<li><b>Evade eats bait.</b> A creature Guard or Trick with Evade that fires earlier in its chain makes your baited Hurt miss. {C}</li>
<li><b>Net health on a lit cell.</b> A heal in the same chain hides a Thornburst or a creature hit: the cell shows the net (the harness note says "h-0 can hide a loss").</li>
<li><b>The creature finishing itself.</b> When its chain fires a Thornburst the bar grows by 5%. The aim total does not count that as "to it". Boar, turn 4: the chip said "fires Thornburst" and nothing about the 8.6 it then gave me. {P}</li>
<li><b>Heavy</b> is a tag with no effect on this board.</li>
<li><b>The free piece.</b> RESOLVED for new fights in 2.7.00: it was a piece the board gave the creature when it had fewer than 2 out, and it looked like a second move. New fights do not get it. Saved fights do.</li>
</ul>

{h3('10.11', 'The board does not last', OP)}
<ul>
<li>At the start of my turn I had no piece of my own on the board in 50% of turns (careful) to 67% (longest chain).</li>
<li>Use-up, two firings, three rounds and the full redraw all clear things away. Most turns are a fresh puzzle: which hand piece links to what the creature and the environment left.</li>
<li>This is known (the T15 bake-off). Keeper is the first rule that lets a player carry something from one round to the next. Only 2 of the game's pieces have it, both legendary.</li>
</ul>

{h3('10.12', 'Charm is a small-creature route', CH)}
<ul>
<li>Charm endings: 50% small, 6% medium, 3% large, 0% boss for the careful player (8.2). Every one was against a gentle creature.</li>
<li>Bramble, Thornburst and Poison count as hurt, so the environment pushes every long fight toward "backs off".</li>
<li><b>Changed in 2.6.989:</b> a creature's heal now empties charm too, once the hurt part is gone. That is the fix the owner asked for ("Creature healing needs to act on the yield bar"). It makes the pure charm route a little harder still against Plants (Sap Mend) and any creature with a Heal piece. I did not measure by how much. {Q}</li>
<li>The reward for a charm win is different (gift, seed, guide). A player who wants it has little control above small size.</li>
</ul>

{h3('10.13', 'Smaller text slips', CH)}
<ul>
<li>{OP} <code>tests/pf_play.php</code> footer (line 103) still says: "a flip is free, once a turn", "A piece must make a linked joint unless nothing can", and lists Teamwork. All three are off.</li>
<li>{OK} The harness printed "on side ?" for both start pieces when the Blank was not in the centre. Fixed in 2.6.989 (line 159): my four starts printed L, R, T, B correctly.</li>
<li>{OP} The harness lets a Snack be placed at any health. The game refuses it at full health and after the snack limit (<code>pfight_game.php</code> lines 200 to 202).</li>
<li>{OP} The harness does not print the creature's guard, its Evade, the second aim, Grudge or venom cells. The page does. I read them from the state file.</li>
<li>{OP} <code>PFB_SUN_MULT</code> is commented "a Hurt or Charm piece" (<code>pfboard.php</code> line 34); the Sun piece doubles every type.</li>
<li>{OP} The page names cells A1 to D4. The harness and this book count x,y from 0. Cell 2,1 here is C2 on the page.</li>
<li>{NW} The harness prints an <b>empty line</b> for a Simmer heal: its note table has no "simmer" entry (<code>tests/pf_play.php</code> line 110). The heal shows up as "your hp +2" on the environment's line.</li>
<li>{NW} The harness deals the test gnome's crop, craft and region pieces <b>off</b> since 2.6.989 (they have no saved state, and new pieces arrive off). Its decks shrank from 14, 19, 27 and 27 pieces to 13, 16, 19 and 19 in my four fights. Nothing in the harness says so. Bots and testers play a thinner deck than before, and no legendary piece ever.</li>
<li>{NW} Stale comments: "Swarm: Critter plays 2 pieces a turn at x0.6" (<code>pfboard.php</code> line 72); "+1 Hurt for each other creature piece out" where the code gives +1 per two (line 681); "crop, craft and region pieces are on unless switched off" (<code>pfdeck.php</code> line 282).</li>
<li>{NW} The pips say "Larder (crop pieces)" and the refusal says "Your Larder holds 3 crop pieces". Legendary pieces count too and are not named.</li>
<li>{NW} The changelog of 2.6.990 says of itself: the bots do not value a kept piece, a sixth piece or a heal over time; no balance run with the 42 pieces; the hand of 6 was not looked at on a phone. I can confirm the first from the code (<code>pfb_score</code> has no term for them) and nothing of the other two.</li>
</ul>

{h3('10.14', 'What I could not verify', CH)}
<ul>
<li>The live pages: layout, taps, replay timing, the look of chips, rings, the NEW mark, the Larder pips, the crown filter, the three new tag marks, a hand of 6 on a phone. All page statements come from the source files.</li>
<li>Rewards, knock-out and health carry-over: read in <code>adventure.php</code> and <code>pfight_game.php</code>, not played. Those parts did not change after 2.6.986.</li>
<li>The Puzzle box, belt and pre-fight screens. The deck builder under them (<code>pfd_build</code>, <code>pfd_slots</code>, <code>pfd_validate</code>) I ran with made-up gnomes. The database side (<code>pfd_sources</code>: 3 harvests, mastery rank, saved switches, <code>pfd_toggle</code>) I only read.</li>
<li>Real decks. My gnome is the test gnome of the harness, at the creature's level, and since 2.6.989 without its crop, craft and region pieces.</li>
<li>The JS twin (<code>tools/pfengine.js</code>). I read its header and constants only; all play was on the PHP engine.</li>
<li>Read in code, not seen firing in a whole fight: Trip and Evade on my own pieces, Calm Charm and Win Over, Bash, Thorns, Mend, Bond, Pluck, the seven built-in knacks, a creature's Heal on a charm-filled bar, your Evade stopping a poison tick, venom, the Water push. The knacks, the heal, the Evade tick and the venom cap were run on set-up positions (<code>play/checks.php</code>).</li>
<li>Of the 42 legendary pieces I played three. The other 39 are checked against the data file only.</li>
<li>That each legendary piece "matches its crop's stat", as the changelog says.</li>
</ul>

{h3('10.15', 'Finisher counts only the hurt part of the bar', NW)}
<ul>
<li>Text on the page: "+3 once its Yield bar is past 60%" (<code>PF_MODS_V1</code>, <code>pfight.php</code> line 116). The piece lines say "+3 when the Yield bar is past 60%" (Kola Jolt) and "+3 late in the fight" (Wasabi Burn).</li>
<li>Code: +3 when the <b>hurt part</b> is at least 60% of the bar (<code>pf_apply</code>, line 439: <code>fh.now &gt;= 0.6 * fh.max</code>). The charm part is not counted.</li>
<li>Run: with the bar 70% full by charm alone, a Finisher Hurt 4 added 4. With 70% hurt it added 7 (<code>play/checks.php</code>).</li>
<li>A player who charms first and then swings Kola Jolt at a bar that reads 70% gets no bonus and no hint why. The rule predates the one shared bar; it was not moved over.</li>
<li>Also: "past 60%" is "60% or more" in the code. Minor.</li>
</ul>

{h3('10.16', 'The new Swarm: what the sentence does not say', NW)}
<ul>
<li>Rule text: "Its Hurt hits +1 for every 2 of its other pieces on the board (up to +2). Use up or outlast its pieces to shrink it."</li>
<li><b>It counts every piece of its:</b> start piece, free piece, Guards, Tricks. Until 2.7.00 the board also handed a Critter a free piece whenever it had fewer than 2 out (<code>pfb_spawn</code>); new fights no longer get it, so "Outlast" can get it to zero now. I did not re-measure that. The next lines are from 2.6.990, with the free piece: after a clean-out it is back at one or two pieces before your next turn. Earwig, seed 11: it had 2 or 3 pieces out at the start of 5 of my 8 turns.</li>
<li><b>It works in your chain too.</b> A Critter Hurt that your chain fires hits with the bonus (<code>pfb_fire</code>, <code>pfboard.php</code> line 681 has no check of whose chain it is). The lit cell shows the cost, the rule text does not say it.</li>
<li><b>The chip is silent.</b> "Swarm" shows no "+1" the way Grudge shows "x2". The aim number has it inside. A player who wants to know why Nip 5 reads 6 has to count pieces.</li>
<li><b>Small creatures hit as hard as you now.</b> With x0.6 gone, the Earwig's Nip is 5 against my Chop 5, on a gnome with 32 health. An Ambush of two of its pieces with +1 each read 17: more than half my health in one aim, on turn 3 of a level 4 fight. I broke that aim; a new player would not know how.</li>
<li>The owner's own numbers say the change is neutral for the chain bot (57% / 71% against 58% / 72%). My careful player lost 28% of its health against Critters (27% before) and won all 24 fights. So the level is the same; the swings are bigger.</li>
</ul>

{h3('10.17', 'New pieces arrive off: what happens to a gnome who already had them', NW)}
<ul>
<li>Since 2.6.989 a piece with no saved switch is off and marked NEW (<code>pfd_build</code>, <code>pfdeck.php</code> line 284). Before, crop, craft and region pieces without a saved switch were on.</li>
<li>So on the day of the update every gnome who never touched those switches loses those pieces from the deck without doing anything. The changelog says so in one line ("will show as New and off until packed"). Nothing on the page tells the player that the deck just got smaller.</li>
<li>How much it matters, from the harness gnome, which is exactly such a gnome: 8 pieces fewer at level 21 and 28. My careful player lost 29% of its health a fight on 2.6.990 against 24% on 2.6.986, with the same policies and seeds. Part of that is the new Swarm and flat poison; I cannot split it. {Q}</li>
<li>If the smaller deck falls under 8 kit pieces or has no Hurt, the fight silently plays the default kit (<code>pfd_fight_entries</code>).</li>
<li><b>Starter crop pieces take Larder slots.</b> The Bold kit holds Oat Cake, a crop piece. A level 9 Bold gnome has 2 free slots, not 3 (run: the third legendary piece was refused). The Steady and Kind kits have 3.</li>
<li><b>Two answers for one state.</b> With more on than slots, <code>pfd_build</code> marks the extra piece "left out" <i>and</i> <code>pfd_validate</code> calls the whole deck illegal ("Take one out first"). The page then has to show both. I could not see how it looks. {Q}</li>
<li>The Keepsake slots (2, 3 from level 15) exist with nothing to put in them. The pips are hidden until then, so this is not visible.</li>
</ul>

{h3('10.18', 'Keeper, Plenty and Simmer: the small print', NW)}
<ul>
<li><b>Keeper narrows the draw.</b> The hand is filled <i>up to</i> 5, so a kept piece costs one new piece every round it stays. The text "stays in your hand until you play it" does not say that. Two Keepers in hand leave 3 new pieces a round.</li>
<li><b>Keeper keeps its flip.</b> Every other piece comes back the right way up; a kept piece stays as you left it. Fine, but the only place a flip carries over.</li>
<li><b>Only when placed.</b> Plenty and Simmer do nothing when a later chain fires the piece again (<code>pf_apply</code>: the root piece only). The piece's own Heal does fire again. So the same piece gives its tag once and its number several times.</li>
<li><b>No chip while they run.</b> The page has chips for poison, trip and Evade, but none for "Simmer: 1 more" or "Plenty: 6 next round" (<code>tools/pfboardv1_part.js</code> has no such text). You find out when it happens.</li>
<li><b>Simmer at full health heals 0</b> and the tick is spent. It is also the last thing in the clean-up, after the poison tick, so it cannot save you from that tick.</li>
<li><b>A second Simmer does not add:</b> the count is set to 2, not raised by 2. Plenty is a flag: two in a round give one extra piece. The Plenty text says "pick from 6", the changelog says "does not stack"; the Simmer text says nothing.</li>
<li><b>Plenty and a trip:</b> 5 pieces, not 6. Plenty and a Keeper: 6 with the Keeper among them.</li>
<li><b>The harness cannot deal them</b> (10.13), so neither the bots nor a tester on the plain harness has ever played one.</li>
</ul>

{h3('10.19', 'The aim chip when its chain would heal you', NW)}
<ul>
<li>Carrion Crow, seed 5, turn 7: the aim (Mob Caw beside a Sun and my Snack) would hit me for 6, all blocked or small, and fire my Snack, which heals. The dry run's total was <b>-2</b>.</li>
<li>The harness printed "it hits you for -2". The page has no case for a negative number: it falls through to "does no damage" for a Hurt aim (<code>tools/pfboardv1_part.js</code> line 264). {C}</li>
<li>Neither is wrong, neither is clear. "Does no damage" hides that the creature is about to heal me; "-2" looks like a bug.</li>
</ul>

{h3('10.20', 'Legendary Item pieces are snacks that eat nothing', NW)}
<ul>
<li>Snack "eats a food item from your satchel", is refused at full health and counts against the fight's snack limit. All three checks hang on the tag <code>snack</code> (<code>pfight_game.php</code> lines 200 to 216).</li>
<li>Cloudberry Gold, Ackee Surprise and Yuzu Zest are Item pieces whose lines call them snacks ("A rare sweet snack", "A snack that heals more", "A sharp snack"). They carry no <code>snack</code> tag. They heal 4 or 5 plus bonuses, eat nothing, have no limit and are never refused.</li>
<li>Juicy Bite and Forager's Find (older Item pieces) work the same way, so this may be meant. But the word "snack" on a piece that needs no snack will confuse.</li>
</ul>

{h3('10.21', 'Legendary Heal pieces are hard to place', NW)}
<ul>
<li>A legendary piece has mind edges on top and bottom. A Heal piece also has a mind hole on the left. That is three mind sides out of four; only the right knob differs.</li>
<li>Earwig, seed 2, turn 4: I held Pecan Pie and Buckthorn Zing and neither had a single cell, flipped or not. Both went to the discard. {P}</li>
<li>They always fit beside the Blank in round 1. After that they need a mind knob next to a free cell: a Critter's pieces, a Rain, another crop piece.</li>
<li>8 of the 42 legendary pieces are Heals, and both Simmer pieces and one of the two Plenty pieces are among them. A piece you waited three harvests for may sit dead in the hand more often than its number suggests. I did not measure how often. {Q}</li>
</ul>
""")

# ------------------------------------------------------------------ appendix A
w(h2('A', 'Four fights, turn by turn'))
w(f"""
<p>All four were played again by hand on the 2.6.990 engine with <code>tests/pf_play.php</code> (mode <code>v1</code>), the gnome at the creature's level, with the same creatures and seeds as in the 2.6.986 edition. They are different fights now: the test gnome's deck is thinner (10.13), the Critter rule is new, poison is flat. On the page cell 2,1 is called C2. For each move I looked at every hand piece, both ways up, on every legal cell, with the plan line the page would show. Cells are x,y from the top left. State files and logs are in <code>rulebook/play/</code> (<code>f1</code> to <code>f4</code>; the 2.6.986 states are kept in <code>play/old986/</code>).</p>
<table class="keep">
<thead><tr><th>Fight</th><th class="num">2.6.986: won on turn</th><th class="num">health left</th><th class="num">2.6.990: won on turn</th><th class="num">health left</th></tr></thead>
<tbody>
<tr><td>A.1 Pincer Earwig, level 4, seed 11</td><td class="num">3</td><td class="num">26 of 32</td><td class="num">8</td><td class="num">21 of 32</td></tr>
<tr><td>A.2 Carrion Crow, level 9, seed 5</td><td class="num">7</td><td class="num">45 of 47</td><td class="num">10</td><td class="num">39 of 47</td></tr>
<tr><td>A.3 Wild Boar, level 21, seed 3</td><td class="num">6</td><td class="num">54 of 88</td><td class="num">7</td><td class="num">71 of 88</td></tr>
<tr><td>A.4 Great Hawk, level 28, seed 9</td><td class="num">4</td><td class="num">105 of 114</td><td class="num">7</td><td class="num">98 of 114</td></tr>
</tbody></table>

{h3('A.1', 'Small Critter: Pincer Earwig, level 4, seed 11')}
<p>Yield bar 42.8. My health 32. Rule: Swarm (the new one). Won on turn 8 with 21 health. Its pieces are 4 and 5 now, against my 3 to 6.</p>
<table class="turn">
<thead><tr><th>Turn</th><th>What I saw</th><th>What I did and why</th><th>Result</th></tr></thead>
<tbody>
<tr><td>Start</td><td>Hand: Chop 5, Hoe Hook 4 (Pierce), Dodge 5, Pierce 4, Bark Badger 6. Blank on 1,1.</td><td>Chop below the Blank. A Guard can then go on its right.</td><td>Earwig put Night Scuttle (Trick 2, Quick) left of the Blank.</td></tr>
<tr><td>1</td><td>Aim: Nip, Hurt 5, on 0,0, "hits you for 5". Hoe Hook right of Chop reads +11. Dodge there reads +8 with 5 guard, and the chip falls to 0.</td><td>Dodge on 2,2. Three bar points less, five health more.</td><td>Riposte 8. Nip fully blocked.</td></tr>
<tr><td>2</td><td>Aim: Humus Hide (Guard 4) beside a Sun: 8 guard for it. Slip Past below Chop reads +14, chain of 3.</td><td>Slip Past on 1,3: the biggest number, before its guard is up.</td><td>Ambush 14. Bar 22. My three pieces used up. It holds 8 guard.</td></tr>
<tr><td>3</td><td>Aim: Pincer 5 (Pierce) on 0,2, "hits you for 17, combo Ambush": Pincer 6, then through Night Scuttle Nip 11. Both carry +1: it has 3 other pieces out. Its guard 8: my Swing reads 2.</td><td>Flipped Brace on 1,2. It touches the aim cell with an edge that does not fit: the aim is broken. It also fires a Bramble (+4.3) and gives 4 guard.</td><td>Bar 26.3. It picked again: Skitter with the Sun and its Humus Hide, 8 guard, a chain of 3 that used up its own pieces. Night Scuttle and Nip expired. I lost nothing.</td></tr>
<tr><td>4</td><td>Its guard 8. Aim: Pincer on 1,0, "hits you for 5, fires Rain". Pierce on 1,1: +8.3 (4 through its guard, Bramble 4.3), chain of 3 with Brace.</td><td>Pierce on 1,1. Guard is no use against a Pierce piece anyway.</td><td>Bar 34.6. Pincer 5 through my 8 guard. Rain gave it 6 guard. Health 27.</td></tr>
<tr><td>5</td><td>Its guard 9. Swing and Bark Badger have no cell. No cell adds to the bar. Rest on 1,1 links its Chitin Shell and a Sun: heals 5, uses both up.</td><td>Rest. It heals, takes the Sun away from the aim, and removes one of its pieces.</td><td>Health 32. The aim was broken; it put its Humus Hide down on another cell.</td></tr>
<tr><td>6</td><td>Its guard 4. Aim: Sting 4 on 3,2, "hits you for 5, fires Rain" (+1: two other pieces out). Charm on 2,0: +3, fires the Rain for me (5 guard), chain of 3 uses up the Rain and Night Scuttle. Chip then: 0.</td><td>Charm on 2,0. Charm ignores its guard, the Rain is mine, and with one piece fewer its Sting loses the +1.</td><td>Bar 37.6. Sting 4, fully blocked. Humus Hide fell (second firing).</td></tr>
<tr><td>7</td><td>Aim: Nip on 3,1, "hits you for 13, combo Double Swing" (6 and 7 with +1 each). Every cell costs health: it touches a Thornburst (3) or its Sting. Pass: 13. Frost Bark on 1,2: 0 to the bar, 7 in all. Hoe Hook on 1,2: +4, fires its Tuck Under and Sting (6 to me) and uses both up; the aim falls to 5.</td><td>Hoe Hook on 1,2. The worst turn of the fight: 11 health for 4 bar points, but it leaves 1.2 to go and no Swarm.</td><td>Bar 41.6. Sting 6 (Riposte for it), then Nip 5. Health 21.</td></tr>
<tr><td>8</td><td>Jab or Pierce on either free cell ends it.</td><td>Pierce on 1,3.</td><td>Bar 45.6: it backs off. The Rain next to Pierce never fired.</td></tr>
</tbody></table>
<p><b>What a thoughtful player looks at:</b> how many pieces the Critter has out; its guard before swinging; a misfit beside a big aim; which pieces ignore guard. <b>What cost health:</b> the Pierce hit on turn 4 (5) and the price of finishing on turn 7 (11). <b>Against 2.6.986:</b> five turns longer. Then its hits were 3; now they are 5 to 7, and a 17 was on the table.</p>

{h3('A.2', 'Medium Bird: Carrion Crow, level 9, seed 5')}
<p>Yield bar 74.6. My health 47. Rule: Two aims. Won on turn 10 with 39 health. On every turn my loss was exactly what the chip said after I placed.</p>
<table class="turn">
<thead><tr><th>Turn</th><th>What I saw</th><th>What I did and why</th><th>Result</th></tr></thead>
<tbody>
<tr><td>Start</td><td>Hand: Jab 5, Sow Doubt (Trick 8), Hum, Bark Badger 8, Dodge 7. Blank on 1,1.</td><td>Jab below the Blank: Sow Doubt can go on its right.</td><td>Crow put Flutter Off (Trick 1, Evade) above the Blank.</td></tr>
<tr><td>1</td><td>Aim 1: Mob Caw 3 (Quick) on 0,1. Aim 2: the same on 2,1. "hits you for 3 · 2 pieces". With a piece on aim 1 the chip reads 9. Sow Doubt on 2,2 reads +16.</td><td>Sow Doubt on 2,2, away from both aims.</td><td>Ambush 16. Mob Caw 3. Its Quick extra, Hat Snatch, tripped me and fired Flutter Off: "dodges next hit". Health 44.</td></tr>
<tr><td>2</td><td>Hand of 4. Evade up. Aim: Dive Bomb 4 (Pierce), Double Swing with Mob Caw, 9. Samara Spin reads +7 and leaves the 9. Flipped Brace below Jab: +0 (the Riposte will miss), 6 guard, chip 4.</td><td>Flipped Brace on 1,3. A Guard, not a Hurt, into an Evade.</td><td>Dive Bomb 4 through the guard, Mob Caw blocked. Its chain of 4 used its pieces up, but fired Flutter Off and Hat Snatch first: Evade and trip again. Health 40.</td></tr>
<tr><td>3</td><td>Hand of 4. Evade up. Both aims (Peck 4) stand beside a Sun: 8. Flipped Oat Cake on 0,1 fires a Rain and its Heat Shimmer: 14 guard, both used up.</td><td>Oat Cake. It blocks the 8, denies the Rain, and removes an Evade piece.</td><td>Peck 8, blocked. 6 guard held (Hold).</td></tr>
<tr><td>4</td><td>No Evade. Aim: Talon Dive beside the Sun, with its Peck: 16, less my 6. Chop on 2,1: Sun for me, 14; fires Peck at me (4, into my guard); chain of 3 uses up Sun and Peck. Chip then: 2.</td><td>Chop on 2,1.</td><td>Bar 30. Talon Dive 4 less 2 guard. Health 38.</td></tr>
<tr><td>5</td><td>Aim: Flutter Off, Ambush on Talon Dive: 7. Samara Spin on 2,2: +8, fires Talon Dive at me (4). That is its second firing: it falls, and the chip reads 0. Charm beside a new Sun: +8.4 and the 7 stays.</td><td>Samara Spin on 2,2.</td><td>Bar 38. Health 34. Flutter Off landed: Evade.</td></tr>
<tr><td>6</td><td>"dodges next hit". Aim: Dive Bomb 4 (Pierce), fires Rain. Jab reads +10 but costs 5 (Thornburst) and the 4. Flipped Snack beside the Sun heals 13.</td><td>Flipped Snack on 0,1. No Hurt into an Evade; heal while the Sun is there.</td><td>Health 47, then Dive Bomb: 43. Rain gave it 11 guard, and Flutter Off fired again.</td></tr>
<tr><td>7</td><td>Its guard 11, Evade. Aim: Mob Caw beside the Sun and my Snack: the harness chip read "-2" (10.19). Flipped Brace on 3,0 beside a Bramble: +7.5, 6 guard, a chain of 2.</td><td>Brace on 3,0. The Bramble ignores guard and Evade, and it stays.</td><td>Bar 45.5. Mob Caw 6 blocked. Its chain fired my Snack: +4 health. Tripped again. Health 47.</td></tr>
<tr><td>8</td><td>Hand of 4. Aim: Talon Dive on 1,2, fires a second Bramble: 9. Swing on 0,2 fires that Bramble first: +14.4, chain of 3 with Flutter Off. Chip then: 4.</td><td>Swing on 0,2: the Bramble for me instead of for it.</td><td>Bar 59.9. Health 43.</td></tr>
<tr><td>9</td><td>Aim: Dive Bomb with Talon Dive, 10. Brace and the first Bramble are in their last round. Flipped Bark Badger on 3,2: Bramble again, +7.5, 14 guard. Chop on 2,0 reads +14.5 but costs 5 and leaves 4.</td><td>Bark Badger on 3,2: use what is leaving.</td><td>Bar 67.4. The Pierce hit of 4 landed. Health 39.</td></tr>
<tr><td>10</td><td>Three cells end it.</td><td>Swing on 2,1 beside a new Bramble.</td><td>Bar 81.8: it backs off.</td></tr>
</tbody></table>
<p><b>What a thoughtful player looks at:</b> "dodges next hit" (on 4 of 10 turns); Pierce on its aim; which Bramble the aim would fire; which pieces leave this round. <b>What cost health:</b> seven hits of 2 to 4, 25 in all, most of them Pierce. Snack gave 17 back. <b>Against 2.6.986:</b> then the Quick extra piece cost 9 health the chip had not shown. Now the chip was right every turn.</p>

{h3('A.3', 'Large Beast: Wild Boar, level 21, seed 3')}
<p>Yield bar 171.8. My health 88. Rule: Grudge. Won on turn 7 with 71 health.</p>
<table class="turn">
<thead><tr><th>Turn</th><th>What I saw</th><th>What I did and why</th><th>Result</th></tr></thead>
<tbody>
<tr><td>Start</td><td>Hand: Glare (Charm 13, Lull), Smash 14, Jab 10, Oat Cake (Guard 11, Hold), Chop 16. Blank on 1,2.</td><td>Chop below the Blank, with the cell to its right free.</td><td>Boar put Shoulder Barge (Trick 3, Bash) left of the Blank.</td></tr>
<tr><td>1</td><td>Aim: Slam 7. Smash right of Chop: +32 and the 7 lands. Oat Cake there: +24, 11 guard, chip 0.</td><td>Oat Cake on 2,3.</td><td>Riposte 24. Slam blocked. 4 guard held.</td></tr>
<tr><td>2</td><td>Aim: Boar Rush 6 (Bash), Double Swing with Slam, 11. Flipped Lull on 2,2 links Oat Cake and Chop: +30.6, chain of 3, "it loses its turn".</td><td>Lull on 2,2.</td><td>Bar 54.6 (charm 6.6, Riposte 24). No creature turn. 11 guard held.</td></tr>
<tr><td>3</td><td>Aim: Boar Rush on 2,2, fires a Bramble: 9 through my guard. Pierce on the aim cell: +28.2, but Grudge and a new pick. Pierce on 1,3, beside the Bramble: also +28.2, and the chip adds "fires your Pierce: 11 to it".</td><td>Pierce on 1,3. Bait through the Bramble (figure 8), and no Grudge.</td><td>Bar 82.8. Its chain: Boar Rush blocked, Bramble -9, my Pierce +11. Bar 93.8. Health 79.</td></tr>
<tr><td>4</td><td>Aim: Mud Wallow (Guard 4) on 3,0, "fires Thornburst". Swing on 2,2: +29.2 with Steam and a new Bramble. Lull: +23.8 and no turn for it.</td><td>Swing on 2,2. I want its turn to happen: its own chain will fire the Thornburst.</td><td>Bar 123. Its Thornburst: +8.6. Bar 131.6.</td></tr>
<tr><td>5</td><td>Its guard 4. Aim: Paddy Surge 6 (Bash) on 1,3, the only cell beside a Rain (26 guard for it). Sting on that cell: +6, Poison, Rain for me: 13 guard.</td><td>Sting on the aim cell. It costs a Grudge, it saves 26 guard.</td><td>Bar 137.6, poison tick +5. It picked again with Grudge x1: Paddy Surge 8, blocked. The Grudge stayed.</td></tr>
<tr><td>6</td><td>Its guard 8, Grudge x1. Aim: Tusk Gore (Pierce) 9 and Maul 10, "hits you for 19", fires my Sting and the Rain. Jab: +14, 8 health, and 9 more to come. Glare on 2,2: +9.8, fires Maul at me (8) and the Rain for me, chain of 4, "it loses its turn".</td><td>Glare on 2,2. It takes Maul, Sting and the Rain off the board and cancels a 19.</td><td>Bar 152.4, poison tick +5 on its lost turn: 157.4. Health 71.</td></tr>
<tr><td>7</td><td>Chop ends it on four cells.</td><td>Chop beside a Sun: 32.</td><td>Bar 189.4: it backs off.</td></tr>
</tbody></table>
<p><b>What a thoughtful player looks at:</b> Lull when it links two pieces; a cell beside the aim that fits (bait); whether a block will add Grudge; who gets the Rain. <b>What cost health:</b> the Bramble in its chain (9) and Maul in mine (8). <b>Against 2.6.986:</b> one turn longer, 17 health better. The poison did less (two ticks of 5, flat); Lull did more.</p>

{h3('A.4', 'Boss: Great Hawk, level 28, seed 9')}
<p>Yield bar 215.2. My health 114. Rule: Two turns. Won on turn 7 with 98 health.</p>
<table class="turn">
<thead><tr><th>Turn</th><th>What I saw</th><th>What I did and why</th><th>Result</th></tr></thead>
<tbody>
<tr><td>Start</td><td>Hand: Sting (Hurt 13, Poison), Pierce 14, Frost Bark (Guard 14, Hold), Jab 13, Lull 14. Blank on 2,2.</td><td>Sting left of the Blank. Frost Bark can go on its left.</td><td>The Hawk put out two pieces: Flutter Off and Wing Cover.</td></tr>
<tr><td>1</td><td>Aim: Crush 10. Next round: Talon Dive. Pierce below Sting: +29, and the 10 lands. Frost Bark on 0,2: +20, 14 guard, chip 0.</td><td>Frost Bark on 0,2.</td><td>Riposte 20. Poison tick 7: half of Sting's printed 13, not of the 20. Crush blocked; its chain fired Flutter Off. 4 guard held.</td></tr>
<tr><td>2</td><td>"dodges next hit", its guard 5. Aim: Talon Dive, fires Rain. No cell of mine can use the Rain up. Flipped Swing on 0,1: Swing takes the miss, then Frost Bark, Sting with Riposte (20 less 5), its Island Time. Chain of 4.</td><td>Swing on 0,1: let the weakest Hurt take the miss.</td><td>Bar 42, tick 7: 49. Talon Dive blocked. The Rain gave it 32 guard.</td></tr>
<tr><td>3</td><td>Its guard 38: Swing and Chop read 0. Aim: Peck with Talon Dive, 10, fires the Rain again. Hoe Hook (Pierce 18) with a Bramble: +39.5, and the 10 and the Rain stay. Hoe Hook on the aim cell 0,1: +18, fires Talon Dive (into my guard) and the Rain for me (17 guard), chain of 3.</td><td>Hoe Hook on 0,1. The chain uses up the Rain, Talon Dive and Hoe Hook itself, so the cell is free again and the aim lands on nothing.</td><td>Bar 67, last tick 7: 74. Peck blocked. No health lost. Its guard next turn: 0.</td></tr>
<tr><td>4</td><td>Aim: Talon Grip 8 (Trip) beside the Bramble: 19. Smash on the aim cell: +38.5, then 8 and a trip. Glare (Charm 16, Lull) on 2,2: +31.1 with the Bramble, chain of 3, no creature turn.</td><td>Glare on 2,2.</td><td>Bar 105.1.</td></tr>
<tr><td>5</td><td>Aim: Talon Grip again (it is forced), on 2,0 beside a Sun: 16. Chop on 3,1 beside that Sun: 38, a chain of 2. The chip adds "fires your Chop: 19 to it".</td><td>Chop on 3,1: 57 bar points for 16 health, at full health.</td><td>Bar 143.1. Talon Grip 16 and a trip. My Chop again: 162.1. Health 98.</td></tr>
<tr><td>6</td><td>Hand of 4. Aim: Crush beside a second Sun: 20. Lull on 2,3 beside that Sun: 28 charm, 16.8 on the bar, no creature turn.</td><td>Lull on 2,3.</td><td>Bar 178.9.</td></tr>
<tr><td>7</td><td>Hoe Hook on 0,3 links the Sun and Lull: 36 + 16.8.</td><td>Hoe Hook on 0,3.</td><td>Bar 231.7: it backs off.</td></tr>
</tbody></table>
<p><b>What a thoughtful player looks at:</b> the Evade chip; who gets the Rain; the forced next piece; Sun plus a piece that will be fired twice. <b>What cost health:</b> one hit of 16, taken on purpose. <b>Against 2.6.986:</b> three turns longer. Then one poison tick of 44 ended the fight on turn 4. Now the three ticks I got were 7 each.</p>

{h3('A.5', 'The three new tags: two short fights with legendary pieces')}
<p>The harness cannot deal a legendary piece. For these two fights I used a copy of it (<code>play/pf_play_legend.php</code>) whose only change is that the test gnome has harvested three treasure crops and switched their pieces on: Cranberry Preserve (Keeper), Buckthorn Zing (Plenty), Pecan Pie (Simmer). Pincer Earwig, level 4. I did not play these to win but to see the tags. States and logs: <code>play/L1</code>, <code>play/L2</code>.</p>
<table class="turn">
<thead><tr><th>Fight, turn</th><th>What I did</th><th>What the engine did</th></tr></thead>
<tbody>
<tr><td>Seed 2, turn 1</td><td>Flipped Cranberry Preserve, then placed another piece.</td><td>Next hand: Cranberry Preserve, still flipped, and 4 new pieces.</td></tr>
<tr><td>Seed 2, turns 2 to 4</td><td>Never played it.</td><td>It was in every hand. 4 new pieces a round.</td></tr>
<tr><td>Seed 2, turn 4</td><td>Held Buckthorn Zing and Pecan Pie.</td><td>Neither had a legal cell, flipped or not (10.21). Both were discarded.</td></tr>
<tr><td>Seed 3, turn 1</td><td>Placed Buckthorn Zing (Plenty) beside my Chop.</td><td>Next hand: 6 pieces: the Keeper and 5 new ones.</td></tr>
<tr><td>Seed 3, turn 2</td><td>Placed Pecan Pie (Simmer) at 27 of 32 health.</td><td>Healed 5 at once. The Earwig then hit for 14 (the chip had said 14). As turn 3 started: 18 to 20. Hand back to 5.</td></tr>
<tr><td>Seed 3, turn 3</td><td>Another piece.</td><td>Hit for 4. As turn 4 started: 16 to 18.</td></tr>
<tr><td>Seed 3, turn 4</td><td>Passed.</td><td>No more Simmer heal. The Keeper was still in the hand.</td></tr>
</tbody></table>
""")

# ------------------------------------------------------------------ appendix B
w(h2('B', 'Numbers from my play runs'))
w(f"""
<p>Besides the hand-played fights I ran <b>684 whole fights</b> on the 2.6.990 engine with six fixed ways of choosing a move (<code>rulebook/play/sim.php</code>). These are the same policies, creatures and seeds as in the 2.6.986 edition, run again; every number on this page is new. Each policy played the same 19 creatures on seeds 1 to 6, with the test gnome at the creature's level. Every policy sees what the page shows: the lit-cell numbers and the aim total after placing. Every policy takes a winning move when one exists.</p>
<p class="small">Creatures: Aphid Swarm, Pincer Earwig, Cave Glowworm (small); Orb Spider, Carrion Crow, Bog Leech, Thistle Beast, Sun Lizard, Frost Hare (medium); Wild Boar, Grass Snake, Grey Heron, Bog Pike, Moss Golem (large); Great Hawk, Old Bramblehorn, Jade Jaguar, Dune Wyrm, Reef Leviathan (boss). 114 fights per policy: a difference of under about 8 points in a win rate is noise. Raw rows: <code>rulebook/play/runs.jsonl</code> (the 2.6.986 rows are kept as <code>runs_986.jsonl</code>).</p>
<p class="small">Three things differ from the 2.6.986 run besides the rules. The test gnome's deck is thinner: its crop, craft and region pieces arrive off now (10.13). The driver counts poison ticks on its own, so the table can show the loss above the chip with and without them. And on a pass it compares the loss with the chip as it stood before the pass (the old driver read the next round's chip there; passes are 0.05 a fight, so this moves nothing).</p>
<table class="keep">
<thead><tr><th>Policy</th><th>How it chooses</th><th class="num">Wins</th><th class="num">Health lost</th><th class="num">Turns</th><th class="num">Lost in its own chains</th><th class="num">Passes a fight</th></tr></thead>
<tbody>
<tr><td><b>Careful</b></td><td>Bar share gained, minus health share lost in its chain and to the aim afterwards.</td><td class="num">99%</td><td class="num">29%</td><td class="num">7.8</td><td class="num">6%</td><td class="num">0.05</td></tr>
<tr><td>Careful, never breaks the aim</td><td>The same, but avoids taking or breaking the aim cell.</td><td class="num">100%</td><td class="num">38%</td><td class="num">8.6</td><td class="num">8%</td><td class="num">0.13</td></tr>
<tr><td>Charmer</td><td>Careful, but counts charm double.</td><td class="num">100%</td><td class="num">32%</td><td class="num">7.8</td><td class="num">8%</td><td class="num">0.04</td></tr>
<tr><td>Turtle</td><td>Least health lost first.</td><td class="num">100%</td><td class="num">24%</td><td class="num">10.2</td><td class="num">5%</td><td class="num">0.25</td></tr>
<tr><td>Biggest number</td><td>The cell that adds most to the bar. Ignores cost and aim.</td><td class="num">89%</td><td class="num">63%</td><td class="num">6.6</td><td class="num">12%</td><td class="num">0.04</td></tr>
<tr><td>Longest chain</td><td>The cell that fires most pieces.</td><td class="num">63%</td><td class="num">80%</td><td class="num">7.7</td><td class="num">25%</td><td class="num">0.02</td></tr>
</tbody></table>
<p>"Health lost" is the share of maximum health missing at the end of the fight, averaged over all fights. "Lost in its own chains" is health lost to creature Hurts and Thornbursts that the player's own chain fired. The last two policies only pass when no piece has a legal cell.</p>
<table class="keep">
<thead><tr><th>By creature size</th><th class="num">small</th><th class="num">medium</th><th class="num">large</th><th class="num">boss</th></tr></thead>
<tbody>
<tr><td>Careful: wins</td><td class="num">100%</td><td class="num">97%</td><td class="num">100%</td><td class="num">100%</td></tr>
<tr><td>Careful: health lost</td><td class="num">31%</td><td class="num">32%</td><td class="num">25%</td><td class="num">28%</td></tr>
<tr><td>Careful: turns</td><td class="num">6.6</td><td class="num">8.1</td><td class="num">7.4</td><td class="num">8.7</td></tr>
<tr><td>Biggest number: wins</td><td class="num">94%</td><td class="num">81%</td><td class="num">93%</td><td class="num">90%</td></tr>
<tr><td>Biggest number: health lost</td><td class="num">64%</td><td class="num">68%</td><td class="num">53%</td><td class="num">66%</td></tr>
<tr><td>Longest chain: wins</td><td class="num">72%</td><td class="num">56%</td><td class="num">73%</td><td class="num">57%</td></tr>
<tr><td>Careful: real loss above the aim chip (share of turns)</td><td class="num">1%</td><td class="num">39%</td><td class="num">19%</td><td class="num">16%</td></tr>
<tr><td>The same, poison ticks taken out</td><td class="num">1%</td><td class="num">1%</td><td class="num">2%</td><td class="num">2%</td></tr>
<tr><td>Careful: health lost to poison ticks</td><td class="num">0%</td><td class="num">10%</td><td class="num">3%</td><td class="num">3%</td></tr>
<tr><td>Careful: turns that start with none of my pieces out</td><td class="num">50%</td><td class="num">49%</td><td class="num">51%</td><td class="num">49%</td></tr>
</tbody></table>
<table class="keep">
<thead><tr><th>Careful player, by class rule</th><th class="num">Fights</th><th class="num">Wins</th><th class="num">Health lost</th><th class="num">Turns</th><th class="num">2.6.986: health lost</th></tr></thead>
<tbody>
<tr><td>Water (Current)</td><td class="num">12</td><td class="num">100%</td><td class="num">19%</td><td class="num">8.1</td><td class="num">32%</td></tr>
<tr><td>Plant (Grows)</td><td class="num">12</td><td class="num">100%</td><td class="num">19%</td><td class="num">6.2</td><td class="num">21%</td></tr>
<tr><td>Beast (Grudge)</td><td class="num">12</td><td class="num">100%</td><td class="num">24%</td><td class="num">7.0</td><td class="num">9%</td></tr>
<tr><td>Critter (Swarm)</td><td class="num">24</td><td class="num">100%</td><td class="num">28%</td><td class="num">6.9</td><td class="num">27%</td></tr>
<tr><td>Boss (Two turns)</td><td class="num">30</td><td class="num">100%</td><td class="num">28%</td><td class="num">8.7</td><td class="num">18%</td></tr>
<tr><td>Bird (Two aims)</td><td class="num">12</td><td class="num">92%</td><td class="num">40%</td><td class="num">8.5</td><td class="num">19%</td></tr>
<tr><td>Reptile (Venom trail)</td><td class="num">12</td><td class="num">100%</td><td class="num">47%</td><td class="num">8.9</td><td class="num">46%</td></tr>
</tbody></table>
<p class="small">These are my own runs, with my own policies. They are not the tuner's bots and should not be compared with the changelog's figures. With 12 fights a class, a swing like Beast 9% to 24% or Bird 19% to 40% can be the thinner deck, the new rules or chance; I cannot say which. {Q} What holds across both editions: the gap between "careful" and "biggest number" (29% against 63% of health lost). Reading the cost of a cell is worth more than any chain. And one thing clearly changed: the aim chip is now right unless poison is involved.</p>
""")

# ------------------------------------------------------------------ appendix C
LEG = json.load(open(os.path.join(HERE, 'play', 'legend.json')))
TYPE = {'hurt': 'Hurt', 'guard': 'Guard', 'heal': 'Heal', 'charm': 'Charm', 'soothe': 'Soothe', 'trick': 'Trick', 'item': 'Item'}
TAGN = {'keep': 'Keeper', 'plenty': 'Plenty', 'simmer': 'Simmer', 'pierce': 'Pierce', 'bash': 'Bash', 'hold': 'Hold', 'pluck': 'Pluck', 'bond': 'Bond', 'evade': 'Evade', 'hum': 'Hum', 'lull': 'Lull', 'poison': 'Poison', 'trip': 'Trip', 'thorns': 'Thorns'}
MODN = {'tender': 'Tender', 'leech': 'Leech', 'spiky': 'Spiky', 'soft': 'Soft touch', 'warm': 'Warm', 'finisher': 'Finisher', 'hardy': 'Hardy'}
rows = []
for q in sorted(LEG, key=lambda q: (q['region'], q['n'])):
    extra = ', '.join(x for x in [TAGN.get(q['tag'], ''), MODN.get(q['mod'], '')] if x) or 'plain'
    if q['tag'] in ('keep', 'plenty', 'simmer'):
        extra = '<b>' + extra + '</b>'
    rows.append(f"<tr><td>{q['region']}</td><td>{q['crop'].replace('-', ' ')}</td><td><b>{q['n']}</b></td><td>{TYPE[q['t']]} {q['v']}</td><td>{q['r']}</td><td>{extra}</td><td>{q['blurb']}</td></tr>")
w(h2('C', 'The 42 legendary crop pieces'))
w(f"""
<p>One piece per treasure crop, three per region. Yours after 3 harvests of that crop (3.7). "Base" is the number before your stat, a third of your level and the rank bonus are added. The right knob decides what can go to its right; the left hole follows the type; top and bottom are mind for all 42. Read from <code>data/pf_pieces.txt</code> on 2.6.990. {C} Played: Cranberry Preserve, Buckthorn Zing, Pecan Pie. {P} The three new tags are in bold.</p>
<table class="leg">
<thead><tr><th>Region</th><th>Crop</th><th>Piece</th><th>Type, base</th><th>Right knob</th><th>Tag, knack</th><th>The piece's own line</th></tr></thead>
<tbody>
{''.join(rows)}
</tbody></table>
<p class="small">By type: 11 Hurt, 10 Guard, 8 Heal, 7 Charm, 3 Item, 2 Soothe, 1 Trick. By extra: 23 with a tag, 16 with a knack (Wasabi Burn has both), 4 plain. Region codes are those of <code>region_crops.txt</code>.</p>
""")

body = '\n'.join(B)

toc = ['<div class="toc"><h2>Contents</h2><ol>']
for lvl, hid, num, title in heads:
    pg = pages.get(hid, '')
    toc.append(f'<li class="l{lvl}"><span class="tn">{num}</span><span>{title}</span><span class="dots"></span><span class="pg">{pg}</span></li>')
toc.append('</ol></div>')

cover = f"""
<div class="cover">
  <div style="margin: 0 auto 18pt">{figs.svg(300, 150, figs.piece(20, 15, 120, 'Slip Past', 'Trick 6', figs.SLIP) + figs.piece(20 + 116, 15, 120, 'Chop', 'Hurt 5', {'L': 'hb', 'R': 'kb', 'T': 'kc', 'B': 'hc'}), 'Two linked pieces')}</div>
  <h1>Puzzle Combat</h1>
  <div class="sub">The rule book for the v1 board</div>
  <div class="rule"></div>
  <div class="meta">
    Gnome Venture 2.7.00 (<code>main</code>, 15 November 2026)<br>
    Written for the owner's review. Third edition, 15 November 2026<br>
    (second edition: 2.6.990. First edition: 14 November 2026, for 2.6.986)<br>
    Rules as a <b>new fight</b> plays them today: 4 by 4 board, one shared Yield bar, class rules on<br><br>
    Every rule here was read in the code (<code>game/includes/pfboard.php</code>, <code>pfight.php</code>, <code>pfdeck.php</code>, the data files).<br>
    The new 2.7.00 rules (chain order, the missing free piece, wearables) are read in the code only.<br>
    The played fights and the 684 policy fights are from the 2.6.990 edition and were <b>not</b> redone.<br>
    No game file was changed. No rule was invented.
  </div>
  <div class="meta" style="margin-top:22pt">
    {P} seen in my own play on 2.6.990 (not redone for 2.7.00) &nbsp;&nbsp; {C} read in the code only &nbsp;&nbsp; {Q} could not verify
  </div>
</div>
"""

html = f"""<!doctype html>
<html lang="en"><head><meta charset="utf-8">
<title>Puzzle Combat: the rule book for the v1 board (2.7.00)</title>
<style>{CSS}</style></head>
<body>
{cover}
{''.join(toc)}
{body}
</body></html>
"""
open(os.path.join(HERE, 'puzzle-combat-rulebook.html'), 'w').write(html)
json.dump([[hid, num, title] for _, hid, num, title in heads], open(os.path.join(HERE, 'play', 'heads.json'), 'w'))
print('written', len(html), 'bytes;', len(heads), 'headings')
