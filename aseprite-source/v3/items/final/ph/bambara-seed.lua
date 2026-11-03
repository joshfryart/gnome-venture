local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dA14.lua")
local HP, B, H, X, c0 = D.HP, D.B, D.H, D.X
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
-- bambara-seed: two round cream seeds with dark hilum rings on a trifoliate groundnut leaf scrap; sprout has three rounded leaflets. quirk: a tiny nibble taken from the scrap edge.
local c = D.new("bambara-seed")
D.scrap(6, 55, 58, 50, 6.5, D.LEAF2, {norib=false})
local NUT = { "#7a5a46", "#a8826a", "#d2b08c", "#ecd2ae", "#f8e6c8", "#fffaec" }
for _, s in ipairs{{20, 51, 4.4}, {33, 52, 4.8}} do
  local m = D.seed(s[1], s[2], s[3], s[3] - .4, 0, NUT)
  c:fillMask(D.ell(s[1] + 2, s[2] + 1, 1.2, 1.2, 0), "#5a3a34")
end
D.stem(33, 48, 33, 32, "#86b86c") D.stem(34, 48, 34, 32, "#6a9a58")
D.lf(27, 28, 4.6, 3, -0.5, D.LEAF2) D.lf(41, 28, 4.6, 3, 0.5, D.LEAF2) D.lf(34, 22, 3.2, 5, 0, D.LEAF2)
D.fin()
