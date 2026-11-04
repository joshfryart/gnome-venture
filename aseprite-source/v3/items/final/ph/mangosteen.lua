-- mangosteen (final, Opus single pass). One whole mangosteen: deep wine-purple globe with waxy lilac bloom, one bright
-- specular, cool reflected light on the lower right; a thick olive calyx of four rounded sepals with AO on the fruit
-- under it; short woody stalk with a pale cut end.
-- quirk: a thumb-sized window has been peeled open on the front, showing the pink cut rind and two snowy segments.
local NAME = "mangosteen"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC22_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new(NAME)

local PUR = { "#24102c", "#3d1640", "#5c1f4f", "#7e2d62", "#a2457a", "#c9739a" }
local BLOOM, COOL = "#9d7fb0", "#5b4f96"
local CAL = { "#1d3424", "#2b4d2e", "#3e6b37", "#5a8b43", "#80ad55", "#b2d27a" }
local STK = { "#3a2622", "#5a3a2a", "#7b5634", "#9c7444", "#c09a62", "#e6c98e" }
local RIND = { "#6e1838", "#9c2a4a", "#c84a62", "#e8768a" }
local FLESH = { "#b9a6a8", "#d9cbc6", "#efe6dc", "#fff4e6" }

-- fruit body
local cx, cy, R = 32, 38, 15.5
local fm = HP.ellipse(cx, cy, 16, 14.5)
local fn = A.body(fm, cx - 1, cy - 1, 16, 6, 0.7)
local fb = {}

-- calyx: back sepal, side sepals, front sepal (thick, rounded, drape over the shoulder)
local sep = {
  { 32, 24.2, 3.2, 1.8, 0 },        -- back (peeks)
  { 25.6, 26.6, 5.2, 2.5, 0.42 },   -- left
  { 38.6, 26.4, 5.2, 2.5, -0.42 },  -- right
  { 32, 28.0, 2.8, 4.4, 0 },        -- front, hanging down
}
for _, s in ipairs(sep) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.7) end
local calm = HP.mask() for _, s in ipairs(sep) do calm:add(s.m) end
-- AO + cast shadow of the calyx on the fruit
X.ao(fb, fm, calm, 2, -1)
A.cast(fb, fm, calm, 1, 2, -1)

-- peeled window on the front (quirk)
local wm = HP.ellipse(37, 44, 5, 4)
local fv = fm:copy():cut(calm)
local ftok = { r = { name = "fruit" } }
local fidx = A.tone(c, fv, fn, PUR, { bias = fb, tok = ftok, cuts = { 0.14, 0.3, 0.48, 0.66, 0.86 }, amb = 0.05, wrap = 0.18 })
-- waxy bloom: sparse lilac flecks on the lit mid tones
fv:each(function(x, y) local k = K(x, y)
  if fidx[k] == 4 or fidx[k] == 5 then
    if X.hash(x, y, 7) > 0.83 and not wm:grow(1):has(x, y) then c:put(x, y, BLOOM, ftok) end
  end end)
-- cool reflected light on the lower-right rim
local rim = X.rim(fn)
fm:edge():each(function(x, y) local k = K(x, y)
  if rim[k] and rim[k] > 0.55 and not calm:has(x, y) and y > cy - 4 then c:put(x, y, COOL, ftok) end end)
-- faint shallow ribs (segment lines) on the shade side
for _, rx in ipairs{ 20, 45 } do
  for y = cy - 6, cy + 9 do
    local x = floor(rx + (rx < cx and -1 or 1) * ((y - cy) / 14) ^ 2 * 3 + .5)
    if fv:has(x, y) and not fv:edge():has(x, y) and fidx[K(x, y)] and fidx[K(x, y)] <= 4 then A.step(c, fidx, PUR, x, y, -1, ftok) end
  end
end
-- specular: 2x2 cream + hi halo, upper left
c:put(23, 32, A.CREAM, ftok) c:put(24, 32, A.CREAM, ftok) c:put(23, 33, A.CREAM, ftok)
c:put(25, 32, PUR[6], ftok) c:put(22, 34, PUR[6], ftok) c:put(24, 33, PUR[6], ftok)
c:put(21, 37, PUR[6], ftok)

-- the peeled window: pink cut rind ring, then flesh segments sunk inside
local rtok = { r = { name = "rind" } }
local inner = HP.ellipse(37.4, 44.4, 3.2, 2.4)
wm:each(function(x, y)
  if inner:has(x, y) then return end
  -- concave: upper-left lip is the lit cut face, lower-right in shadow
  local dx, dy = x - 37, y - 44
  local i = (dx + dy < -2) and 4 or (dx + dy < 1 and 3 or 2)
  if dy >= 3 or dx >= 4 then i = 1 end
  c:put(x, y, RIND[i], rtok)
end)
local stok = { r = { name = "flesh" } }
inner:each(function(x, y)
  local dx, dy = x - 37.4, y - 44.4
  local i = 3
  if dy < -1.2 or dx < -2.4 then i = 1 end           -- AO under the rind lip
  if dx > 0.6 and dx < 1.6 then i = 2 end             -- seam between two segments
  if dx > -1.6 and dx < -0.4 and dy > -1.2 and dy < 0.6 then i = 4 end
  if dx > 2 and dy > -1 and dy < 1 then i = 4 end
  c:put(x, y, FLESH[i], stok)
end)

-- calyx sepals, back to front
local ctok = { r = { name = "calyx" } }
for i, s in ipairs(sep) do
  local vis = s.m:copy()
  local b = {}
  for j = i + 1, #sep do vis:cut(sep[j].m) X.ao(b, s.m, sep[j].m, 1, -1) end
  local idx = A.tone(c, vis, s.n, CAL, { bias = b, tok = ctok, amb = 0.1, wrap = 0.3 })
  -- midrib crease: a darker line down the sepal's long axis on the lit half
  local ca, sa = math.cos(s[5]), math.sin(s[5])
  vis:each(function(x, y) local k = K(x, y)
    local u = (x - s[1]) * ca + (y - s[2]) * sa
    local v = -(x - s[1]) * sa + (y - s[2]) * ca
    local long, across = s[3] > s[4] and u or v, s[3] > s[4] and v or u
    local L = max(s[3], s[4])
    if abs(across) < 0.5 and abs(long) < L - 1.2 and idx[k] and idx[k] >= 3 then A.step(c, idx, CAL, x, y, -1, ctok) end
  end)
end
-- warty tip on the front sepal
c:put(31, 31, CAL[6], ctok) c:put(30, 27, CAL[6], ctok) c:put(31, 27, CAL[6], ctok)

-- stalk: short thick woody stub with a pale cut end
local sp = { { 32, 24 }, { 32, 21 }, { 32.5, 18 }, { 34, 15.5 } }
local sm, sn = A.tube(sp, function(t) return 1.6 - t * 0.2 end)
sm:cut(calm)
local ktok = { r = { name = "stalk" } }
local kidx = A.tone(c, sm, sn, STK, { tok = ktok, amb = 0.1, wrap = 0.3, cuts = { 0.2, 0.38, 0.55, 0.72, 0.9 } })
-- grain: one dark streak along the stalk
for i = 2, 16 do local x, y = A.bez(sp, i / 20) A.step(c, kidx, STK, floor(x + 1.2), floor(y + .5), -1, ktok) end
-- cut end (oval cap, pale end grain with a dark pith dot)
for _, p in ipairs{ { 33, 14, 5 }, { 34, 14, 6 }, { 35, 14, 5 }, { 33, 15, 4 }, { 35, 15, 4 }, { 34, 15, 3 }, { 36, 15, 4 } } do
  c:put(p[1], p[2], STK[p[3]], ktok) end

A.fin(c, NAME)
