-- mini-basalt-borer (81x49 still, side view, faces right). Haiku first pass.
-- Dark stone grub: ringed basalt segments, a drill head with pale mandibles, stubby legs, ember vein glow (quirk).
local NAME = "mini-basalt-borer"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")

local c = HP.canvas{ w = 81, h = 49, scale = 1, name = NAME }
c:groundShadow(40, 45, 32, 2)
-- stubby legs under the body
for _, x in ipairs{ 18, 32, 46, 58 } do c:part(c:rect(x, 36, x + 2, 41), "stone", { band = 1, nopop = true }) end
-- body: tail, middle, head segment
c:part(c:rrect(6, 20, 40, 39, 9), "stone", { band = 3, pop = { x = 12, y = 24 } })
c:part(c:rrect(30, 16, 62, 39, 9), "stone", { band = 3, pop = { x = 36, y = 20 } })
-- segment rings (deep lines between segments)
for _, x in ipairs{ 14, 22, 30, 38, 46, 54 } do c:fillMask(c:line({ { x, 21 }, { x, 38 } }, 1), P.stone.deep) end
-- ember vein glowing through the basalt (quirk)
c:fillMask(c:line({ { 12, 28 }, { 20, 26 }, { 26, 31 }, { 34, 28 } }, 1), P.ember.base)
c:put(20, 26, P.ember.hi)
-- head: round cap, drill cone and pale mandibles
c:part(c:ellipse(68, 28, 10, 10), "stone", { band = 2, pop = { x = 62, y = 22 } })
c:part(c:poly{ { 74, 22 }, { 80, 28 }, { 74, 34 } }, "wood", { band = 1, pop = { x = 76, y = 27 } })
c:part(c:poly{ { 60, 36 }, { 66, 41 }, { 72, 36 } }, "gold", { band = 1, nopop = true })
c:eyeSmall(63, 24)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
