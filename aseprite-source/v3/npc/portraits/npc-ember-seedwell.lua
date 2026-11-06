-- npc-ember-seedwell portrait (npc2 P1_9) species: snail
-- 80x100 head and shoulders on a gold disc. Same design as the sprite: cream-tan snail, eyes on stalk bulbs,
-- red pillbox hat, grey-violet coat, brown spiral shell; prop: clay pot with a sprout (seed husk still on a leaf).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-ember-seedwell"
local SLUG  = { hi = "#fff0c8", base = "#ecc995", shade = "#c4936f", deep = "#85564b" }
local SHELL = { hi = "#e8a86a", base = "#b8693e", shade = "#7f4034", deep = "#4e2a3f" }
local COAT  = { hi = "#d8d3dc", base = "#a39cad", shade = "#706984", deep = "#463f5e" }
local CLAY  = { hi = "#f7b27a", base = "#e07a48", shade = "#a84a3c", deep = "#68283a" }
local HATTOP = { hi = "#ffb08a", base = P.ember.hi, shade = P.ember.base, deep = P.ember.shade }
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
-- spiral shell behind the right shoulder
local sh = c:ellipse(60, 66, 15, 15)
c:part(sh, SHELL, { band = 3, pop = { 51, 56 } })
local pts = {}
for i = 0, 160 do local t = i / 160 local a = math.rad(160) + t * 2.6 * 2 * math.pi local r = 13.5 * (1 - t)
  pts[#pts + 1] = { math.floor(60 + math.cos(a) * r + .5), math.floor(66 + math.sin(a) * r + .5) } end
c:fillMask(c:line(pts, 1):clip(sh:shrink(1)), SHELL.deep)
for _, q in ipairs{ { 50, 58 }, { 51, 57 }, { 52, 56 }, { 53, 55 }, { 55, 54 } } do c:put(q[1], q[2], SHELL.hi) end
-- coat
local body = c:ellipse(39.5, 104, 28, 30):clip(c:rect(0, 72, 79, 99))
c:part(body, COAT, { band = 3, pop = { 20, 82 } })
c:part(c:poly{ { 32, 72 }, { 47, 72 }, { 39.5, 85 } }, SLUG, { band = 1, nopop = true })
c:fillMask(c:line({ { 31, 74 }, { 39, 87 } }, 1), COAT.deep) c:fillMask(c:line({ { 48, 74 }, { 40, 87 } }, 1), COAT.deep)
for y = 87, 99 do c:put(39, y, COAT.deep) end
c:part(c:rect(41, 89, 42, 90), "gold", { band = 1 }) c:part(c:rect(41, 95, 42, 96), "gold", { band = 1 })
-- clay pot + sprout, held lower-left
c:part(c:poly{ { 13, 81 }, { 29, 81 }, { 27, 97 }, { 15, 97 } }, CLAY, { band = 2, nopop = true })
c:part(c:rrect(11, 77, 31, 81, 1), CLAY, { band = 1, pop = { 13, 78 } })
c:fillMask(c:rect(13, 77, 29, 77), SHELL.deep)
c:fillMask(c:line({ { 21, 76 }, { 21, 69 } }, 1), P.moss.shade)
c:part(c:ellipse(17.5, 68, 3.5, 2), "moss", { band = 1, pop = { 15, 67 } })
c:part(c:ellipse(25, 66, 3.5, 2), "moss", { band = 1, pop = { 23, 65 } })
c:part(c:ellipse(28, 64, 1.5, 1.5), { hi = P.wood.hi, base = P.wood.base, shade = P.wood.shade, deep = P.wood.deep }, { band = 1, nopop = true })
c:part(c:ellipse(12, 87, 3, 3), SLUG, { band = 1 }) c:part(c:ellipse(30, 87, 3, 3), SLUG, { band = 1 })
-- eyestalks + bulbs with locked eyes
c:part(c:line({ { 32, 46 }, { 29, 34 }, { 27, 25 } }, 3), SLUG, { band = 1, nopop = true })
c:part(c:line({ { 47, 46 }, { 50, 34 }, { 52, 25 } }, 3), SLUG, { band = 1, nopop = true })
c:part(c:ellipse(27, 21, 5, 4.5), SLUG, { band = 1, nopop = true })
c:part(c:ellipse(52, 21, 5, 4.5), SLUG, { band = 1, nopop = true })
c:eyeLocked(25, 19) c:eyeLocked(50, 19)
-- head
c:part(c:ellipse(39.5, 57, 20, 15.5), SLUG, { band = 3, pop = { 26, 49 } })
c:put(25, 51, SLUG.hi) c:put(24, 52, SLUG.hi)
-- snout nub with drooping lower feelers
c:part(c:line({ { 35, 63 }, { 31, 67 } }, 2), SLUG, { band = 1, nopop = true })
c:part(c:line({ { 44, 63 }, { 48, 67 } }, 2), SLUG, { band = 1, nopop = true })
c:part(c:ellipse(39.5, 61, 6, 4), SLUG, { band = 1, pop = { 36, 59 } })
c:paint({ "i....i", ".iiii." }, 37, 66, { i = "ink" })
c:cheek(25, 62) c:cheek(53, 62)
-- red pillbox hat
c:part(c:rect(29, 37, 50, 45), P.ember, { band = 2, nopop = true })
c:part(c:ellipse(39.5, 37, 10.5, 3), HATTOP, { band = 1, pop = { 33, 36 } })
c:stitch{ { 29, 43 }, { 50, 43 } }
c:part(c:ellipse(39.5, 33.5, 1.5, 1.5), "gold", { band = 1 })
c:finish{ outline = true }
backdrop(P.gold)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
