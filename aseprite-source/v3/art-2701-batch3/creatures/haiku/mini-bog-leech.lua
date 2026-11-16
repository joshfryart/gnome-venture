-- mini-bog-leech (61x31 still, side view, faces right). Haiku first pass.
-- Flat segmented leech: moss-green body with dark rings, a sucker at each end, a clear head with a dot eye, one sheen band (quirk).
local NAME = "mini-bog-leech"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")

local c = HP.canvas{ w = 61, h = 31, scale = 1, name = NAME }
c:groundShadow(30, 27, 24, 2)
local spine = { { 9, 21 }, { 20, 17 }, { 32, 19 }, { 43, 15 }, { 52, 16 } }
local body = c:line(spine, 8)
c:part(body, "moss", { band = 2, pop = { x = 22, y = 13 } })
-- segment rings: short darker cuts across the body
for _, x in ipairs{ 14, 19, 24, 29, 34, 39, 44, 49 } do
  local yy = 19 - (x - 9) * 0.1
  c:fillMask(c:line({ { x, yy - 5 }, { x - 1, yy + 5 } }, 1):clip(body), P.moss.deep)
end
-- sheen band along the top (quirk)
c:fillMask(c:line({ { 13, 15 }, { 26, 13 }, { 36, 14 } }, 1):clip(body), P.moss.hi)
-- suckers at both ends
c:part(c:ellipse(7, 21, 4, 3.5), "wood", { band = 1, pop = { x = 5, y = 19 } })
c:part(c:ellipse(56, 16, 5, 5), "moss", { band = 2, pop = { x = 54, y = 12 } })
c:fillMask(c:ellipse(7, 21, 1.5, 1), P.wood.deep)
-- head: two dot eyes and a pale sucker mouth
c:fillMask(c:ellipse(59, 15, 1.5, 1.5), P.cream)
c:put(59, 15, P.ink)
c:put(55, 14, P.moss.hi)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
