-- npc-willow-rootstock portrait (npc2 P1_38) species: hare
-- Same design as the sprite: tan hare, blue headband + bow, violet shirt, cream bib apron, flopped right ear,
-- buck teeth. Prop: grafted sapling in a burlap root ball held in the paw. Backdrop: moss disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-willow-rootstock"
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local FUR = { hi = "#f2c98e", base = "#d49a5e", shade = "#a0684e", deep = "#5e3a3e" }
local MUZ = { hi = P.cream, base = "#f6e2c0", shade = "#d8b49a", deep = "#a0684e" }
local APR = { hi = P.cream, base = "#f3e6c8", shade = P.stone.hi, deep = P.stone.base }
local BAND = { hi = P.sea.base, base = P.sea.shade, shade = P.sea.deep, deep = "#22305a" }
local BUR = { hi = "#e0c08a", base = "#b89464", shade = "#86664e", deep = "#53403e" }
local LEAF = { hi = P.moss.hi, base = "#9ccf5c", shade = P.moss.shade, deep = P.moss.deep }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg)
  local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  for y = math.floor(cy - rx - 1), math.ceil(cy + rx + 1) do for x = math.floor(cx - rx - 1), math.ceil(cx + rx + 1) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
-- ears
local eL = c:line({ { 30, 42 }, { 27, 24 }, { 26, 8 } }, 9)
local eR = c:line({ { 50, 42 }, { 54, 26 }, { 58, 17 }, { 66, 19 } }, 8)
c:part(eL, FUR, { band = 2, pop = { 24, 14 } }) c:part(eR, FUR, { band = 2, pop = { 52, 30 } })
c:part(c:line({ { 29, 38 }, { 27, 24 }, { 26, 11 } }, 3):clip(eL:shrink(2)), P.petal, { band = 1, inner = false, nopop = true })
c:part(c:line({ { 51, 38 }, { 54, 27 }, { 57, 21 } }, 3):clip(eR:shrink(2)), P.petal, { band = 1, inner = false, nopop = true })
c:fillMask(c:line({ { 58, 15 }, { 60, 16 }, { 61, 19 } }, 1):clip(eR), FUR.deep)
-- body + apron
local body = c:ellipse(39.5, 108, 34, 32):clip(c:rect(0, 70, 79, 99))
c:part(body, P.dusk, { band = 3 })
c:part(c:rrect(29, 80, 50, 99, 3), APR, { band = 2, nopop = true })
c:part(c:line({ { 31, 81 }, { 29, 73 } }, 3), APR, { band = 1, nopop = true })
c:part(c:line({ { 48, 81 }, { 50, 73 } }, 3), APR, { band = 1, nopop = true })
c:stitch{ { 33, 91 }, { 46, 91 } }
c:button(31, 82) c:button(48, 82)
-- sapling prop
c:part(c:line({ { 63, 86 }, { 64, 72 }, { 66, 58 } }, 2), P.wood, { band = 1, nopop = true })
for _, lf in ipairs({ { 59, 66, 5, 2, -25 }, { 71, 62, 5, 2, 25 }, { 67, 53, 2, 4, 15 }, { 60, 75, 3.5, 1.5, -15 } }) do
  local m = oval(lf[1], lf[2], lf[3], lf[4], lf[5])
  c:part(m, LEAF, { band = 1 })
end
c:fillMask(c:line({ { 63, 67 }, { 56, 65 } }, 1), P.moss.shade) c:fillMask(c:line({ { 66, 63 }, { 74, 61 } }, 1), P.moss.shade)
c:part(c:rect(62, 73, 65, 75), P.gold, { band = 1, pop = { 62, 73 } })
local ball = c:ellipse(65, 92, 8, 7)
c:part(ball, BUR, { band = 2 })
c:fillMask(c:line({ { 58, 94 }, { 72, 88 } }, 1):clip(ball), BUR.deep)
c:fillMask(c:line({ { 60, 87 }, { 70, 97 } }, 1):clip(ball), BUR.deep)
c:part(c:ellipse(56, 91, 4, 3.5), FUR, { band = 1 })
c:put(55, 94, FUR.deep) c:put(58, 94, FUR.deep)
-- head
local head = c:ellipse(39.5, 52, 20.5, 17)
for _, q in ipairs({ { 19.5, 58, 2.5 }, { 21, 62, 2 }, { 59.5, 58, 2.5 }, { 58, 62, 2 } }) do head:add(HP.ellipse(q[1], q[2], q[3], q[3])) end
c:part(head, FUR, { band = 3, sep = true, pop = { 27, 42 } })
local band = c:ellipse(39.5, 66, 24, 28):cut(c:ellipse(39.5, 66, 24, 25)):clip(head)
c:part(band, BAND, { band = 1 })
local bow = c:ellipse(62, 40, 3, 2.5):add(c:ellipse(63, 47, 2.5, 2.5))
c:part(bow, BAND, { band = 1, sep = true })
c:part(c:rect(59, 42, 60, 44), BAND, { band = 1, sep = true, nopop = true })
-- muzzle, nose, mouth, buck teeth
c:part(c:ellipse(39.5, 59, 8, 5.5), MUZ, { band = 2, nopop = true })
c:paint({ "hPPS", ".PS.", ".ii.", "i..i", "sCCs", ".CC.", ".ss." }, 38, 55,
  { h = "petal.hi", P = "petal.base", S = "petal.shade", i = "ink", C = "cream", s = "stone.base" })
c:eyeLocked(28, 47) c:eyeLocked(46, 47)
c:paint({ "PPP", "PPP" }, 24, 56, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 53, 56, { P = "petal.base" })
c:put(24, 56, P.petal.hi) c:put(53, 56, P.petal.hi)
-- whisker dots
for _, q in ipairs({ { 33, 59 }, { 34, 61 }, { 45, 59 }, { 44, 61 } }) do c:put(q[1], q[2], FUR.shade) end
c:finish{ outline = true }
backdrop(P.moss)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
