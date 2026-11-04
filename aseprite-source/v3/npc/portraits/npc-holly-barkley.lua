-- npc-holly-barkley portrait (npc2 P1_14) species: field mouse
-- 80x100 head+shoulders: round brown mouse, big pink-lined ears, pale muzzle, pink nose + W mouth, whiskers,
-- gold knitted sweater, striped red scarf with hanging end. prop: holly sprig tucked behind the right ear. backdrop dusk.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-holly-barkley"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local MUZ = { hi = P.skinA.hi, base = P.wood.hi, shade = P.wood.base, deep = P.wood.shade }
local HOL = { hi = P.moss.base, base = P.moss.shade, shade = P.moss.deep, deep = "#1e3d3c" }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
local function holly(ax, ay, bx, by, w)
  local dx, dy = bx - ax, by - ay
  local L = math.sqrt(dx * dx + dy * dy)
  local nx, ny = -dy / L, dx / L
  local pts, N = {}, 6
  local function wd(i) return w * math.sin(math.pi * i / N) * (i % 2 == 1 and 1.35 or 0.8) end
  for i = 0, N do pts[#pts + 1] = { ax + dx * i / N + nx * wd(i), ay + dy * i / N + ny * wd(i) } end
  for i = N - 1, 1, -1 do pts[#pts + 1] = { ax + dx * i / N - nx * wd(i), ay + dy * i / N - ny * wd(i) } end
  return HP.poly(pts)
end
-- ears
for _, ex in ipairs{ 18, 61 } do
  c:part(c:ellipse(ex, 31, 10, 10), P.wood, { band = 3, pop = { x = ex - 7, y = 25 } })
  local ix = ex + (ex < 40 and 1 or -1)
  c:part(c:ellipse(ix, 32, 6, 6), P.petal, { band = 2, pop = { x = ix - 4, y = 28 } })
end
-- sweater
local body = c:ellipse(39.5, 104, 31, 28):clip(c:rect(0, 74, 79, 99))
c:part(body, P.gold, { band = 3, pop = { x = 15, y = 86 } })
body:each(function(x, y) if y >= 80 and x % 4 == 0 and c:get(x, y) == P.gold.base then c:put(x, y, P.gold.shade, true) end end)
-- scarf
local sc = c:rrect(20, 69, 59, 78, 4)
c:part(sc, P.ember, { band = 2, pop = { x = 24, y = 71 } })
local st = c:poly{ {25,74},{33,74},{32,93},{23,92} }
c:part(st, P.ember, { band = 2, nopop = true, sep = true })
sc:copy():add(st):each(function(x, y) if (x + y) % 8 < 2 and c:get(x, y) == P.ember.base then c:put(x, y, P.cream, true) end end)
for x = 23, 32, 2 do c:put(x, 92, P.ember.deep, true) end
-- head + tuft
c:part(c:poly{ {35,39},{36,31},{39,35},{41,29},{44,38} }, P.wood, { band = 1, nopop = true })
local head = c:ellipse(39.5, 52, 19.5, 16.5)
c:part(head, P.wood, { band = 3, pop = { x = 26, y = 41 } })
c:part(c:ellipse(39.5, 60, 9.5, 6.5), MUZ, { band = 2, nopop = true, inner = false })
c:part(c:ellipse(39.5, 55.5, 2.5, 1.5), P.petal, { band = 1, nopop = true, inner = false })
c:put(38, 54, P.petal.hi, true) c:put(39, 54, P.petal.hi, true)
c:put(39, 58, P.wood.shade, true) c:put(40, 58, P.wood.shade, true)
for _, q in ipairs{ {36,60},{37,61},{38,61},{39,60},{40,60},{41,61},{42,61},{43,60} } do c:put(q[1], q[2], P.ink, true) end
c:eyeLocked(28, 45) c:eyeLocked(47, 45)
for _, q in ipairs{ {28,43},{29,42},{30,42},{49,42},{50,42},{51,43} } do c:put(q[1], q[2], P.wood.deep, true) end
c:paint({ "PPP", "PPP" }, 23, 54, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 54, 54, { P = "petal.base" })
c:put(23, 54, P.petal.hi) c:put(54, 54, P.petal.hi)
-- holly sprig behind the right ear
for _, l in ipairs{ { 69, 30 }, { 60, 21 } } do
  local m = holly(54, 39, l[1], l[2], 3.5)
  c:part(m, HOL, { band = 1, nopop = true, sep = true })
  c:line({ {54,39},{l[1],l[2]} }, 1):clip(m:shrink(1)):each(function(x, y) c:put(x, y, P.moss.base, true) end)
end
for _, q in ipairs{ {53,38},{57,40},{53,42} } do
  c:part(c:ellipse(q[1], q[2], 1.5, 1.5), P.ember, { band = 1, nopop = true, sep = true })
  c:put(q[1] - 1, q[2] - 1, P.ember.hi, true)
end
c:finish{ outline = true }
for _, l in ipairs{ { {19,58},{11,56} }, { {19,61},{11,62} }, { {60,58},{68,56} }, { {60,61},{68,62} } } do c:fillMask(c:line(l, 1), P.wood.deep) end
backdrop(P.dusk)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
