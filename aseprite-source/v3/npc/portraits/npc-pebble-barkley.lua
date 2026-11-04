-- npc-pebble-barkley portrait (npc2 P1_28) species: tortoise
-- Elder tortoise: bark carapace rising behind the shoulders, red coat + gold collar, wrinkled neck,
-- crown scutes, bushy cream brows, hooked horn beak, kind smile. Prop in frame: walking stick with sprout.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-pebble-barkley"
local SKIN = { hi = "#d4e08e", base = "#97b85e", shade = "#5f8456", deep = "#344a4a" }
local BARK = { hi = "#c7956a", base = "#94603f", shade = "#64413f", deep = "#3e2836" }
local CREAM = { hi = P.cream, base = "#f3e2b8", shade = "#d4b98e", deep = "#9a7a5e" }
local HORN = { hi = "#efe0b0", base = "#c9b27e", shade = "#97805e", deep = "#5e4a42" }
local LAV = { base = "#b9a6e8", shade = "#9580d0", deep = "#6e58a8" }
local COAT = P.ember
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function keep(x, y, hex) local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end

-- carapace: marginal ring, radial seams, bark grain
local sh = c:ellipse(39.5, 77, 29, 26)
c:part(sh, BARK, { band = 3, pop = { 18, 62 } })
local rim = c:ellipse(39.5, 79, 23.5, 20.5)
rim:edge():each(function(x, y) if sh:has(x, y) then keep(x, y, BARK.deep) end end)
for a = 180, 360, 22 do
  local r = math.rad(a)
  c:line({ { 39.5 + math.cos(r) * 24, 79 + math.sin(r) * 21 }, { 39.5 + math.cos(r) * 30, 77 + math.sin(r) * 27 } }, 1)
    :clip(sh):each(function(x, y) keep(x, y, BARK.deep) end)
end
sh:each(function(x, y) if (x * 5 + y * 2) % 9 == 0 and c:get(x, y) == BARK.base then keep(x, y, BARK.shade) keep(x, y + 1, BARK.shade) end end)
sh:each(function(x, y) if (x * 3 + y * 7) % 23 == 0 and c:get(x, y) == BARK.base then keep(x, y, BARK.hi) end end)
-- red coat + lapels
local coat = c:ellipse(39.5, 95, 23, 21)
c:part(coat, COAT, { band = 2 })
c:part(c:poly{ { 26, 77 }, { 39, 88 }, { 39, 99 }, { 30, 99 } }, COAT, { band = 1, sep = true, nopop = true })
c:part(c:poly{ { 53, 77 }, { 40, 88 }, { 40, 99 }, { 49, 99 } }, COAT, { band = 1, sep = true, nopop = true })
-- wrinkled neck + gold collar
c:part(c:rrect(30, 56, 49, 77, 3), SKIN, { band = 2 })
for _, y in ipairs{ 63, 67, 71 } do for x = 33, 46 do if (x + y) % 4 ~= 0 then keep(x, y, SKIN.shade) end end end
c:part(c:rrect(29, 73, 50, 76, 1), P.gold, { band = 1 })
c:part(c:ellipse(39.5, 81, 1.5, 1.5), P.gold, { band = 1 })
-- head + crown scutes
local hd = c:ellipse(39.5, 44, 20, 16.5)
c:part(hd, SKIN, { band = 3, pop = { 26, 33 } })
for _, s in ipairs{ { { 33, 28 }, { 46, 28 }, { 49, 33 }, { 40, 36 }, { 30, 33 } },
                    { { 22, 36 }, { 30, 33 }, { 32, 37 }, { 23, 40 } },
                    { { 57, 36 }, { 49, 33 }, { 47, 37 }, { 56, 40 } } } do
  c:poly(s):edge():clip(hd):each(function(x, y) keep(x, y, SKIN.shade) end)
end
keep(36, 30, SKIN.hi) keep(37, 30, SKIN.hi)
-- muzzle + horn beak + nostrils + smile
c:part(c:ellipse(39.5, 53, 10, 5.5), CREAM, { band = 1, nopop = true })
for x = 36, 43 do keep(x, 48, HORN.base) end
for x = 37, 42 do keep(x, 49, HORN.base) end
for x = 38, 41 do keep(x, 50, HORN.shade) end
keep(39, 51, HORN.deep) keep(40, 51, HORN.deep) keep(36, 48, HORN.hi) keep(37, 48, HORN.hi)
keep(38, 48, P.ink) keep(41, 48, P.ink)
for x = 33, 46 do keep(x, 56, P.ink) end
keep(32, 55, P.ink) keep(47, 55, P.ink) keep(31, 54, P.ink) keep(48, 54, P.ink)
for x = 36, 43 do keep(x, 57, CREAM.shade) end
-- eyes + elder brows + cheeks
c:eyeLocked(28, 41) c:eyeLocked(47, 41)
for x = 27, 33 do keep(x, 40, SKIN.deep) end for x = 46, 52 do keep(x, 40, SKIN.deep) end
for _, q in ipairs{ { 26, 38 }, { 27, 37 }, { 28, 37 }, { 29, 36 }, { 30, 37 }, { 31, 37 }, { 32, 38 }, { 33, 38 },
                    { 53, 38 }, { 52, 37 }, { 51, 37 }, { 50, 36 }, { 49, 37 }, { 48, 37 }, { 47, 38 }, { 46, 38 } } do keep(q[1], q[2], P.cream) end
for _, q in ipairs{ { 26, 39 }, { 25, 38 }, { 53, 39 }, { 54, 38 }, { 30, 38 }, { 49, 38 } } do keep(q[1], q[2], CREAM.shade) end
for _, x in ipairs{ 23, 54 } do c:cheek(x, 50) c:cheek(x, 51) end
-- walking stick with sprout, gripped
local st = c:line({ { 66, 99 }, { 65, 86 }, { 66, 72 }, { 64, 60 } }, 3)
c:part(st, P.wood, { band = 1, pop = { 64, 62, horizontal = false } })
for _, y in ipairs{ 66, 75, 93 } do keep(66, y, P.wood.shade) keep(66, y + 1, P.wood.shade) end
c:part(c:poly{ { 64, 59 }, { 57, 52 }, { 60, 50 }, { 66, 56 } }, P.moss, { band = 1 })
c:part(c:poly{ { 65, 59 }, { 71, 52 }, { 74, 55 }, { 68, 60 } }, P.moss, { band = 1, sep = true })
c:part(c:ellipse(62, 93, 5, 6), COAT, { band = 1, sep = true })
c:part(c:ellipse(65, 82, 4, 3.5), SKIN, { band = 1 })
for _, y in ipairs{ 81, 83 } do keep(67, y, SKIN.deep) keep(68, y, SKIN.deep) end
c:finish{ outline = true }
backdrop(LAV)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
