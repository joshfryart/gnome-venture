local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA14.lua")
local HP, B, H, X, c0 = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- beehive-lantern: a skep-shaped lantern of amber glass in a dark iron frame hanging from a hook, glowing, with a bee silhouette inside. quirk: the bee inside is asleep (Zz) next to the flame.
local c = D.new("beehive-lantern")
D.ln(32, 2, 32, 9, "#443f4c") D.ln(33, 2, 33, 9, "#625c6c") D.lit(D.ell(32, 11, 3, 3, 0), D.STEEL, 1.6) c:fillMask(D.ell(32, 11, 1, 1, 0), "#2b1c26")
local body = c:poly{ {32, 14}, {42, 18}, {46, 30}, {50, 44}, {48, 50}, {16, 50}, {14, 44}, {18, 30}, {22, 18} }
D.lit(body, D.ORG, 6)
for _, y in ipairs{22, 31, 40} do
  local hw = y == 22 and 8 or y == 31 and 13 or 17
  D.ln(32 - hw, y, 32 + hw, y, "#8f3a1f") D.ln(32 - hw, y + 1, 32 + hw, y + 1, "#ff9a3c")
end
c:fillMask(D.ell(32, 40, 6, 6, 0), "#fff2a8") c:fillMask(D.ell(32, 40, 3.5, 4, 0), "#ffe46e")
c:fillMask(c:rect(28, 41, 36, 42), "#f8d048") D.bee(32, 36)
D.ln(32, 14, 32, 49, "#3a2a30") D.ln(24, 18, 20, 49, "#3a2a30") D.ln(40, 18, 44, 49, "#3a2a30")
D.lit(c:rect(13, 50, 51, 55), D.GREY, 2.5) D.ln(14, 51, 50, 51, "#cac6d2")
D.px(47, 14, "#fff4d6") D.px(48, 14, "#fff4d6") D.px(49, 13, "#fff4d6") D.px(48, 11, "#fff4d6") D.px(49, 11, "#fff4d6")
D.fin()
