-- greenhouse-mossy (dC10 first draft): an old lopsided glasshouse, green-tinged panes, moss cushions on frame and roof, one cracked pane.
-- quirk: a red toadstool grows on the plinth.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC10.lua")
local B, H, HP, X, K = D.B, D.H, D.HP, D.X, D.K
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new('greenhouse-mossy')
c:groundShadow(32, 56, 22, 2.5)
D.house(c, { x0 = 12, x1 = 51, wt = 30, fl = 50, pk = 12, roof = 'hip', mull = 8, tint = { '#d8f0d0', '#b0d8a8', '#80b880' }, fr = { '#c4e07a', '#7cc35a', '#3f9150' }, plinth = 'wood' })
-- moss blobs
local G = H.ramp('moss')
for _, p in ipairs{ {16,12,4,2},{36,13,5,2},{12,31,5,2.5},{46,30,4,2},{26,50,6,2} } do
  local m = B.ell(p[1] + 8, p[2] + 6, p[3], p[4], 0) B.lit(c, m, 'moss', 1.5)
end
for _, p in ipairs{ {14,38},{14,40},{49,40},{49,43} } do B.ln(c, p[1], p[2], p[1], p[2] + 4, '#3f9150') end
-- crack
B.ln(c, 26, 33, 29, 37, '#2a4a7a') B.ln(c, 29, 37, 27, 41, '#2a4a7a') B.ln(c, 29, 37, 32, 40, '#2a4a7a')
-- toadstool
c:fillMask(c:rect(52, 49, 53, 54), '#fff4d6')
local cap = c:ellipse(52.5, 48, 4, 2.5):clip(c:rect(40, 40, 63, 49)) B.lit(c, cap, 'ember', 1.5)
c:px(51, 47, '#fff4d6') c:px(54, 48, '#fff4d6')
D.fin()
