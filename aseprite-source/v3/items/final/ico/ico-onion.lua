-- ico-onion first draft (Sonnet). quirk: a single teardrop rolls down its cheek
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA7.lua")
local HP, INK, CR = D.HP, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new("ico-onion")
local PL = { "#4a1f45", "#7a2f6a", "#a8458a", "#c860a4", "#e486bc", "#ffb8d8" }
c:groundShadow(32, 58, 16, 2)
local bulb = D.ell(32, 39, 17, 15):add(c:poly{ {20, 30}, {28, 17}, {36, 17}, {44, 30} })
D.lit(bulb, PL, 8, { amb = .1 })
for _, o in ipairs{ -12, -6, 6, 12 } do
  for y = 20, 52 do
    local t = (y - 17) / 36
    local x = floor(32 + o * sin(pi * min(1, t * 1.1)) ^ 0.8 + .5)
    if bulb:has(x, y) then c:px(x, y, PL[2]) end
  end
end
-- neck stalk
D.lit(c:poly{ {29, 17}, {35, 17}, {37, 10}, {27, 8} }, "wood", 2)
D.fill(c:rect(29, 8, 36, 9), "#e8b982")
D.leaf(34, 9, 46, 2, 3, "moss") D.leaf(30, 9, 20, 3, 3, "moss")
-- roots
for _, x in ipairs{ 28, 31, 34, 37 } do D.fill(c:rect(x, 53, x, 57), "#e8b982") end
-- face
c:eyeSmall(24, 36) c:eyeSmall(37, 36)
D.fill(c:rect(29, 44, 33, 44), "#4a1f45") c:px(28, 43, "#4a1f45") c:px(34, 43, "#4a1f45")
-- tear
D.fill(c:rect(39, 40, 40, 44), "#5fc4c8") D.fill(c:rect(38, 45, 41, 47), "#5fc4c8") D.fill(c:rect(39, 48, 40, 48), "#5fc4c8")
D.fill(c:rect(39, 41, 39, 43), "#b6f0e0") c:px(39, 46, "#b6f0e0")
D.fin()
