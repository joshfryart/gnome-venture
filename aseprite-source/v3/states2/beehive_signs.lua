-- beehive EMPTY state only (BUILD-sign craft pass). 56x64, anchor (28,54).
local G = dofile("/tmp/ase/states2/signs_kbgt_common.lua")
local P, HP = G.P, G.HP
local out = app.params.out or "/tmp/ase/states2/beehive/"
local px, R, ink, lerp, hsh = G.px, G.R, G.ink, G.lerp, G.hsh
local GO, S, SKY, CREAM, INK = P.gold, P.stone, P.sky, P.cream, P.ink
local IRON_L, IRON_B = S.shade, S.deep
local WAXL, WAXE = "#fbe9c0", "#e8c48a"

local STK = { { 13, 48 }, { 43, 48 }, { 12, 59 }, { 44, 59 } }

local function bracket()   -- shepherd's-crook of bent iron
  local post = G.c:rect(6, 12, 7, 56)
  local cx, cy, r = 17.5, 11.5, 11
  local hook = HP.mask()
  for y = 0, 15 do for x = 4, 31 do
    local d = math.sqrt((x + .5 - cx) ^ 2 + (y + .5 - cy) ^ 2)
    if d <= r + .5 and d >= r - 1.5 and y <= 11 then hook:set(x, y) end
  end end
  hook:cut(post)
  local eye = G.pts{ { 27, 13 }, { 29, 13 }, { 28, 14 }, { 28, 12 } }
  local foot = G.c:rect(4, 55, 9, 57)
  ink(post, hook, foot)
  G.c:rim(eye, INK)
  G.c:fillMask(foot, S.base) R(4, 55, 6, 55, S.hi) R(7, 57, 9, 57, S.shade) px(5, 56, S.shade)
  G.c:fillMask(post, IRON_B) R(6, 12, 6, 54, IRON_L)
  hook:each(function(x, y)
    local d = math.sqrt((x + .5 - cx) ^ 2 + (y + .5 - cy) ^ 2)
    local lit = d > r - .4 and (x < cx + 4)
    px(x, y, lit and IRON_L or IRON_B)
  end)
  G.c:fillMask(eye, IRON_B) px(27, 13, IRON_L)
  -- rivet collar where the crook is welded to the post
  R(5, 17, 8, 18, IRON_B) R(5, 17, 8, 17, IRON_L) ink(G.c:rect(5, 17, 8, 18)) R(5, 17, 8, 18, IRON_B) R(5, 17, 8, 17, IRON_L) px(6, 18, S.hi)
end

local function chain(x0, y0, x1, y1)
  local n = y1 - y0
  local prev
  for i = 0, n do
    local x = math.floor(x0 + (x1 - x0) * i / n + .5)
    local col = (i % 2 == 0) and S.base or IRON_B
    if prev and math.abs(x - prev) > 1 then for xx = math.min(x, prev) + 1, math.max(x, prev) - 1 do px(xx, y0 + i, col) end end
    px(x, y0 + i, col)
    prev = x
  end
end

local function plaque(dx)
  local plate = HP.mask()
  for y = 19, 41 do
    local k = math.floor(6 * math.abs(y - 30) / 11)
    for x = 12 + k, 44 - k do plate:set(x + dx, y) end
  end
  local thick = plate:shift(1, 1):cut(plate)
  ink(plate, thick)
  G.c:fillMask(thick, GO.deep)
  -- honeycomb cells over the whole plate
  plate:each(function(x, y)
    local lx, ly = x - dx, y
    local row = ly // 3
    local off = (row % 2) * 2
    local wall = (ly % 3 == 0) or ((lx + off) % 4 == 0)
    local col = wall and GO.shade or GO.base
    if not wall and (ly % 3 == 1) and ((lx + off) % 4 == 1) then col = GO.hi end
    px(x, y, col)
  end)
  -- plate edge: lit upper-left rim, darker lower-right rim (thickness reads)
  local e = plate:edge()
  e:each(function(x, y)
    local lx = x - dx
    if (y < 30 and lx < 40) or (lx < 16) then px(x, y, GO.hi) else px(x, y, GO.deep) end
  end)
  -- clean wax label band across the widest rows
  local band = G.c:rect(10 + dx, 27, 46 + dx, 38):clip(plate:shrink(2))
  G.c:fillMask(band, WAXL)
  band:each(function(x, y) if not band:has(x, y - 1) or not band:has(x, y + 1) then px(x, y, WAXE) end end)
  G.text(19 + dx, 30, INK, WAXE)
  -- capped cell with the bee icon
  local cell = G.c:rrect(23 + dx, 20, 33 + dx, 25, 2)
  G.c:fillMask(cell, WAXL)
  cell:edge():each(function(x, y) px(x, y, WAXE) end)
  local b = dx
  px(27 + b, 21, SKY.base) px(28 + b, 21, SKY.hi) px(30 + b, 21, SKY.hi)   -- wings
  px(28 + b, 22, SKY.hi) px(29 + b, 22, SKY.base) px(30 + b, 22, SKY.base)
  px(25 + b, 23, INK) px(25 + b, 24, INK) px(24 + b, 22, INK)               -- head, antenna
  for x = 26, 30 do
    local k = (x == 27 or x == 29) and INK or GO.base
    px(x + b, 23, k) px(x + b, 24, (k == INK) and INK or GO.shade)
  end
  px(26 + b, 23, GO.hi) px(31 + b, 24, INK)                                    -- sting
  -- hanging eyes
  px(20 + dx, 19, S.hi) px(36 + dx, 19, S.hi)
end

local function bee(x, y, f)
  local body = G.c:rect(x, y + 1, x + 3, y + 2)
  local wing = (f % 2 == 1) and G.pts{ { x + 1, y }, { x + 2, y } } or G.pts{ { x + 1, y }, { x + 2, y - 1 } }
  ink(body, wing)
  G.c:fillMask(body, GO.base) px(x + 1, y + 1, INK) px(x + 1, y + 2, INK) px(x + 3, y + 1, GO.hi) px(x, y + 2, GO.shade)
  px(x, y + 1, INK)
  G.c:fillMask(wing, SKY.hi)
end

local function empty(f)
  local c = G.new(56, 64, "beehive-empty")
  local dx = ({ 0, 1, 0, -1 })[f]
  G.plot(9, 44, 47, 61, 5, 7)
  G.tuft(10, 48) G.tuft(46, 52) G.tuft(30, 62)
  G.stringBack(STK)
  -- hanging plaque's shadow on the ground + post shadow (lower right)
  G.shadow(G.c:poly{ { 20 + dx, 52 }, { 40 + dx, 52 }, { 47 + dx, 55 }, { 40 + dx, 58 }, { 20 + dx, 58 }, { 16 + dx, 55 } })
  G.shadow(G.segMask(8, 57, 20, 59)) G.shadow(G.segMask(9, 57, 20, 58))
  bracket()
  chain(27, 14, 20 + dx, 18) chain(29, 14, 36 + dx, 18)
  plaque(dx)
  G.stringFront(STK)
  G.pebble(18, 56, true) G.pebble(37, 58)
  G.flower(15, 52, P.dusk.hi, P.dusk.base)    -- lavender
  G.flower(41, 53, CREAM, P.petal.hi)         -- clover
  local bp = ({ { 47, 40 }, { 50, 44 }, { 47, 48 }, { 44, 45 } })[f]
  bee(bp[1], bp[2], f)
  return c
end

local fr = {}
for f = 1, 4 do fr[f] = empty(f) end
G.save(fr, out, "beehive")
