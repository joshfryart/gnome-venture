local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA16.lua")
local floor, sin, cos = math.floor, math.sin, math.cos
local c = D.new("blossom-cherry")
-- blossom-cherry: slim blossoming cherry twig in an S curve, trunk with bark rings, clusters of five-petal pink blossoms with gold stamens. quirk: one petal drifts away mid-fall.
D.ln(30, 58, 30, 40, "#51302b") D.ln(31, 58, 31, 40, "#864c33") D.ln(32, 58, 32, 40, "#a35f3c")
D.ln(30, 42, 22, 32, "#51302b") D.ln(31, 42, 23, 32, "#864c33") D.ln(31, 42, 40, 30, "#864c33") D.ln(32, 42, 41, 30, "#a35f3c")
D.ln(22, 32, 18, 22, "#864c33") D.ln(40, 30, 44, 20, "#864c33") D.ln(23, 32, 30, 20, "#864c33")
D.ln(30, 56, 32, 56, "#3a2030") D.ln(30, 50, 31, 50, "#3a2030")
local function fl(x, y, r)
  for k = 0, 4 do local a = k * 1.2566 - 1.57; D.E(x + cos(a) * r, y + sin(a) * r, r * 0.72, r * 0.72, 0, D.PINK, 1.5) end
  D.c:fillMask(D.c:ellipse(x, y, 1, 1), "#ffe38a") D.px(x, y, "#d98322")
end
fl(18, 20, 4) fl(44, 18, 5) fl(30, 17, 4) fl(24, 33, 3) fl(40, 31, 3) fl(14, 28, 3)
D.E(51, 40, 1.8, 1, 0.8, D.PINK, 1) D.px(50, 39, "#ffc9d8")
D.fin()
