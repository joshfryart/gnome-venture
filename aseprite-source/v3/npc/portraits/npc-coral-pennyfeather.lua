-- npc-coral-pennyfeather portrait (npc2 P1_7) species: coral finch (songbird)
-- Same design as the sprite: plump coral finch, plaid tam with gold pom, conical gold beak,
-- cream apron with stitched flower, fishing pole held in her wing with a teal feather lure.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-coral-pennyfeather"
local CO  = { hi = "#ffb8a0", base = "#f5876f", shade = "#c95a63", deep = "#7d2c5e" }
local CRM = { hi = P.cream, base = "#f7e8c6", shade = "#e2cba6", deep = P.stone.base }
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
-- body + apron
local body = c:ellipse(39.5, 106, 31, 29):clip(c:rect(0, 0, 79, 99))
c:part(body, CO, { band = 3, pop = { x = 16, y = 86 } })
for _, f in ipairs{ { 14, 92 }, { 19, 86 }, { 60, 88 }, { 22, 95 } } do c:put(f[1], f[2], CO.shade) c:put(f[1] + 1, f[2] + 1, CO.shade) end
local bib = c:rrect(28, 83, 51, 99, 4)
c:part(bib, CRM, { band = 2, pop = { x = 30, y = 84 } })
c:part(c:line({ { 30, 84 }, { 27, 77 } }, 2), CRM, { band = 1, nopop = true })
c:part(c:line({ { 49, 84 }, { 52, 77 } }, 2), CRM, { band = 1, nopop = true })
c:paint({ ".P.", "PGP", ".P." }, 38, 89, { P = "petal.base", G = "gold.base" })
c:paint({ "m.", ".m" }, 40, 92, { m = "moss.shade" })
c:stitch{ { 31, 97 }, { 48, 97 } }
-- fishing pole + gripping wing
c:part(c:line({ { 64, 99 }, { 70, 8 } }, 3), P.wood, { band = 1, nopop = true })
local lure = c:poly{ { 75, 26 }, { 77, 30 }, { 76, 36 }, { 74, 36 }, { 73, 30 } }
c:part(lure, P.sea, { band = 1, pop = { x = 74, y = 29 } })
c:fillMask(c:line({ { 75, 27 }, { 75, 35 } }, 1), P.sea.deep)
c:part(c:ellipse(75, 24, 1.5, 1.5), P.gold, { band = 1, nopop = true })
local wing = c:ellipse(63, 88, 7, 9)
c:part(wing, CO, { band = 2, sep = true, pop = { x = 59, y = 82 } })
c:fillMask(c:line({ { 59, 90 }, { 64, 95 } }, 1):clip(wing:shrink(1)), CO.shade)
-- head
local head = c:ellipse(39.5, 53, 20, 18)
c:part(head, CO, { band = 3, sep = true, pop = { x = 25, y = 47 } })
c:eyeLocked(28, 49) c:eyeLocked(47, 49)
c:put(27, 47, CO.deep) c:put(28, 47, CO.deep) c:put(51, 47, CO.deep) c:put(52, 47, CO.deep) -- brow feathers
local beak = c:poly{ { 35, 56 }, { 45, 56 }, { 42, 64 }, { 38, 64 } }
c:part(beak, P.gold, { band = 1, pop = { x = 37, y = 57 } })
for x = 36, 44 do if beak:has(x, 60) then c:put(x, 60, P.gold.deep) end end
c:put(38, 58, P.gold.shade)
c:paint({ "PPP", "PPP" }, 23, 59, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 54, 59, { P = "petal.base" })
c:put(23, 59, P.petal.hi) c:put(54, 59, P.petal.hi)
-- plaid tam + pom
local cap = c:ellipse(39.5, 37, 23, 6.5):add(c:ellipse(38, 32, 18, 6))
c:part(cap, P.ember, { band = 2, pop = { x = 24, y = 29 } })
cap:shrink(1):each(function(x, y)
  local v = c:get(x, y)
  local dark = (v == P.ember.shade or v == P.ember.deep)
  if x % 5 == 0 then c:put(x, y, dark and P.gold.shade or P.gold.base)
  elseif y % 4 == 0 then c:put(x, y, dark and P.moss.shade or P.moss.base) end
end)
local pom = c:ellipse(50, 24, 4, 4)
c:part(pom, P.gold, { band = 1, pop = { x = 48, y = 22 } })
c:put(51, 23, P.gold.shade) c:put(49, 26, P.gold.shade) c:put(53, 25, P.gold.shade)
c:finish{ outline = true }
c:fillMask(c:line({ { 71, 8 }, { 74, 14 }, { 75, 22 } }, 1), P.stone.deep)
backdrop(P.sky)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
