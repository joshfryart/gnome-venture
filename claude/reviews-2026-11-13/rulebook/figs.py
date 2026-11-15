# Inline SVG figures for the rule book (no external resources). Used by build.py.
OWN = {'me': ('#f6e7bf', '#8a6a1f'), 'foe': ('#f3cdc8', '#9b3b33'), 'env': ('#d9ead0', '#4d7a3a'), 'none': ('#eeeeee', '#888888')}
FAM = {'b': 'body', 'm': 'mind', 'c': 'craft'}


def _shape(fam, cx, cy, r, ang, fill, stroke):
    """One edge mark centred at cx,cy: body = circle, mind = keyhole, craft = triangle. ang = rotation in degrees (0 = pointing right)."""
    if fam == 'b':
        s = f'<circle cx="0" cy="0" r="{r}"/>'
    elif fam == 'm':
        s = f'<path d="M {-r*0.2},{-r*0.45} L {-r*1.0},{-r*0.45} L {-r*1.0},{r*0.45} L {-r*0.2},{r*0.45} A {r*0.8} {r*0.8} 0 1 0 {-r*0.2},{-r*0.45} Z"/>'
    else:
        s = f'<path d="M {r},0 L {-r*0.8},{-r} L {-r*0.8},{r} Z"/>'
    return f'<g transform="translate({cx:.1f},{cy:.1f}) rotate({ang})" fill="{fill}" stroke="{stroke}" stroke-width="1.6" stroke-linejoin="round">{s}</g>'


def piece(x, y, S, name, line2, edges, owner='me', badge=None, dashed=False, faded=False):
    """A piece in a cell of size S with its top-left at x,y. edges: dict L/R/T/B -> 'kb' (knob body), 'hm' (hole mind), 'w' wild, 'f' flat."""
    fill, stroke = OWN[owner]
    pad = S * 0.13
    r = S * 0.085
    op = ' opacity="0.45"' if faded else ''
    o = [f'<g{op}>']
    dash = ' stroke-dasharray="5 4"' if dashed else ''
    o.append(f'<rect x="{x+pad:.1f}" y="{y+pad:.1f}" width="{S-2*pad:.1f}" height="{S-2*pad:.1f}" rx="7" fill="{fill}" stroke="{stroke}" stroke-width="1.8"{dash}/>')
    mid = {'L': (x + pad, y + S / 2, 180), 'R': (x + S - pad, y + S / 2, 0), 'T': (x + S / 2, y + pad, 270), 'B': (x + S / 2, y + S - pad, 90)}
    vec = {'L': (-1, 0), 'R': (1, 0), 'T': (0, -1), 'B': (0, 1)}
    for side, e in edges.items():
        cx, cy, ang = mid[side]
        dx, dy = vec[side]
        if e == 'w':
            o.append(f'<text x="{cx - dx*r*1.5:.1f}" y="{cy - dy*r*1.5 + 3.5:.1f}" font-size="{S*0.12:.1f}" text-anchor="middle" fill="{stroke}">*</text>')
            continue
        if e == 'f':
            continue
        kind, fam = e[0], e[1]
        if kind == 'k':   # knob: solid, sticks out
            o.append(_shape(fam, cx + dx * r * 0.75, cy + dy * r * 0.75, r, ang, stroke, stroke))
        else:             # hole: hollow, cut in
            o.append(_shape(fam, cx - dx * r * 1.05, cy - dy * r * 1.05, r, ang, '#ffffff', stroke))
    o.append(f'<text x="{x+S/2:.1f}" y="{y+S/2-2:.1f}" font-size="{S*0.135:.1f}" font-weight="700" text-anchor="middle" fill="#222">{name}</text>')
    if line2:
        o.append(f'<text x="{x+S/2:.1f}" y="{y+S/2+S*0.16:.1f}" font-size="{S*0.125:.1f}" text-anchor="middle" fill="#333">{line2}</text>')
    if badge:
        o.append(f'<circle cx="{x+S-pad-2:.1f}" cy="{y+pad+2:.1f}" r="{S*0.11:.1f}" fill="#222"/><text x="{x+S-pad-2:.1f}" y="{y+pad+2+S*0.045:.1f}" font-size="{S*0.14:.1f}" font-weight="700" text-anchor="middle" fill="#fff">{badge}</text>')
    o.append('</g>')
    return ''.join(o)


def grid(x, y, S, w=4, h=4, labels=True):
    o = [f'<rect x="{x}" y="{y}" width="{S*w}" height="{S*h}" fill="#fbf8f1" stroke="#8c8577" stroke-width="1.5"/>']
    for i in range(1, w):
        o.append(f'<line x1="{x+i*S}" y1="{y}" x2="{x+i*S}" y2="{y+S*h}" stroke="#cfc8b8" stroke-width="1"/>')
    for j in range(1, h):
        o.append(f'<line x1="{x}" y1="{y+j*S}" x2="{x+S*w}" y2="{y+j*S}" stroke="#cfc8b8" stroke-width="1"/>')
    if labels:
        for i in range(w):
            o.append(f'<text x="{x+i*S+S/2}" y="{y-5}" font-size="10" text-anchor="middle" fill="#777">{i}</text>')
        for j in range(h):
            o.append(f'<text x="{x-8}" y="{y+j*S+S/2+3}" font-size="10" text-anchor="middle" fill="#777">{j}</text>')
    return ''.join(o)


def aim(x, y, S, label='AIM'):
    cx, cy = x + S / 2, y + S / 2
    return (f'<circle cx="{cx}" cy="{cy}" r="{S*0.3}" fill="none" stroke="#c0392b" stroke-width="2.2"/><circle cx="{cx}" cy="{cy}" r="{S*0.12}" fill="none" stroke="#c0392b" stroke-width="2.2"/>'
            f'<text x="{cx}" y="{y+S-6}" font-size="9.5" font-weight="700" text-anchor="middle" fill="#c0392b">{label}</text>')


def svg(w, h, body, title=''):
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}" width="{w}" height="{h}" role="img" aria-label="{title}" font-family="Inter, DejaVu Sans, sans-serif">{body}</svg>'


def note(x, y, text, size=10.5, anchor='start', bold=False, color='#333'):
    fw = ' font-weight="700"' if bold else ''
    return f'<text x="{x}" y="{y}" font-size="{size}" text-anchor="{anchor}" fill="{color}"{fw}>{text}</text>'


def arrow(x1, y1, x2, y2, color='#555'):
    import math
    a = math.atan2(y2 - y1, x2 - x1)
    hx, hy = x2 - 8 * math.cos(a), y2 - 8 * math.sin(a)
    px, py = 4 * math.sin(a), -4 * math.cos(a)
    return (f'<line x1="{x1}" y1="{y1}" x2="{hx:.1f}" y2="{hy:.1f}" stroke="{color}" stroke-width="1.6"/>'
            f'<path d="M {x2},{y2} L {hx+px:.1f},{hy+py:.1f} L {hx-px:.1f},{hy-py:.1f} Z" fill="{color}"/>')


SWING = {'L': 'hb', 'R': 'km', 'T': 'kb', 'B': 'hb'}
CHOP = {'L': 'hb', 'R': 'kb', 'T': 'kc', 'B': 'hc'}
DODGE = {'L': 'hb', 'R': 'kb', 'T': 'hb', 'B': 'kb'}
SLIP = {'L': 'hc', 'R': 'kb', 'T': 'kc', 'B': 'hc'}
CHARM = {'L': 'hm', 'R': 'kc', 'T': 'km', 'B': 'hm'}
WILD = {'L': 'w', 'R': 'w', 'T': 'w', 'B': 'w'}
HUMUS = {'L': 'hb', 'R': 'kb', 'T': 'hb', 'B': 'kb'}
NIP = {'L': 'hb', 'R': 'km', 'T': 'km', 'B': 'hm'}
RAIN = {'L': 'hc', 'R': 'kb', 'T': 'km', 'B': 'hm'}
SUN = {'L': 'hb', 'R': 'km', 'T': 'kc', 'B': 'hc'}
BRAMBLE = {'L': 'hm', 'R': 'kc', 'T': 'kb', 'B': 'hb'}
THORN = {'L': 'hm', 'R': 'kb', 'T': 'hc', 'B': 'kc'}


def fig_anatomy():
    S = 150
    b = piece(120, 30, S, 'Swing', 'Hurt 5', SWING)
    b += note(20, 108, 'left: a HOLE', 10.5) + note(20, 122, '(body, round)', 10.5) + arrow(92, 105, 132, 105)
    b += note(300, 100, 'right: a KNOB', 10.5) + note(300, 114, '(mind, keyhole)', 10.5) + arrow(296, 105, 262, 105)
    b += note(195, 16, 'top: a knob (body)', 10.5, 'middle')
    b += note(195, 202, 'bottom: a hole (body)', 10.5, 'middle')
    # legend
    lx = 420
    b += note(lx, 40, 'Edge families', 11, bold=True)
    for i, (f, nm) in enumerate([('b', 'body: round'), ('m', 'mind: keyhole'), ('c', 'craft: triangle')]):
        yy = 62 + i * 30
        b += _shape(f, lx + 12, yy, 9, 0, '#8a6a1f', '#8a6a1f') + _shape(f, lx + 42, yy, 9, 0, '#fff', '#8a6a1f') + note(lx + 62, yy + 4, nm, 10.5)
    b += note(lx + 2, 152, 'solid = knob', 10) + note(lx + 2, 166, 'hollow = hole', 10)
    b += note(lx + 2, 186, 'A knob fits a hole', 10) + note(lx + 2, 200, 'of the same family.', 10)
    return svg(600, 215, b, 'A piece: name, type and number in the middle, a knob or a hole on each of its four edges')


def fig_fit():
    S = 110
    b = note(10, 16, 'Fits and links', 11, bold=True)
    b += piece(10, 24, S, 'Dodge', 'Guard 5', DODGE) + piece(10 + S - 4, 24, S, 'Chop', 'Hurt 5', CHOP)
    b += note(10 + S - 2, 24 + S + 14, 'body knob into body hole: linked', 10, 'middle', color='#2e6b2e')
    x2 = 300
    b += note(x2, 16, 'Does not fit: you cannot place it there', 11, bold=True)
    b += piece(x2, 24, S, 'Swing', 'Hurt 5', SWING) + piece(x2 + S + 14, 24, S, 'Chop', 'Hurt 5', CHOP)
    b += f'<path d="M {x2+S-2},{24+S/2-12} l 18,24 m 0,-24 l -18,24" stroke="#c0392b" stroke-width="3" fill="none"/>'
    b += note(x2 + S + 7, 24 + S + 14, 'mind knob against body hole', 10, 'middle', color='#c0392b')
    return svg(560, 160, b, 'Left: a body knob in a body hole fits and links. Right: a mind knob does not fit a body hole.')


def fig_flip():
    S = 110
    b = piece(10, 22, S, 'Dodge', 'Guard 5', DODGE) + note(10 + S / 2, 16, 'as dealt: hole on top', 10, 'middle')
    b += arrow(135, 77, 185, 77) + note(160, 68, 'Flip', 10.5, 'middle', bold=True)
    b += piece(200, 22, S, 'Dodge', 'Guard 5', {'L': 'hb', 'R': 'kb', 'T': 'kb', 'B': 'hb'}) + note(200 + S / 2, 16, 'flipped: knob on top', 10, 'middle')
    b += note(330, 50, 'Flip swaps the top and bottom edges.', 10.5) + note(330, 66, 'Left and right stay as they are.', 10.5)
    b += note(330, 90, 'It is free. You may flip any hand piece,', 10.5) + note(330, 106, 'as often as you like, before you place it.', 10.5)
    return svg(600, 140, b, 'Flipping a piece swaps its top and bottom edges')


NSCUT = {'L': 'hc', 'R': 'km', 'T': 'km', 'B': 'hm'}
BRUSH = {'L': 'hb', 'R': 'km', 'T': 'kb', 'B': 'hb'}
PIERCE = {'L': 'hb', 'R': 'km', 'T': 'kb', 'B': 'hb'}
JAB = {'L': 'hb', 'R': 'kc', 'T': 'kb', 'B': 'hb'}
FLUT = {'L': 'hc', 'R': 'kc', 'T': 'kc', 'B': 'hc'}


def fig_opening():
    """2.6.990 replay: Pincer Earwig, level 4, seed 11. Blank on 1,1; my Chop below it; its Night Scuttle left of it; the aim (Nip) on 0,0."""
    S = 76
    gx, gy = 30, 26
    b = grid(gx, gy, S)
    b += piece(gx + 1 * S, gy + 1 * S, S, 'Blank', '', WILD, 'none', dashed=True)
    b += piece(gx + 1 * S, gy + 2 * S, S, 'Chop', 'Hurt 5', CHOP, 'me')
    b += piece(gx + 0 * S, gy + 1 * S, S, 'Night Sc.', 'Trick 2', NSCUT, 'foe')
    b += aim(gx + 0 * S, gy + 0 * S, S)
    tx = gx + 4 * S + 24
    b += note(tx, 44, 'The opening (Pincer Earwig, seed 11)', 11, bold=True)
    lines = ['The Blank sits on one of the four inner cells.', 'It fits every edge. It never fires and', 'no chain runs through it.', '',
             'You put one hand piece beside it (tan).', 'The creature puts its gentlest piece', 'beside it too (rose). Nothing fires.', '',
             'The red mark is the creature’s aim:', 'the cell where its next piece will land.', '', 'The Blank leaves at the end of round 1.']
    for i, t in enumerate(lines):
        b += note(tx, 66 + i * 15, t, 10.5)
    return svg(640, 350, b, 'The 4 by 4 board at the start: the Blank, your start piece, the creature’s start piece and its aim')


def fig_chain():
    """2.6.990 replay, Earwig turn 1: Dodge placed right of Chop: Riposte 8."""
    S = 84
    gx, gy = 24, 30
    b = note(gx, 18, 'Your chain: you place Dodge to the right of Chop', 11, bold=True)
    b += grid(gx, gy, S, 3, 3, labels=False)
    b += piece(gx + 0 * S, gy + 0 * S, S, 'Blank', '', WILD, 'none', dashed=True)
    b += piece(gx + 0 * S, gy + 1 * S, S, 'Chop', 'Hurt 5', CHOP, 'me', badge='2')
    b += piece(gx + 1 * S, gy + 1 * S, S, 'Dodge', 'Guard 5', DODGE, 'me', badge='1')
    tx = gx + 3 * S + 22
    for i, t in enumerate(['1  Dodge fires first: it is the piece you placed.', '    You hold 5 guard.',
                           '2  Chop is linked to it, so it fires next.', '    Guard then Hurt is the combo Riposte:', '    5 x 1.5 = 7.5, rounded to 8 on the Yield bar.', '',
                           'Two pieces fired. Nothing is used up.', 'Both stay on the board.', '',
                           'Had you placed Chop next to a Dodge already', 'on the board, Chop would fire first: no combo, 5.']):
        b += note(tx, 52 + i * 15, t, 10.5)
    return svg(640, 300, b, 'A chain of two: the placed piece fires first, then the piece linked to it')


def fig_useup():
    """2.6.990 replay, Wild Boar (seed 3) turn 3: its Boar Rush lands on the aim cell, links the Bramble and, through it, my Pierce."""
    S = 84
    gx, gy = 24, 30
    b = note(gx, 18, 'The creature’s chain of 3 (Wild Boar, seed 3, turn 3)', 11, bold=True)
    b += grid(gx, gy, S, 3, 3, labels=False)
    b += piece(gx + 1 * S, gy + 1 * S, S, 'Boar Rush', 'Hurt 6', BRUSH, 'foe', badge='1')
    b += piece(gx + 1 * S, gy + 2 * S, S, 'Bramble', '-10%', BRAMBLE, 'env', badge='2')
    b += piece(gx + 0 * S, gy + 2 * S, S, 'Pierce', 'Hurt 11', PIERCE, 'me', badge='3')
    tx = gx + 3 * S + 22
    for i, t in enumerate(['1  The Boar places Boar Rush on its aim cell:', '    6, all of it blocked by my guard.', '2  Boar Rush links to the Bramble below it. The', '    Bramble fires for the Boar: I lose 9 health.',
                           '3  The Bramble links to my Pierce. It fires, for me:', '    11 on the Yield bar, in the creature’s turn.', '',
                           'Three pieces fired, so all three are used up:', 'Boar Rush, the Bramble and Pierce leave the board.', '',
                           'Each piece works for its owner, whoever started the', 'chain. An environment piece works for the starter.']):
        b += note(tx, 46 + i * 15, t, 10.5)
    return svg(640, 300, b, 'A chain of three started by the creature fires an environment piece for the creature and one of your pieces for you, then all three are used up')


def fig_round():
    w = 640
    b = ''
    steps = [('You', '#f6e7bf', ['look, pick, flip,', 'place one piece', '(or pass),', 'End turn']), ('The creature', '#f3cdc8', ['plays its aim', '(or picks again),', 'its chain fires,', 'class rule extras']),
             ('The environment', '#d9ead0', ['places 1 piece', 'on an empty,', 'lonely cell.', 'Nothing fires.']), ('Clean-up', '#e6e6e6', ['poison, Simmer,', 'old pieces leave,', 'new hand of 5,', 'new aim is shown'])]
    bw = 138
    for i, (t, c, ls) in enumerate(steps):
        x = 8 + i * (bw + 20)
        b += f'<rect x="{x}" y="10" width="{bw}" height="104" rx="8" fill="{c}" stroke="#777"/>'
        b += note(x + bw / 2, 30, t, 11.5, 'middle', bold=True)
        for j, l in enumerate(ls):
            b += note(x + bw / 2, 50 + j * 14.5, l, 10, 'middle')
        if i < 3:
            b += arrow(x + bw + 2, 62, x + bw + 18, 62)
    return svg(w, 122, b, 'One round: you, the creature, the environment, then clean-up')


def fig_env():
    S = 92
    b = ''
    items = [('Sun', 'x2', SUN, 'Your pieces in this', 'chain count double.'), ('Bramble', '-10%', BRAMBLE, 'The other side', 'loses a tenth.'),
             ('Rain', 'guard', RAIN, 'The side that fires', 'it gets guard.'), ('Thornburst', '-10% you', THORN, 'The side that fires', 'it is hurt.')]
    for i, (n, l2, e, t1, t2) in enumerate(items):
        x = 14 + i * 155
        b += piece(x, 6, S, n, l2, e, 'env')
        b += note(x + S / 2, S + 22, t1, 10, 'middle') + note(x + S / 2, S + 36, t2, 10, 'middle')
    return svg(640, 136, b, 'The four environment pieces with their edges')


def fig_bird():
    """2.6.990 replay: Carrion Crow, level 9, seed 5, turn 1."""
    S = 70
    gx, gy = 24, 24
    b = grid(gx, gy, S)
    b += piece(gx + 1 * S, gy + 2 * S, S, 'Jab', 'Hurt 5', JAB, 'me')
    b += piece(gx + 1 * S, gy + 0 * S, S, 'Flutter O.', 'Trick 1', FLUT, 'foe')
    b += piece(gx + 1 * S, gy + 1 * S, S, 'Blank', '', WILD, 'none', dashed=True)
    b += aim(gx + 0 * S, gy + 1 * S, S, "AIM 1") + aim(gx + 2 * S, gy + 1 * S, S, "AIM 2")
    tx = gx + 4 * S + 24
    for i, t in enumerate(['Bird rule, Two aims (Carrion Crow, seed 5, turn 1).', '', 'Aim 1: Mob Caw, Hurt 3, Quick, on cell 0,1.', 'Aim 2: the same piece on cell 2,1.', '',
                           'Put a piece on aim 1 and it plays aim 2.', 'Put pieces on both and it picks again.', '', 'Taking one cell does not stop the hit. Here it', 'made it worse: with a piece on aim 1 the chip',
                           'read 9 for aim 2 (its Quick extra piece links', 'better from there). Left alone it was 3.']):
        b += note(tx, 44 + i * 15, t, 10.5, bold=(i == 0))
    return svg(640, 320, b, 'A Bird shows two aims on different cells')


def fig_hand():
    """2.6.990: the hand over three rounds with a Keeper, a Plenty and a Simmer piece (as played: Pincer Earwig, seed 3, with the harness copy whose gnome owns the three pieces)."""
    b = ''
    rows = [('Round 1', ['Charm', 'Buckthorn Z.', 'Cranberry P.', 'Pierce'], 'I play Buckthorn Zing (Plenty). Cranberry Preserve (Keeper) is not played.', {1: 'play', 2: 'keep'}),
            ('Round 2', ['Cranberry P.', 'Swing', 'Bark Badger', 'Pecan Pie', 'Hoe Hook', 'Dodge'], 'Six pieces: the Keeper stayed, five new ones came. I play Pecan Pie (Simmer).', {0: 'keep', 3: 'play'}),
            ('Round 3', ['Cranberry P.', 'Frost Bark', 'Slip Past', 'Jab', 'Rest'], 'Back to five. As the turn starts: Simmer heals 2 (again next round, then it is over).', {0: 'keep'})]
    y = 8
    for name, hand, text, marks in rows:
        b += note(6, y + 22, name, 10.5, bold=True)
        for i, n in enumerate(hand):
            x = 66 + i * 94
            m = marks.get(i)
            fill = '#f6e7bf' if m is None else ('#cfe6c0' if m == 'keep' else '#f7d9a0')
            sw = '2.2' if m else '1.2'
            b += f'<rect x="{x}" y="{y + 4}" width="88" height="28" rx="5" fill="{fill}" stroke="#8a6a1f" stroke-width="{sw}"/>'
            b += note(x + 44, y + 22, n, 9.6, 'middle')
        b += note(66, y + 47, text, 9.6, color='#444')
        y += 62
    b += f'<rect x="66" y="{y + 2}" width="14" height="12" rx="3" fill="#cfe6c0" stroke="#8a6a1f"/>' + note(86, y + 12, 'Keeper: stays in the hand', 9.6)
    b += f'<rect x="250" y="{y + 2}" width="14" height="12" rx="3" fill="#f7d9a0" stroke="#8a6a1f"/>' + note(270, y + 12, 'the piece I placed that round', 9.6)
    b += note(66, y + 30, 'Round 1 shows 4 pieces: the fifth was my start piece.', 9.2, color='#555')
    return svg(640, y + 38, b, 'The hand over three rounds: a Keeper piece stays, Plenty gives a sixth piece for one round, Simmer heals 2 at the start of the next two turns')


def fig_swarm():
    """2.6.988 Swarm grows: +1 Hurt per 2 other creature pieces on the board, at most +2 (checked on the engine: play/checks.php)."""
    b = ''
    cols = [('0 or 1 other pieces', 0), ('2 or 3 other pieces', 1), ('4 or more', 2)]
    for i, (t, add) in enumerate(cols):
        x = 10 + i * 212
        b += f'<rect x="{x}" y="6" width="200" height="74" rx="8" fill="#f3cdc8" stroke="#9b3b33"/>'
        b += note(x + 100, 24, t, 10.5, 'middle', bold=True)
        n = [1, 3, 5][i]
        for k in range(n):
            b += f'<rect x="{x + 100 - n * 11 + k * 22}" y="34" width="18" height="18" rx="3" fill="{"#9b3b33" if k == 0 else "#fff"}" stroke="#9b3b33"/>'
        b += note(x + 100, 70, 'Nip, printed 5, hits for ' + str(5 + add), 10.5, 'middle')
    return svg(640, 88, b, 'Swarm: a Critter Hurt hits 1 harder for every 2 of its other pieces on the board, up to 2 harder')
