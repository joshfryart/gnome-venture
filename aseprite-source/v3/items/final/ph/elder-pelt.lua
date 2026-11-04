-- elder-pelt (first draft, Sonnet)
-- quirk: a bone bead and a single feather are knotted into the hind corner
local NAME = "elder-pelt"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dB25.lua")
local H, HP = D.H, D.HP
local X, K = D.X, D.K
local floor, sin, cos, max, min, abs, pi = math.floor, math.sin, math.cos, math.max, math.min, math.abs, math.pi
local c = D.new(NAME)
local FR = D.rp("#4a4658", "#9a98a8", "#e8e6ee")
-- body, four legs, tail
local body = D.el(30, 32, 15, 12, -0.1, FR, 7)
body:add(D.el(17, 21, 6, 7, 0.6, FR, 3)) body:add(D.el(43, 21, 6, 7, -0.6, FR, 3))
D.el(17, 44, 6, 7, -0.6, FR, 3) D.el(43, 44, 6, 7, 0.6, FR, 3)
D.el(30, 20, 5, 4, 0, FR, 3)
D.el(30, 50, 4, 6, 0, FR, 2.5)
D.el(30, 32, 15, 12, -0.1, FR, 7)
-- fur tufts: little lines on rim
for _, p in ipairs{ { 17, 28 }, { 44, 36 }, { 22, 42 }, { 38, 24 }, { 30, 30 }, { 26, 36 } } do
  c:px(p[1], p[2], FR[6]) c:px(p[1] + 1, p[2] + 1, FR[6]) c:px(p[1] + 2, p[2] + 1, FR[2]) end
-- silver old-age patch
c:fillMask(c:ellipse(30, 30, 5, 3), "#e8e6ee") c:fillMask(c:ellipse(30, 32, 3, 1.5), "#cfd0dc")
-- bead + feather
D.stem({ { 47, 50 }, { 51, 54 } }, "#c8a878", "#7a5a38", 1)
D.bead(52, 56, 2.5, D.rp("#a89a7a", "#ece0c0", "#fffbe8"), "#ffffff" == "" and "" or "#fffbe8")
D.leaf(54, 46, 5, 1.8, 1.0, D.rp("#6a3a14", "#c8802a", "#f8d890"), true)
D.fin()
