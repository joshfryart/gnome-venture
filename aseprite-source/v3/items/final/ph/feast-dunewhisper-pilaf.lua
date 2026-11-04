-- feast-dunewhisper-pilaf (Opus single pass). A wind-swept dune of saffron pilaf heaped on a footed, engraved brass platter
-- with two slim ring handles. Rice: per-pixel dome light, 2x1 grain texture (lit grain + dark gap), a few pale unsaffroned
-- grains; toppings of slivered almonds, raisins, pomegranate seeds and pistachio. Brass: bevelled rim, engraved dashes,
-- specular streak, dark well, ambient shadow where the rice meets the brass.
-- quirk: a tiny striped pennant on a toothpick flies from the dune's crest, tugged by the desert wind.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB30_2.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, sqrt, max, min, abs, sin, cos, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local c = D.new("feast-dunewhisper-pilaf")
local BRASS = { "#3e1c26", "#743226", "#a8502c", "#cf783c", "#eba562", "#ffd8a2" }
local RICE = { "#7a2c1c", "#b45a14", "#e08a14", "#f8b428", "#ffd65a", "#fff09a" }
local btok, rtok = D.tok("brass"), D.tok("rice")
local CX = 32

c:groundShadow(32, 57, 13, 1)
-- foot ring
local foot = D.sweep(D.ellipseMask(CX, 53, 10, 2), 2)
D.toneN(c, foot, D.vcylN(foot, CX, 10, 0.3), BRASS, { tok = btok })
-- ring handles (behind the platter rim): thin loops of 2 px wire
local function handle(hx, dir)
  local m = HP.mask()
  for a = 0, 359, 4 do local r = a * pi / 180
    local x, y = hx + cos(r) * 2.6, 45 + sin(r) * 2.2
    m:set(floor(x + .5), floor(y + .5))
  end
  m:add(m:shift(0, 1))
  local inner = D.ellipseMask(hx, 45.5, 1.0, 0.8)
  m:cut(inner)
  local n = {} m:each(function(x, y) n[K(x, y)] = { D.norm((x - hx) * 0.25, (y - 45.5) * 0.35, 1) } end)
  D.toneN(c, m, n, BRASS, { tok = btok })
end
handle(10, -1) handle(54, 1)
-- platter: thick rim + top
local RX, RY, PY = 21, 6.5, 45
local ptop = D.ellipseMask(CX, PY, RX, RY)
local prim = D.sweep(ptop, 3):cut(ptop)
D.toneN(c, prim, D.vcylN(prim, CX, RX, 0.35), BRASS, { tok = btok })
-- engraved dashes on the rim face + dark underside row
prim:each(function(x, y)
  if prim:has(x, y - 1) and prim:has(x, y + 1) and (x % 3 == 0) then c:put(x, y, BRASS[2], btok) end
  if not prim:has(x, y + 1) then c:put(x, y, BRASS[1], btok) end
end)
-- top: flat rim band, then sunken well
local well = D.ellipseMask(CX, PY + 0.5, RX - 4, RY - 1.5)
local band = ptop:copy():cut(well)
local bn = {} band:each(function(x, y) bn[K(x, y)] = { D.norm((x - CX) * 0.004, -0.6, 1) } end)
D.toneN(c, band, bn, BRASS, { tok = btok })
ptop:edge():each(function(x, y) if y <= PY and x < CX + 6 then c:put(x, y, BRASS[6], btok) end end) -- bright bevel edge
well:edge():each(function(x, y) c:put(x, y, (y < PY + 0.5) and BRASS[2] or BRASS[5], btok) end) -- inner step
-- specular streak on the left of the band
for _, p in ipairs{ { 14, 44 }, { 15, 43 }, { 16, 43 } } do c:put(p[1], p[2], BRASS[6], btok) end
c:put(15, 42, "#fff4d6", btok)
local wfill = well:copy():cut(well:edge())
local wn = {} wfill:each(function(x, y) wn[K(x, y)] = { D.norm(0, -0.4, 1) } end)
local wbias = {}

-- rice dune: dome clipped to the base ellipse; crest leans right (wind from the left)
local BY, BRX, BRY = PY - 0.5, 15, 4.5
local base = D.ellipseMask(CX, BY, BRX, BRY)
local dune, dn = HP.mask(), {}
local TOPY = 20
for x = CX - BRX, CX + BRX do
  local u = (x - CX) / (BRX + 0.5)
  -- asymmetric profile: long windward slope on the left, steep slip-face on the right
  local h
  if u < 0.25 then h = (1 - ((u - 0.25) / 1.25) ^ 2) else h = (1 - ((u - 0.25) / 0.75) ^ 2) ^ 0.8 end
  h = max(0, h)
  local yTop = BY - h * (BY - TOPY)
  local yBot = BY + BRY * sqrt(max(0, 1 - u*u))
  for y = floor(yTop + 0.5), floor(yBot + 0.2) do dune:set(x, y) end
end
dune:add(base)
-- normals from a smooth bump: slope across x from the profile, round toward the viewer in y
local function hAt(x)
  local u = (x - CX) / (BRX + 0.5)
  if u < 0.25 then return max(0, 1 - ((u - 0.25) / 1.25) ^ 2) end
  return max(0, 1 - ((u - 0.25) / 0.75) ^ 2) ^ 0.8
end
dune:each(function(x, y)
  local dhx = (hAt(x + 1) - hAt(x - 1)) * 0.5 * (BY - TOPY)
  local top = BY - hAt(x) * (BY - TOPY)
  local bot = BY + BRY * sqrt(max(0, 1 - ((x - CX) / (BRX + 0.5)) ^ 2))
  local f = (y - top) / max(1, bot - top)       -- 0 at crest edge, 1 at the front foot
  local ny = -0.9 + f * 1.3
  dn[K(x, y)] = { D.norm(-dhx * 0.9, ny, 1) }
end)
X.ao(wbias, wfill, dune, 2, -1)
D.toneN(c, wfill, wn, BRASS, { tok = btok, bias = wbias, cuts = { 0.3, 0.5, 0.66, 0.8, 0.92 } })
local bias = {}
dune:each(function(x, y) if not dune:has(x, y + 2) and y > BY then bias[K(x, y)] = -1 end end)  -- ambient where rice meets brass
local idx = D.toneN(c, dune, dn, RICE, { tok = rtok, bias = bias, cuts = { 0.26, 0.42, 0.58, 0.74, 0.9 }, amb = 0.02, wrap = 0.15 })
-- grain texture: 2x1 lit grains (alternating rows offset) with dark gaps
dune:each(function(x, y)
  local k = K(x, y) local i = idx[k] or 3
  local hsh = X.hash(floor((x + (y % 2)) / 2), y, 11)
  if (x + (y % 2)) % 2 == 0 and hsh > 0.45 then
    c:put(x, y, RICE[min(6, i + 1)], rtok)
    if dune:has(x + 1, y) then c:put(x + 1, y, RICE[min(6, i + 1)], rtok) end
  elseif hsh < 0.12 and i > 1 then c:put(x, y, RICE[i - 1], rtok) end
  if X.hash(x, y, 5) > 0.95 and i >= 3 then c:put(x, y, "#fff4dc", rtok) end   -- pale unsaffroned grain
end)
-- wind ripple lines along the windward slope
for _, r in ipairs{ { 20, 36, 26, 33 }, { 23, 40, 30, 37 }, { 18, 41, 22, 39 } } do
  for _, p in ipairs{ { r[1], r[2] }, { r[1] + 2, r[2] - 1 }, { r[1] + 4, r[2] - 1 }, { r[3], r[4] } } do
    if dune:has(p[1], p[2]) then c:put(p[1], p[2], RICE[3], rtok) if dune:has(p[1], p[2] - 1) then c:put(p[1], p[2] - 1, RICE[6], rtok) end end
  end
end
-- crest highlight
for x = CX - 6, CX + 5 do local top = floor(BY - hAt(x) * (BY - TOPY) + 0.5)
  if dune:has(x, top) and x < CX + 4 then c:put(x, top, RICE[6], rtok) end end
-- toppings
local ttok = D.tok("top")
local function almond(x, y) c:put(x, y, "#fff0d0", ttok) c:put(x + 1, y, "#e8c48e", ttok) c:put(x + 1, y + 1, "#a8703e", ttok) end
local function raisin(x, y) c:put(x, y, "#6e3a52", ttok) c:put(x + 1, y, "#4a2238", ttok) c:put(x, y + 1, "#3a1a2c", ttok) c:put(x + 1, y + 1, "#2e1626", ttok) end
local function pome(x, y) c:put(x, y, "#ff6a5a", ttok) c:put(x + 1, y, "#c8283c", ttok) end
local function pist(x, y) c:put(x, y, "#9dd06c", ttok) c:put(x, y + 1, "#3f8f50", ttok) end
for _, p in ipairs{ { 24, 30 }, { 35, 27 }, { 29, 38 }, { 40, 36 }, { 21, 42 } } do almond(p[1], p[2]) end
for _, p in ipairs{ { 30, 31 }, { 39, 30 }, { 25, 40 }, { 35, 41 } } do raisin(p[1], p[2]) end
for _, p in ipairs{ { 27, 34 }, { 33, 33 }, { 42, 40 }, { 32, 45 }, { 20, 38 } } do pome(p[1], p[2]) end
for _, p in ipairs{ { 37, 34 }, { 23, 35 }, { 31, 25 }, { 44, 43 } } do pist(p[1], p[2]) end
-- spilled grains on the brass band (contact detail)
for _, p in ipairs{ { 14, 47 }, { 47, 48 }, { 49, 44 } } do c:put(p[1], p[2], RICE[5], rtok) c:put(p[1] + 1, p[2], RICE[3], rtok) end

-- quirk: toothpick pennant at the crest, flying to the right
local ptk = D.tok("pick")
local crestX = 35
local crestY = floor(BY - hAt(crestX) * (BY - TOPY) + 0.5)
for y = crestY - 10, crestY do c:put(crestX, y, (y < crestY - 5) and "#e8b982" or "#b97a4a", ptk) end
c:put(crestX, crestY - 11, "#864c33", ptk)
local flag = {
  "AAAB.",
  "aaabbB",
  "AAAB..",
}
local FC = { A = "#5fc4c8", a = "#fff4d6", B = "#3a86b0", b = "#d9cdb0" }
for yy, row in ipairs(flag) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if FC[ch] then c:put(crestX + xx, crestY - 11 + yy - 1, FC[ch], ptk) end end end
D.save(c, "ph", "feast-dunewhisper-pilaf")
