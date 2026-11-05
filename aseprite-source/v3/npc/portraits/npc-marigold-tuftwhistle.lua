-- npc-marigold-tuftwhistle portrait (npc2 P1_21) species: hedgehog
-- 80x100 head+shoulders: spiky quill crown, tan face with eye patches + locked eyes, pointed snout with button nose,
-- red jumper + cream collar bleeding off the bottom, brass tin whistle on a cord at the chest. Moss backdrop disc.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local HH = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hedgehog.lua")
local out = app.params.out or "./"
local NAME = "npc-marigold-tuftwhistle"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function R(v) return math.floor(v + 0.5) end
local function kp(x, y, hex) local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end
local FACE = { hi = P.cream, base = P.skinA.hi, shade = P.skinA.base, deep = P.skinA.shade }
local CR = { hi = P.cream, base = P.cream, shade = P.skinA.hi, deep = P.skinA.shade }
local NOSE = { hi = P.wood.shade, base = P.wood.deep, shade = P.skinC.deep, deep = P.skinC.deep }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end

-- jumper + collar + chin ruff
local sw = c:ellipse(39.5, 100, 33, 27):clip(c:rect(0, 0, 79, 99))
c:part(sw, P.ember, { band = 3, pop = { 15, 88 } })
for y = 82, 99 do kp(22 + (y % 2), y, P.ember.shade) kp(57 - (y % 2), y, P.ember.shade) end
c:part(c:ellipse(39.5, 71, 13, 5), FACE, { band = 1, nopop = true })
c:part(c:poly{ {28, 75}, {51, 75}, {39.5, 85} }, CR, { band = 1, sep = true, pop = { 31, 76 } })
HH.head(c, { cx = 39.5, cy = 46, s = 1.4, SP = P.wood, FACE = FACE })
-- whistle on a cord
c:line({ {30, 77}, {34, 85} }, 1):each(function(x, y) c:put(x, y, P.gold.deep) end)
c:line({ {49, 77}, {45, 85} }, 1):each(function(x, y) c:put(x, y, P.gold.deep) end)
c:part(c:rrect(33, 86, 45, 89, 1), P.gold, { band = 1, pop = { 34, 86 } })
c:part(c:rect(46, 87, 49, 88), P.gold, { band = 1, sep = true, nopop = true })
kp(37, 87, P.wood.deep) kp(38, 87, P.wood.deep) kp(41, 87, P.gold.deep)
c:finish{ outline = true }
backdrop(P.moss)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
