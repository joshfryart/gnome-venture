-- mini-clam-lurker (61x45 still, faces right). Haiku first pass.
-- Open clam: ribbed petal-pink lower shell, a raised upper shell on a hinge, pearly sky-pale flesh with one eye on it (the head fix), a pale tooth row (quirk).
local NAME = "mini-clam-lurker"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")

local c = HP.canvas{ w = 61, h = 45, scale = 1, name = NAME }
c:groundShadow(30, 41, 24, 2)
-- lower shell: half-disc, ribbed
local low = c:ellipse(30, 30, 26, 11):clip(c:rect(0, 30, 60, 40))
c:part(low, "petal", { band = 3, pop = { x = 12, y = 33 } })
for _, a in ipairs{ -60, -35, -10, 15, 40 } do
  local r = math.rad(a)
  c:fillMask(c:line({ { 30, 35 }, { 30 + math.cos(r) * 26, 35 + math.sin(r) * 11 } }, 1):clip(low), P.petal.shade)
end
-- pale flesh between the halves
c:part(c:ellipse(38, 29, 12, 5), "sky", { band = 1, pop = { x = 33, y = 27 } })
-- upper shell, lifted open on the left
local up = c:ellipse(28, 16, 25, 13):clip(c:rect(0, 0, 60, 27))
c:part(up, "petal", { band = 3, pop = { x = 14, y = 9 } })
for _, a in ipairs{ 200, 220, 245, 270 } do
  local r = math.rad(a)
  c:fillMask(c:line({ { 28, 27 }, { 28 + math.cos(r) * 25, 16 + math.sin(r) * 13 } }, 1):clip(up), P.petal.deep)
end
-- eye and a fringe of teeth on the flesh
c:eyeSmall(40, 26)
for _, x in ipairs{ 34, 37, 40, 43, 46 } do c:put(x, 31, P.cream) end
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
