local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA14.lua")
local HP, B, H, X, c0 = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- bamboo-shoot-seed: three slender rice-like husked grains on a lanceolate bamboo leaf; sprout is a pointed culm with narrow leaves. quirk: the grains are tipped with a thin whisker.
local c = D.new("bamboo-shoot-seed")
D.scrap(5, 52, 59, 46, 5, D.LEAF, {veins = {6, 11, 16, 21, 26, 31, 36, 41, 46}})
for i, s in ipairs{{18, 50, -0.2}, {29, 52, 0.15}, {41, 49, 0.4}} do
  local m = D.seed(s[1], s[2], 5.6, 2.4, s[3], D.HUSK)
  D.ln(s[1] + 5, s[2] + floor(s[3] * 5), s[1] + 8, s[2] + floor(s[3] * 8), "#b8985a")
end
D.ln(32, 48, 32, 18, "#86b86c") D.ln(33, 48, 33, 18, "#4a8a50")
for _, y in ipairs{22, 29, 36} do D.ln(33, y + 2, 41, y - 3, "#2e7646") D.ln(32, y + 2, 24, y - 3, "#45954c") D.lf(41, y - 3, 3, 1.1, -0.5, D.LEAF2) D.lf(24, y - 3, 3, 1.1, 0.5, D.LEAF2) end
D.lf(32, 15, 1.2, 4, 0, D.LEAF2)
D.fin()
