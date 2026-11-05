-- npc-tumble-seedwell portrait (npc2 P1_36) species: hedgehog
-- Same design as the sprite: lavender quills with stuck seeds, crown sprout, peach face, long snout with
-- berry nose, pink smock with cream ruff, satchel strap; seed satchel with seeds peeking in frame. 80x100.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local HH = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hedgehog.lua")
local out = app.params.out or (DIR .. "/")
local NAME = "npc-tumble-seedwell"
local SPINE = { hi = "#c9b2f0", base = "#8a6fd0", shade = "#5a459e", deep = "#35295f" }
local FACE  = { hi = "#ffe8c8", base = "#f0c89a", shade = "#c98f72", deep = "#7a4a46" }
local SNOUT = { hi = P.cream, base = "#ffe8c8", shade = "#f0c89a", deep = "#c98f72" }
local CR    = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
local FLAP  = { hi = P.wood.hi, base = P.wood.hi, shade = P.wood.base, deep = P.wood.shade }
local SMOCK, LEAF, BAG, NOSE = P.petal, P.moss, P.wood, "#5a2a4a"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function keep(x, y, hex) if x >= 0 and y >= 0 and x < c.w and y < c.h then local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end end
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
local function spikes(m, cx, cy, rx, ry, a0, a1, step, len, half)
  for a = a0, a1, step do
    local r, h = math.rad(a), math.rad(half)
    m:add(c:poly{ { cx + math.cos(r - h) * rx * .85, cy + math.sin(r - h) * ry * .85 },
      { cx + math.cos(r + .12) * (rx + len), cy + math.sin(r + .12) * (ry + len) },
      { cx + math.cos(r + h) * rx * .85, cy + math.sin(r + h) * ry * .85 } })
  end
  return m
end
local function quills(m, cx, cy, deg)
  m:each(function(x, y)
    local a = math.deg(math.atan(y + .5 - cy, x + .5 - cx)) % 360
    local k, v = math.floor(a / deg) % 3, c:get(x, y)
    if k == 0 and v == SPINE.base then keep(x, y, SPINE.shade)
    elseif k == 0 and v == SPINE.shade then keep(x, y, SPINE.deep)
    elseif k == 1 and v == SPINE.base and x < cx and y < cy then keep(x, y, SPINE.hi) end
  end)
end
local function seed(x, y)
  c:paint({ ".hb.", "hbbs", ".bs." }, x, y, { h = "gold.hi", b = "gold.base", s = "gold.shade" })
end
-- quill mantle behind the shoulders
local mt = c:ellipse(39.5, 84, 30, 13)
spikes(mt, 39.5, 84, 30, 13, 150, 215, 16, 5, 7) spikes(mt, 39.5, 84, 30, 13, -35, 30, 16, 5, 7)
c:part(mt, SPINE, { band = 2, nopop = true }) quills(mt, 39.5, 84, 6)
-- smock
local body = c:ellipse(39.5, 106, 26, 30):clip(c:rect(0, 72, 79, 99))
c:part(body, SMOCK, { band = 3 })
for _, x in ipairs{ 31, 48 } do for y = 82, 99 do if body:shrink(1):has(x, y) then keep(x, y, SMOCK.shade) end end end
-- strap + seed satchel
c:part(c:line({ { 25, 74 }, { 52, 99 } }, 3), BAG, { band = 1, nopop = true })
c:part(c:rrect(52, 81, 73, 99, 3), BAG, { band = 2 })
c:part(c:rrect(52, 81, 73, 89, 3), FLAP, { band = 1, sep = true })
c:part(c:rect(61, 88, 63, 90), "gold", { band = 1, sep = true })
c:stitch{ { 54, 92 }, { 71, 92 } }
seed(54, 78) seed(59, 77) seed(64, 78)
c:part(c:ellipse(52, 84, 3.5, 3), FACE, { band = 1 })
-- cream ruff
local ruff = c:ellipse(39.5, 73, 13, 3)
for _, x in ipairs{ 28, 33, 39.5, 46, 51 } do ruff:add(HP.ellipse(x, 75, 2, 2)) end
c:part(ruff, CR, { band = 1 })
HH.head(c, { cx = 39.5, cy = 46, s = 1.4, SP = SPINE, FACE = FACE })
seed(25, 32) seed(50, 29) seed(57, 39)
-- crown sprout
c:part(c:line({ { 41, 27 }, { 42, 20 }, { 42, 14 } }, 2), LEAF, { band = 1, nopop = true, inner = false })
c:part(c:ellipse(37, 13, 4, 2), LEAF, { band = 1, pop = { x = 34, y = 12 } })
c:part(c:ellipse(47, 11, 4, 2), LEAF, { band = 1, sep = true, pop = { x = 45, y = 10 } })
c:finish{ outline = true }
backdrop(P.moss)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
