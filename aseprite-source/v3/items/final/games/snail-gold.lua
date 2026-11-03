local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA0.lua")
local HP, X, K, INK, CREAM = D.HP, D.X, D.K, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- snail-gold: a left-facing snail with a tall, pointed, ridged golden turret shell (four whorls), pale butter body.
-- quirk: it is fast asleep, eyes shut, with little z's drifting up.
local c = D.new("snail-gold")
local BODY = { "#8a6a40", "#b89a60", "#d8bc80", "#ecd8a0", "#f8ecc0", "#fff8dc" }
local G = { "#8f4a1f", "#c06a22", "#d98322", "#f5b82e", "#ffd860", "#fff0a8" }
c:groundShadow(34, 56, 25, 2)
local bm = D.sweep({ {57, 52}, {38, 55}, {18, 53}, {11, 38} }, function(t) return t < 0.25 and 1 + t * 11 or (t > 0.8 and 3.6 - (t - 0.8) * 4 or 3.6) end, 60)
bm:add(c:ellipse(11, 37, 4, 4))
D.lit(c, bm, BODY, 3, { amb = 0.15 })
for x = 17, 52 do if bm:has(x, 55) then D.shift(c, x, 55, BODY, -2) end end
D.stalk(c, 8, 34, 7, 25, BODY[2], true)
D.stalk(c, 13, 34, 14, 27, BODY[2], true)
local w = { c:ellipse(38, 42, 13, 10), c:ellipse(37, 31, 10, 8), c:ellipse(36, 22, 7, 6), c:ellipse(35, 15, 4, 4) }
for i, m in ipairs(w) do
  D.lit(c, m, G, 5, { amb = 0.1 })
  if i > 1 then D.seam(c, w[i - 1], m, G[1]) end
end
-- ridges
for i = 1, 3 do local m = w[i]
  m:each(function(x, y) if y == floor(m:bbox() and 0 or 0) then end end)
end
for _, r in ipairs{ {38, 42, 13, 10}, {37, 31, 10, 8}, {36, 22, 7, 6} } do
  for a = 0.15, 0.9, 0.05 do
    local x, y = floor(r[1] + cos(a * pi * 2) * r[3] * 0.6 + .5), floor(r[2] + sin(a * pi * 2) * r[4] * 0.6 + .5)
    if c:get(x, y) then D.shift(c, x, y, G, -1) end
  end
end
c:px(31, 40, "#fff8dc") c:px(31, 39, "#fff0a8") c:px(32, 38, "#fff0a8") c:px(33, 30, "#fff0a8")
-- z z z
local z = { "ZZZ", "..Z", ".Z.", "Z..", "ZZZ" }
c:paint({ "ZZ", ".Z", "ZZ" }, 15, 12, { Z = CREAM })
c:paint(z, 6, 7, { Z = "#b6f0e0" })
D.fin()
