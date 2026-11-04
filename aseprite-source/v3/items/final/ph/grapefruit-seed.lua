-- grapefruit-seed (dC10 first draft): three cream teardrop pips on a leaf scrap, one has sprouted two glossy oval leaves.
-- quirk: a ruby juice bead still clings to the nearest pip.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC10.lua")
local B, H, HP, X, K = D.B, D.H, D.HP, D.X, D.K
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new('grapefruit-seed')
D.scrap(c, 31, 46, 22, 10, -0.15, 'moss')
local SD = { '#6a4a34', '#a07a52', '#cfa874', '#e8cc98', '#f6e4b8', '#fff4d6' }
-- sprout
B.ln(c, 40, 41, 40, 30, '#86b86c') B.ln(c, 41, 41, 41, 31, '#b8dc92')
D.leafE(c, 33, 26, 8, 4.6, -0.4, 'moss', 2)
D.leafE(c, 48, 25, 8, 4.6, 0.35, 'moss', 2)
D.leafE(c, 41, 18, 4, 5.5, 1.57, 'moss', 1)
for _, s in ipairs{ {16,47,0.5}, {26,50,-0.3}, {38,46,0} } do
  local m = B.seed(c, s[1], s[2], 4.4, 2.6, s[3], SD, '#1f553f', '#fff4d6')
  c:px(floor(s[1]+3.4), floor(s[2]+.5), SD[2])
end
-- juice bead
c:px(21, 49, '#e0566a') c:px(21, 50, '#c0394f') c:px(22, 49, '#ffb0a8')
D.fin()
