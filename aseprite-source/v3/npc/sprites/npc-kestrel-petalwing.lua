-- npc-kestrel-petalwing sprite (npc2 P1_18) species: honey bear cub
-- 64x96, 3/4 top-down, feet y=90. Tulip-petal cap, scalloped petal collar, cream belly; prop: petal pinwheel.
-- idle 4f: base / breath (body+cap 1 lower) / base / blink + pinwheel turns. Feet + shadow fixed.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-kestrel-petalwing"
local FUR = { hi = "#f6c77e", base = "#dc9a45", shade = "#a9643f", deep = "#5e3040" }
local MUZ = { hi = P.cream, base = "#f4d9ae", shade = "#d4a585", deep = "#93636a" }
local PET, GLD = P.petal, P.gold
local function under(c, m, hex) local l = {} m:each(function(x, y) if not m:has(x, y + 1) then l[#l + 1] = { x, y } end end) for _, q in ipairs(l) do c:put(q[1], q[2], hex) end end
local function eye(c, x, y)
  for _, q in ipairs{ {1,0},{2,0},{0,1},{3,1},{0,2},{3,2},{1,3},{2,3} } do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 1, y + 1, P.cream) c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
end
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b = p.bob or 0
  c:groundShadow(32, 89.5, 13, 3)
  for _, fx in ipairs{ 26.5, 37.5 } do
    local m = c:ellipse(fx, 88, 4, 2.5) c:part(m, FUR, { band = 1 }) under(c, m, FUR.deep)
    c:put(math.floor(fx) - 1, 87, MUZ.base) c:put(math.floor(fx) + 1, 87, MUZ.base)
  end
  -- body + belly
  local body = c:ellipse(32, 77 + b, 11, 9.5)
  c:part(body, FUR, { band = 2 }) under(c, body, FUR.deep)
  c:part(c:ellipse(31.5, 79 + b, 6, 5.5), MUZ, { band = 1, nopop = true })
  -- left arm
  local la = c:ellipse(21, 74 + b, 3, 4.5) c:part(la, FUR, { band = 1 }) under(c, la, FUR.deep)
  -- pinwheel: stick then head, paw over the stick
  local stick = c:line({ { 45, 76 + b }, { 51, 59 + b } }, 1)
  c:part(stick, P.wood, { noshade = true, nopop = true })
  local cx, cy = 52, 55 + b
  local a0 = (p.spin or 0) * math.pi / 4
  for i = 0, 3 do
    local a = a0 + i * math.pi / 2
    local tip = { cx + math.cos(a) * 7, cy + math.sin(a) * 7 }
    local side = { cx + math.cos(a + 1.0) * 4, cy + math.sin(a + 1.0) * 4 }
    c:part(c:poly{ { cx, cy }, tip, side }, (i % 2 == 0) and PET or GLD, { band = 1, nopop = true })
  end
  c:part(c:rect(cx - 1, cy - 1, cx, cy), P.wood, { noshade = true, nopop = true }) c:put(cx - 1, cy - 1, P.wood.hi)
  local ra = c:ellipse(44, 74 + b, 3, 3.5) c:part(ra, FUR, { band = 1 }) under(c, ra, FUR.deep)
  -- scalloped petal collar
  local col = c:ellipse(32, 66 + b, 12, 2.5)
  for x = 21, 43, 4 do col:add(c:ellipse(x, 68 + b, 1.6, 1.6)) end
  c:part(col, PET, { band = 1 })
  -- ears then head
  for _, ex in ipairs{ 20, 44 } do
    local e = c:ellipse(ex, 43 + b, 4, 4) c:part(e, FUR, { band = 1, nopop = true })
    c:fillMask(c:ellipse(ex, 43 + b, 1.6, 1.6), MUZ.shade)
  end
  local head = c:ellipse(32, 52 + b, 14, 11.5)
  c:part(head, FUR, { band = 2, pop = { x = 21, y = 47 + b } }) under(c, head, FUR.deep)
  c:part(c:ellipse(32, 57.5 + b, 6, 3.5), MUZ, { band = 1, nopop = true })
  c:paint({ "hNNN", ".NN." }, 30, 54 + b, { N = FUR.deep, h = MUZ.deep })
  c:paint({ "i..i", ".ii." }, 30, 58 + b, { i = "ink" })
  if p.blink then for _, x in ipairs{ 24, 36 } do for i = 0, 3 do c:put(x + i, 51 + b, P.ink) end end
  else eye(c, 24, 49 + b) eye(c, 36, 49 + b) end
  c:cheek(21, 55 + b) c:cheek(41, 55 + b)
  -- tulip-petal cap with a leafy stem
  local hy = b
  local cap = c:ellipse(32, 41 + hy, 8.5, 3)
  cap:add(c:poly{ { 23, 41 + hy }, { 25, 33 + hy }, { 30, 39 + hy } })
  cap:add(c:poly{ { 28, 39 + hy }, { 32, 31 + hy }, { 36, 39 + hy } })
  cap:add(c:poly{ { 34, 39 + hy }, { 39, 33 + hy }, { 41, 41 + hy } })
  c:part(cap, PET, { band = 2, pop = { x = 27, y = 39 + hy } }) under(c, cap, PET.deep)
  for _, q in ipairs{ { 29, 40 }, { 29, 39 }, { 35, 40 }, { 35, 39 } } do c:put(q[1], q[2] + hy, PET.shade) end
  local stem = c:line({ { 32, 31 + hy }, { 33, 28 + hy } }, 1)
  stem:add(c:ellipse(35.5, 28 + hy + (p.bob or 0) * 0, 2, 1))
  c:part(stem, P.moss, { noshade = true, nopop = true })
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local F = { { bob = 0 }, { bob = 1 }, { bob = 0 }, { bob = 0, blink = true, spin = 1 } }
local frames = {}
for _, p in ipairs(F) do frames[#frames + 1] = frame(p) end
HP.report(frames[1])
HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
  :save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite", scale = 1 }
