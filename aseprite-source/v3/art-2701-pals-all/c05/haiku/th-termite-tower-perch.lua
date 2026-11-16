-- Termite Tower (th-termite-tower), perch 36x36. Hand-built at size. Haiku first pass.
-- quirk: grains dropping from the base (see yard).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local c = HP.canvas{ w = 36, h = 36, scale = 1, name = "th-termite-tower-perch" }
c:groundShadow(18, 34, 10, 2)
c:part(c:ellipse(18, 9, 6, 2), "ember")
c:part(c:poly({ { 12, 9 }, { 24, 9 }, { 27, 33 }, { 9, 33 } }), "ember")
for _, y in ipairs({ 16, 24, 29 }) do
  for x = 11, 25 do if c:get(x, y) then c:px(x, y, P.ember.deep) end end
end
c:eyeSmall(14, 17) c:eyeSmall(20, 17)
c:px(17, 22, P.ember.deep) c:px(18, 22, P.ember.deep)
c:px(15, 26, P.ink) c:px(16, 27, P.ink) c:px(17, 27, P.ink) c:px(18, 27, P.ink) c:px(19, 26, P.ink)
c:px(6, 28, P.gold.base) c:px(30, 30, P.gold.base)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "th-termite-tower-perch.aseprite", png = out .. "th-termite-tower-perch.png", scale = 1 }
