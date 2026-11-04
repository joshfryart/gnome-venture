-- npc-bramble-mossfoot PASS 1 (form). Hearth Pop v3, 80x100 portrait. Hedgehog villager.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-bramble-mossfoot.p1"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade) end end)
end
local FACE = { hi = P.cream, base = P.cream, shade = P.skinA.hi, deep = P.skinA.shade }

-- jumper
local jum = c:poly{ {3,100},{6,86},{15,76},{30,70},{50,70},{65,76},{74,86},{77,100} }
c:part(jum, "moss", { band = 3 })
c:button(40, 90)

-- spike crown
local cx, cy = 40, 45
local mass = c:ellipse(cx, cy, 23, 21)
local spikes = {}
local n = 13
for i = 0, n - 1 do
  local a = math.rad(160 + i * (220 / (n - 1)))
  local len = ({ 32, 35, 33 })[i % 3 + 1]
  local w = 0.24
  local tip = { cx + math.cos(a) * len, cy + math.sin(a) * len * 0.95 }
  local s = c:poly{ { cx + math.cos(a - w) * 19, cy + math.sin(a - w) * 18 }, tip, { cx + math.cos(a + w) * 19, cy + math.sin(a + w) * 18 } }
  mass:add(s)
  spikes[#spikes + 1] = { s = s, tip = tip }
end
c:part(mass, "wood", { band = 3 })
for _, sp in ipairs(spikes) do
  local tx, ty = math.floor(sp.tip[1] + .5), math.floor(sp.tip[2] + .5)
  c:fillMask(c:ellipse(tx, ty, 2, 2):clip(sp.s):clip(mass), P.wood.hi)
end

-- ears
c:part(c:ellipse(23, 38, 3, 3), "skinA", { band = 1, nopop = true })
c:part(c:ellipse(57, 38, 3, 3), "skinA", { band = 1, nopop = true })
c:px(23, 38, P.petal.base) c:px(57, 38, P.petal.base)

-- face (cream) with spike widow's peak
local face = c:ellipse(40.5, 51, 17, 14):add(c:poly{ {26,46},{34,38},{40,34},{46,38},{55,46} }):cut(c:poly{ {37,31},{40,40},{43,31} })
c:part(face, FACE, { nopop = true })
-- muzzle
c:part(c:ellipse(43, 56, 7, 5), FACE, { nopop = true, band = 1 })
c:fillMask(c:rrect(46, 52, 50, 55, 1), P.ink) c:px(47, 53, P.cream)
c:px(43, 59, P.skinA.shade) c:px(44, 60, P.skinA.shade) c:px(45, 60, P.skinA.shade) c:px(46, 59, P.skinA.shade)
c:fillMask(c:rrect(28, 42, 36, 50, 3), P.wood.hi) c:fillMask(c:rrect(42, 42, 50, 50, 3), P.wood.hi)
c:eyeLocked(30, 44) c:eyeLocked(44, 44)
c:cheek(28, 52) c:cheek(52, 51)

-- scarf
c:part(c:poly{ {24,66},{40,70},{56,66},{58,72},{40,77},{22,72} }, "ember")
c:part(c:poly{ {26,72},{33,74},{31,90},{24,89} }, "ember", { band = 2 })
-- quirk: leaf tucked behind the right ear
c:part(c:poly{ {58,37},{62,29},{68,24},{70,27},{66,34} }, "moss", { band = 1 })
c:fillMask(c:line({ {60,35},{67,26} }, 1), P.moss.shade)

c:finish{ outline = true }
backdrop(P.sky)
HP.report(c) HP.assertClean(c)
c:save{ png = out .. NAME .. ".png", scale = 1 }
