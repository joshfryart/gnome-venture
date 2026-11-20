-- tailor EMPTY state only (BUILD-sign craft pass). 64x64, anchor (32,54).
local G = dofile("/tmp/ase/states2/signs_kbgt_common.lua")
local P, HP = G.P, G.HP
local out = app.params.out or "/tmp/ase/states2/tailor/"
local px, R, ink, lerp, hsh = G.px, G.R, G.ink, G.lerp, G.hsh
local W, S, E, D, PE, GO, CREAM, INK = P.wood, P.stone, P.ember, P.dusk, P.petal, P.gold, P.cream, P.ink
local GRAIN = lerp(W.hi, W.base, .4)

local STK = { { 15, 48 }, { 49, 48 }, { 14, 59 }, { 50, 59 } }

local function frame()
  local postL = G.c:rect(8, 9, 9, 53)
  local postR = G.c:rect(55, 12, 56, 53)
  local pole = G.c:rect(8, 2, 8, 8)
  local knob = G.c:ellipse(55.5, 10, 1.5, 1.5)
  local bar = G.c:rect(10, 13, 54, 14)
  local pegL, pegR = G.c:rect(7, 13, 7, 14), G.c:rect(57, 13, 57, 14)
  ink(postL, postR, pole, knob, bar, pegL, pegR)
  for _, p in ipairs{ postL, postR } do
    p:each(function(x, y) px(x, y, p:has(x - 1, y) and W.shade or W.base) end)
  end
  px(8, 9, W.hi) R(8, 15, 8, 52, W.base)
  for _, g in ipairs{ { 9, 22 }, { 9, 31 }, { 8, 40 }, { 56, 25 }, { 56, 36 }, { 55, 46 } } do px(g[1], g[2], W.deep) end
  G.c:fillMask(pole, W.shade) px(8, 2, GO.hi)
  G.c:fillMask(knob, W.base) px(55, 9, W.hi) px(56, 11, W.shade)
  G.c:fillMask(bar, W.base) R(10, 13, 54, 13, W.hi)
  G.c:fillMask(pegL, W.deep) G.c:fillMask(pegR, W.deep)
  -- notch where the thread is tied, and a pin stuck in the bar
  px(32, 14, W.deep)
  -- little dirt collars at the post feet
  R(6, 53, 11, 54, G.EARTH.dark) R(53, 53, 58, 54, G.EARTH.dark) R(6, 53, 7, 53, G.EARTH.base) R(53, 53, 54, 53, G.EARTH.base)
end

local function flag(f)
  local m = HP.mask()
  local cols = {}
  for i = 0, 6 do
    local off = math.floor(math.sin(i * 0.95 - f * 1.5708) * 1.0 + .5)
    if i == 0 then off = 0 end
    cols[i] = off
    local top, bot = 3 + off, 6 + off
    if i == 6 then top = top + 1 end
    for y = top, bot do if not (i == 6 and y == 4 + off) then m:set(9 + i, y) end end
  end
  ink(m)
  m:each(function(x, y)
    local i = x - 9
    local r = y - (3 + cols[i])
    local col = (r == 0 and PE.hi) or (r == 2 and CREAM) or (r == 3 and PE.shade) or PE.base
    px(x, y, col)
  end)
end

local function tagMask(dx)
  local m = HP.mask()
  for y = 20, 42 do
    local cut = (y < 24) and (24 - y) or 0
    for x = 18 + cut, 46 - cut do m:set(x + dx, y) end
  end
  return m
end

local function tag(dx)
  local m = tagMask(dx)
  local thick = m:shift(1, 1):cut(m)
  ink(m, thick)
  G.c:fillMask(thick, W.shade)
  G.c:fillMask(m, W.hi)
  -- wood grain, kept out of the lettering/icon area
  local clear = G.c:rect(21 + dx, 23, 43 + dx, 39)
  m:each(function(x, y)
    local lx = x - dx
    if not clear:has(x, y) and (y + math.floor(math.sin(lx * .45) * 1.2 + .5)) % 3 == 0 and hsh(lx // 4, y) < 70 then px(x, y, GRAIN) end
  end)
  -- edges: lit top/left, shaded bottom/right
  m:edge():each(function(x, y)
    local lx = x - dx
    if y >= 41 or lx >= 45 or (y < 24 and lx > 32) then px(x, y, W.base) else px(x, y, CREAM) end
  end)
  -- purple running stitch 2 px inside the edge
  local inner = m:shrink(2)
  local k = 0
  local ring = inner:edge()
  ring:each(function(x, y)
    local lx = x - dx
    local t = (lx + y) % 3
    if t ~= 0 and not (y < 25 and math.abs(lx - 32) < 4) then px(x, y, D.base) end
  end)
  -- punched hole with a brass eyelet
  px(31 + dx, 22, GO.shade) px(33 + dx, 22, GO.shade) px(32 + dx, 21, GO.base) px(32 + dx, 23, GO.deep)
  G.c.pix[22 * G.W + 32 + dx] = nil G.c.own[22 * G.W + 32 + dx] = nil
  -- icon: red thread spool + needle with a gold thread
  local b = dx
  R(26 + b, 25, 31 + b, 25, W.shade) R(26 + b, 31, 31 + b, 31, W.deep)
  R(27 + b, 26, 30 + b, 30, E.base)
  R(27 + b, 26, 27 + b, 30, E.hi) R(30 + b, 26, 30 + b, 30, E.shade)
  px(28 + b, 27, E.shade) px(29 + b, 28, E.shade) px(28 + b, 29, E.shade)
  -- needle: diagonal, eye at the top
  for i = 0, 6 do px(34 + i + b, 25 + i, (i == 0) and S.shade or S.deep) end
  px(35 + b, 25, S.deep) px(34 + b, 26, S.deep)
  px(36 + b, 27, S.hi)
  -- gold thread from spool to the needle eye
  px(31 + b, 28, GO.shade) px(32 + b, 28, GO.shade) px(33 + b, 27, GO.shade) px(33 + b, 26, GO.shade)
  -- BUILD in plum ink
  G.text(23 + dx, 33, D.deep)
end

local function empty(f)
  local c = G.new(64, 64, "tailor-empty")
  local dx = ({ 0, 1, 0, -1 })[f]
  G.plot(11, 44, 53, 61, 5, 5)
  G.tuft(12, 48) G.tuft(52, 50) G.tuft(28, 62) G.tuft(40, 44)
  G.stringBack(STK)
  -- shadows: hanging tag and post feet (lower right)
  G.shadow(G.c:poly{ { 24 + dx, 53 }, { 46 + dx, 53 }, { 51 + dx, 57 }, { 29 + dx, 57 } })
  G.shadow(G.c:poly{ { 10, 54 }, { 12, 54 }, { 17, 57 }, { 15, 57 } }) G.shadow(G.c:poly{ { 57, 53 }, { 59, 53 }, { 62, 56 }, { 60, 56 } })
  frame()
  flag(f)
  -- thread from the bar to the eyelet
  G.seg(32, 15, 32 + dx, 21, E.base)
  tag(dx)
  G.stringFront(STK)
  G.pebble(19, 56, true) G.pebble(45, 52)
  -- a dropped gold button
  local btn = G.c:ellipse(37, 58, 1, 1)
  ink(btn) G.c:fillMask(btn, GO.base) px(36, 57, GO.hi) px(37, 58, GO.deep) px(38, 59, GO.shade)
  G.flower(23, 52, P.sky.base, CREAM)       -- cornflower
  G.flower(46, 56, PE.hi, GO.base)           -- pink
  return c
end

local fr = {}
for f = 1, 4 do fr[f] = empty(f) end
G.save(fr, out, "tailor")
