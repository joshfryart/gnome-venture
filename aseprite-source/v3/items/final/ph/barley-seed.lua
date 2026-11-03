local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA14.lua")
local HP, B, H, X, c0 = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- barley-seed: four spindle kernels with a centre groove and a short awn, on a broad grass blade scrap; sprout is two grass blades. quirk: one kernel stands on end.
local c = D.new("barley-seed")
D.scrap(4, 53, 60, 49, 5.5, D.LEAF2, {veins = {8, 14, 20, 26, 32, 38, 44, 50}})
for i, s in ipairs{{16, 51, -0.15}, {27, 52, 0.1}, {38, 52, -0.1}} do
  local m = D.seed(s[1], s[2], 5.4, 2.7, s[3], D.GRAIN)
  D.ln(s[1] - 4, s[2], s[1] + 4, s[2] + floor(s[3] * 8), D.GRAIN[2])
  D.ln(s[1] + 5, s[2], s[1] + 8, s[2] - 3, D.GRAIN[4])
end
D.lit(D.ell(48, 47, 2.6, 5.4, 0.15), D.GRAIN, 1.8) D.ln(49, 42, 50, 36, D.GRAIN[4])
D.lf(30, 33, 1.5, 9, -0.2, D.LEAF2) D.lf(34, 34, 1.5, 8, 0.4, D.LEAF2)
D.ln(32, 48, 31, 40, "#86b86c") D.ln(33, 48, 33, 40, "#6a9a58")
D.fin()
