-- npc-lantern-lou sprite (npc2 P1_18) species: rosy lantern moth
-- 64x96, 3/4 top-down, feet y=90. Lavender fuzz, cream ruff, tan eyespot wings, wide sea-blue knob hat,
-- feathery antennae, curled proboscis; prop: a glowing brass lantern held in both hands.
-- idle 4f: base / breath (body, hat, wings 1 lower) / base / blink + right antenna twitch.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-lantern-lou"
local FUR = { hi = P.dusk.hi, base = P.dusk.base, shade = P.dusk.shade, deep = P.dusk.deep }
local FACE = { hi = P.cream, base = "#e6d4f2", shade = P.dusk.hi, deep = P.dusk.base }
local RUFF = { hi = P.cream, base = "#f3e6c8", shade = "#d2bccf", deep = P.dusk.shade }
local WING = { hi = "#f2ddb0", base = "#d9b582", shade = "#a7808a", deep = "#6b4a6a" }
local HAT, GLD, WOOD = P.sea, P.gold, P.wood
local function under(c, m, hex) local l = {} m:each(function(x, y) if not m:has(x, y + 1) then l[#l + 1] = { x, y } end end) for _, q in ipairs(l) do c:put(q[1], q[2], hex) end end
local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg) local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  for y = math.floor(cy - rx - 1), math.ceil(cy + rx + 1) do for x = math.floor(cx - rx - 1), math.ceil(cx + rx + 1) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local function eye(c, x, y)
  for _, q in ipairs{ {1,0},{2,0},{0,1},{3,1},{0,2},{3,2},{1,3},{2,3} } do c:put(x + q[1], y + q[2], P.cream) end
  c:put(x + 1, y + 1, P.cream) c:put(x + 2, y + 1, P.ink) c:put(x + 1, y + 2, P.ink) c:put(x + 2, y + 2, P.ink)
end
local function feather(c, pts, dir)
  local m = c:line(pts, 1) local add = HP.mask()
  m:each(function(x, y) if y % 2 == 0 then add:set(x + dir, y) end end)
  c:part(m:add(add), WING, { noshade = true, nopop = true })
end
local function frame(p)
  local c = HP.canvas{ w = 64, h = 96, name = NAME }
  local b = p.bob or 0
  c:groundShadow(32, 89.5, 12, 3)
  -- wings behind (upper + lower), eyespots
  for _, s in ipairs{ -1, 1 } do
    local up = oval(32 + s * 12, 63 + b, 11, 6, s * -55)
    c:part(up, WING, { band = 2 })
    c:fillMask(c:ellipse(32 + s * 14, 61 + b, 1.6, 1.6), GLD.base) c:put(32 + s * 14, 61 + b, FUR.deep)
    local lo = oval(32 + s * 10, 77 + b, 6, 4, s * 25) c:part(lo, WING, { band = 1, nopop = true })
  end
  for _, fx in ipairs{ 28, 36 } do local m = c:ellipse(fx, 88, 3, 2) c:part(m, FUR, { band = 1 }) under(c, m, FUR.deep) end
  local body = c:ellipse(32, 77 + b, 9, 9.5)
  for _, q in ipairs{ { 23, 74 }, { 41, 74 }, { 24, 81 }, { 40, 81 } } do body:add(c:ellipse(q[1], q[2] + b, 1.5, 1.5)) end
  c:part(body, FUR, { band = 2 }) under(c, body, FUR.deep)
  -- lantern
  c:part(c:line({ { 29, 72 + b }, { 30, 70 + b }, { 34, 70 + b }, { 35, 72 + b } }, 1), WOOD, { noshade = true, nopop = true })
  c:part(c:rrect(28, 73 + b, 36, 75 + b, 1), WOOD, { band = 1 })
  local gl = c:rrect(28, 76 + b, 36, 84 + b, 2)
  c:part(gl, GLD, { band = 1, nopop = true })
  c:fillMask(c:rect(31, 78 + b, 33, 82 + b), GLD.hi)
  c:fillMask(c:ellipse(32, 80.5 + b, 0.8, 1.5), P.cream)
  c:put(29, 77 + b, P.cream) c:put(29, 78 + b, P.cream)
  for y = 77, 83 do c:put(35, y + b, WOOD.shade) end
  c:part(c:rrect(28, 85 + b, 36, 86 + b, 1), WOOD, { band = 1, nopop = true })
  for _, hx in ipairs{ 26, 38 } do local h = c:ellipse(hx, 73 + b, 2.5, 2.5) c:part(h, FUR, { band = 1, nopop = true }) end
  -- ruff
  local ruff = c:ellipse(32, 66 + b, 11, 3)
  for _, x in ipairs{ 22, 26, 30, 34, 38, 42 } do ruff:add(c:ellipse(x, 68.5 + b, 1.6, 1.6)) end
  c:part(ruff, RUFF, { band = 1 })
  -- antennae (behind hat)
  local tw = p.tw or 0
  feather(c, { { 25, 43 + b }, { 21, 36 + b }, { 18, 30 + b } }, -1)
  feather(c, { { 39, 43 + b }, { 43, 36 + b }, { 46 + tw, 30 + b - tw } }, 1)
  -- head
  local head = c:ellipse(32, 55 + b, 12, 9.5)
  head:add(c:ellipse(20.5, 57 + b, 1.5, 1.5)) head:add(c:ellipse(43.5, 57 + b, 1.5, 1.5))
  c:part(head, FACE, { band = 2 }) under(c, head, FACE.deep)
  for _, ex in ipairs{ 26.5, 37.5 } do c:fillMask(c:ellipse(ex, 53.5 + b, 3, 2.5), FUR.shade) end
  if p.blink then for _, x in ipairs{ 25, 36 } do for i = 0, 3 do c:put(x + i, 54 + b, P.ink) end end
  else eye(c, 25, 52 + b) eye(c, 36, 52 + b) end
  c:part(c:ellipse(32, 58.5 + b, 2, 1.2), RUFF, { noshade = true, nopop = true })
  c:paint({ "pp", ".p", "pp" }, 32, 60 + b, { p = GLD.deep })
  c:cheek(22, 58 + b) c:cheek(40, 58 + b)
  -- wide coolie hat with knob
  local hat = c:ellipse(32, 46 + b, 15, 3.5)
  hat:add(c:poly{ { 22, 46 + b }, { 42, 46 + b }, { 32, 37 + b } })
  c:part(hat, HAT, { band = 2, pop = { x = 27, y = 42 + b } }) under(c, hat, HAT.deep)
  c:stitch{ { 22, 46 + b }, { 42, 46 + b } }
  c:part(c:ellipse(32, 36 + b, 1.6, 1.6), GLD, { band = 1, pop = { x = 31, y = 35 + b } })
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end
local F = { { bob = 0 }, { bob = 1 }, { bob = 0 }, { bob = 0, blink = true, tw = 1 } }
local frames = {}
for _, p in ipairs(F) do frames[#frames + 1] = frame(p) end
HP.report(frames[1])
HP.sheet{ cellw = 64, cellh = 96, frames = frames, tags = { { name = "idle", from = 1, to = 4 } } }
  :save{ png = out .. NAME .. ".png", aseprite = out .. NAME .. ".aseprite", scale = 1 }
