-- npc-bramble-mossfoot portrait (npc2 P1_3) species: hedgehog
-- Same design as the sprite: brown spine cloak with pale tips, cream face + pointed snout with violet nose,
-- green knit sweater, red stitched scarf, red mushroom + moss tuft growing on the spines. Moss backdrop disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local HH = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hedgehog.lua")
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
HH.head(c, { cx = 39.5, cy = 46, s = 1.4, SP = SPN, FACE = FACE })
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
