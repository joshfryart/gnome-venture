-- guaria-morada-seed (dC10 first draft): a pinch of dust-fine orchid seeds with three larger spindle seeds on a leaf scrap;
-- the sprout is a tiny green pseudobulb with two strap-like leathery leaves.
-- quirk: a single violet orchid lip petal has drifted onto the scrap.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC10.lua")
local B, H, HP, X, K = D.B, D.H, D.HP, D.X, D.K
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new('guaria-morada-seed')
D.scrap(c, 31, 48, 22, 8, 0.1, 'moss')
local SD = { '#5a3a2a', '#8a5a34', '#b07a42', '#d09c58', '#e8c47a', '#f8e4a8' }
-- pseudobulb
local pb = B.ell(39, 41, 2.6, 5, 0) B.lit(c, pb, 'moss', 1.6)
for y = 38, 44 do c:px(39, y, '#c4e07a') end
-- strap leaves
D.blade(c, 38, 38, 22, 14, 3.2, 'moss', { veins = { 4, 8, 12, 16 }, slant = 1 })
D.blade(c, 41, 38, 56, 12, 3.2, 'moss', { veins = { 4, 8, 12, 16 }, slant = 1 })
-- dust
for i = 1, 40 do
  local x, y = floor(10 + X.hash(i, 1, 1) * 22), floor(46 + X.hash(i, 2, 2) * 8)
  c:px(x, y, X.hash(i, 3, 3) > 0.5 and SD[4] or SD[5])
end
for _, s in ipairs{ {16,52,0.2}, {24,54,-0.3}, {30,51,0.1} } do B.seed(c, s[1], s[2], 3.8, 1.5, s[3], SD, '#1f553f', '#fff4d6') end
-- petal
local pt = B.ell(49, 51, 4.5, 3, 0.3) B.lit(c, pt, 'dusk', 2)
c:px(47, 51, '#f5809f') c:px(48, 52, '#f5809f') c:px(46, 50, '#ffc4d8')
D.fin()
