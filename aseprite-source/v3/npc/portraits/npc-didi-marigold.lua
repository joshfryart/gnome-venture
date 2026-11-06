-- npc-didi-marigold portrait (npc2 P1_9) species: red panda
-- 80x100 head and shoulders on a dusk disc. Same design as the sprite: rust fur, cream mask, teal overalls,
-- marigold by the ear, ringed tail curling in lower-left; prop: pink yarn ball in her paws.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-didi-marigold"
local RUST = { hi = "#f59a52", base = "#d8642f", shade = "#a53f3a", deep = "#6a2540" }
local TAN  = { hi = "#ffe0b0", base = "#e9b57e", shade = "#b97d6a", deep = "#7a4a50" }
local DARK = { hi = "#8a4f4c", base = "#64323f", shade = "#47263f", deep = "#341c33" }
local CR   = { hi = P.cream, base = P.cream, shade = "#dcc6cf", deep = "#a99aae" }
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function recol(m, map) m:each(function(x, y) local v = map[c:get(x, y) or ""] if v then c:put(x, y, v, c.own[y * c.w + x]) end end) end
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
-- ringed tail curling up lower-left
local tail = c:line({ { 10, 99 }, { 8, 88 }, { 12, 80 } }, 9):add(c:ellipse(15, 77, 5, 5))
c:part(tail, RUST, { band = 2 })
local ring = HP.mask()
tail:each(function(x, y) if math.floor((y + 0.4 * x) / 4) % 2 == 0 then ring:set(x, y) end end)
recol(ring, { [RUST.hi] = TAN.hi, [RUST.base] = TAN.base, [RUST.shade] = TAN.shade, [RUST.deep] = TAN.deep })
-- shoulders + overalls
local body = c:ellipse(39.5, 100, 27, 28):clip(c:rect(0, 70, 79, 99))
c:part(body, RUST, { band = 3, pop = { 18, 82 } })
local bib = c:rrect(27, 78, 52, 99, 3)
bib:add(c:line({ { 29, 79 }, { 26, 71 } }, 3)):add(c:line({ { 50, 79 }, { 53, 71 } }, 3))
c:part(bib, "sea", { band = 2, pop = { 29, 81 } })
c:part(c:rrect(34, 89, 45, 96, 1), "sea", { band = 1, nopop = true })
c:stitch{ { 35, 90 }, { 44, 90 } }
c:part(c:rect(28, 78, 30, 80), "gold", { band = 1 }) c:part(c:rect(49, 78, 51, 80), "gold", { band = 1 })
-- yarn ball + loose end
local ball = c:ellipse(56, 87, 8, 7.5)
c:part(ball, "petal", { band = 2, pop = { 51, 82 } })
for _, l in ipairs{ { { 50, 83 }, { 58, 93 } }, { { 53, 81 }, { 62, 89 } }, { { 49, 89 }, { 53, 93 } }, { { 57, 80 }, { 63, 85 } } } do
  c:fillMask(c:line(l, 1):clip(ball:shrink(1)), P.petal.shade)
end
c:fillMask(c:line({ { 62, 92 }, { 66, 95 }, { 65, 99 } }, 1), P.petal.base)
-- arms + paws
c:part(c:line({ { 38, 99 }, { 48, 89 } }, 6), DARK, { band = 1, nopop = true })
c:part(c:line({ { 72, 99 }, { 64, 84 } }, 6), DARK, { band = 1, nopop = true })
c:part(c:ellipse(49, 88, 3.5, 3), DARK, { band = 1 }) c:part(c:ellipse(63, 83, 3.5, 3), DARK, { band = 1 })
-- ears: cream rims, dark inner
c:part(c:poly{ { 20, 46 }, { 20, 27 }, { 24, 23 }, { 36, 35 } }, CR, { band = 1, nopop = true })
c:part(c:poly{ { 23, 42 }, { 23, 29 }, { 31, 36 } }, DARK, { band = 1, nopop = true })
c:part(c:poly{ { 59, 46 }, { 59, 27 }, { 55, 23 }, { 43, 35 } }, CR, { band = 1, nopop = true })
c:part(c:poly{ { 56, 42 }, { 56, 29 }, { 48, 36 } }, DARK, { band = 1, nopop = true })
-- marigold behind the right ear
local fl = c:ellipse(63, 35, 3, 3)
for i = 0, 7 do local a = math.rad(i * 45) fl:add(c:ellipse(63 + math.cos(a) * 3.5, 35 + math.sin(a) * 3.5, 1.8, 1.8)) end
c:part(fl, "gold", { band = 2, pop = { 60, 32 } })
c:fillMask(c:rect(62, 34, 63, 35), P.gold.deep) c:put(62, 34, P.ember.base)
-- head
local head = c:ellipse(39.5, 51, 20, 16.5)
c:part(head, RUST, { band = 3, pop = { 26, 39 } })
for _, s in ipairs{ { 33, 37, 34, 36 }, { 44, 37, 45, 36 }, { 39, 35, 40, 35 } } do
  c:fillMask(c:line({ { s[1], s[2] }, { s[3], s[4] } }, 1), RUST.hi)
end
-- cream mask: cheek ruffs, muzzle, brows
local ck = c:ellipse(26, 60, 8, 6):add(c:ellipse(53, 60, 8, 6)):add(c:ellipse(18, 64, 3, 2.5)):add(c:ellipse(61, 64, 3, 2.5))
c:part(ck, CR, { band = 2, nopop = true })
c:part(c:ellipse(39.5, 61, 8, 5.5), CR, { band = 1, nopop = true })
c:part(c:ellipse(30, 44, 2.5, 1.5), CR, { noshade = true, nopop = true, inner = false })
c:part(c:ellipse(49, 44, 2.5, 1.5), CR, { noshade = true, nopop = true, inner = false })
-- tear marks, eyes, nose, mouth, blush
c:fillMask(c:line({ { 30, 53 }, { 29, 57 } }, 2), RUST.shade) c:fillMask(c:line({ { 49, 53 }, { 50, 57 } }, 2), RUST.shade)
c:eyeLocked(28, 48) c:eyeLocked(47, 48)
c:paint({ "NNNNNN", ".NNNN.", "..NN.." }, 37, 56, { N = DARK.base }) c:put(38, 56, DARK.hi) c:put(39, 56, DARK.hi)
c:paint({ "..ii..", "i.ii.i", ".i..i." }, 37, 59, { i = "ink" })
c:cheek(22, 58) c:cheek(56, 58)
c:finish{ outline = true }
backdrop(P.dusk)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
