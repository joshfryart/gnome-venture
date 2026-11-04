-- npc-bramble-mossfoot portrait (npc2 P1_3) species: hedgehog
-- Same design as the sprite: brown spine cloak with pale tips, cream face + pointed snout with violet nose,
-- green knit sweater, red stitched scarf, red mushroom + moss tuft growing on the spines. Moss backdrop disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-bramble-mossfoot"
local SPN = { hi = P.wood.base, base = P.wood.shade, shade = P.wood.deep, deep = "#3a2230" }
local FACE = { hi = P.cream, base = P.skinA.hi, shade = P.skinA.base, deep = P.skinA.shade }
local STEM = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local function R(v) return math.floor(v + 0.5) end
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function under(m, hex) m:each(function(x, y) if not m:has(x, y + 1) then c:put(x, y, hex) end end) end
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
local function spikes(cx, cy, rx, ry, a0, a1, n, len, w, lean)
  local m, tips = HP.mask(), {}
  for i = 0, n - 1 do
    local a = math.rad(a0 + (a1 - a0) * i / (n - 1))
    local ca, sa = math.cos(a), math.sin(a)
    local bx, by = cx + ca * (rx - 1), cy + sa * (ry - 1)
    local ta = a + math.rad(lean or 0)
    local tx, ty = cx + math.cos(ta) * (rx + len), cy + math.sin(ta) * (ry + len)
    m:add(c:poly{ { R(bx - sa * w), R(by + ca * w) }, { R(tx), R(ty) }, { R(bx + sa * w), R(by - ca * w) } })
    tips[#tips + 1] = { R(tx), R(ty) }
  end
  return m, tips
end
-- sweater
local body = c:ellipse(39.5, 106, 30, 27):clip(c:rect(0, 0, 79, 99))
c:part(body, P.moss, { band = 3, pop = { x = 17, y = 87 } })
for y = 84, 98, 2 do for _, x in ipairs{ 33, 46 } do if body:has(x, y) then c:put(x, y, P.moss.shade) c:put(x + 1, y + 1, P.moss.shade) end end end
c:part(c:rrect(38, 90, 41, 93, 1), P.gold, { band = 1, pop = { x = 38, y = 90 } })
-- spine cloak
local cx, cy = 39.5, 47
local core = c:ellipse(cx, cy, 18, 19)
local sk, tips = spikes(cx, cy, 18, 19, 145, 395, 17, 4, 3, 7)
local sp = core:copy():add(sk)
c:part(sp, SPN, { band = 3, pop = { x = 27, y = 32 } })
for i = 0, 21 do
  local a = math.rad(150 + i * 11.5)
  local s = c:line({ { R(cx + math.cos(a) * 11), R(cy + math.sin(a) * 12) }, { R(cx + math.cos(a + .1) * 18), R(cy + math.sin(a + .1) * 19) } }, 1):clip(sp)
  local lit = math.cos(a) < 0.1 and math.sin(a) < 0
  s:each(function(x, y) c:put(x, y, (lit and i % 2 == 0) and SPN.hi or SPN.deep) end)
end
for _, t in ipairs(tips) do for dy = -1, 1 do for dx = -1, 1 do
  if math.abs(dx) + math.abs(dy) <= 1 and sk:has(t[1] + dx, t[2] + dy) and not core:has(t[1] + dx, t[2] + dy) then c:put(t[1] + dx, t[2] + dy, P.wood.hi) end
end end end
for _, e in ipairs{ { 22, 40 }, { 57, 40 } } do
  c:part(c:ellipse(e[1], e[2], 3, 3), FACE, { band = 1, nopop = true })
  c:put(e[1], e[2], P.skinA.shade) c:put(e[1], e[2] + 1, P.skinA.shade)
end
-- face + snout + nose
local fc = c:ellipse(39.5, 55, 14, 12)
c:part(fc, FACE, { band = 2, pop = { x = 29, y = 46 } })
local sn = c:ellipse(39.5, 59.5, 6, 4)
c:part(sn, FACE, { band = 1, sep = true, pop = { x = 36, y = 56 } })
under(sn, FACE.deep)
c:part(c:ellipse(39.5, 58, 3, 2), { hi = P.dusk.shade, base = P.dusk.deep, shade = "#251c42", deep = "#1e1630" }, { band = 1, pop = { x = 38, y = 57 } })
c:put(37, 57, P.stone.hi)
c:paint({ "i...i", ".iii." }, 37, 65, { i = "ink" })
c:eyeLocked(29, 49) c:eyeLocked(46, 49)
c:paint({ "PPh", "PPP" }, 26, 58, { P = "petal.base", h = "petal.hi" }) c:paint({ "hPP", "PPP" }, 51, 58, { P = "petal.base", h = "petal.hi" })
-- scarf, knot and tail
local sc = c:rrect(21, 68, 58, 74, 3)
c:part(sc, P.ember, { band = 2, pop = { x = 24, y = 69 } })
c:stitch{ { 24, 71 }, { 55, 71 } }
local tl = c:poly{ { 24, 72 }, { 30, 72 }, { 30, 90 }, { 23, 89 } }
c:part(tl, P.ember, { band = 2, sep = true, nopop = true })
c:stitch{ { 27, 75 }, { 27, 87 } }
for x = 23, 30, 2 do c:put(x, 89, P.ember.deep) end
c:part(c:ellipse(27, 73, 3, 2.5), P.ember, { band = 1, sep = true, pop = { x = 25, y = 72 } })
-- mushroom + moss tuft on the spines
local tuft = c:ellipse(26, 29, 6, 2.5) tuft:add(c:ellipse(20, 28, 2, 2)) tuft:add(c:ellipse(32, 28, 2, 1.5))
c:part(tuft, P.moss, { band = 1, sep = true, pop = { x = 19, y = 27 } })
c:part(c:rect(26, 22, 28, 28), STEM, { band = 1, nopop = true })
local cap = c:ellipse(27, 20, 6, 3.5)
c:part(cap, P.ember, { band = 2, pop = { x = 23, y = 18 } })
under(cap, P.ember.deep)
c:put(27, 18, P.cream) c:put(28, 18, P.cream) c:put(31, 20, P.cream) c:put(23, 21, P.cream)
c:finish{ outline = true }
backdrop(P.moss)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
