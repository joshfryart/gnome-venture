-- greenhouse-2 (dC10 first draft): tier 2, wider hip-roofed house with a red ridge flag and a roof vent propped open.
-- quirk: the little red flag flies the wrong way, into the wind.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC10.lua")
local B, H, HP, X, K = D.B, D.H, D.HP, D.X, D.K
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new('greenhouse-2')
c:groundShadow(32, 56, 25, 2.5)
D.house(c, { x0 = 9, x1 = 54, wt = 28, fl = 50, pk = 15, roof = 'hip', mull = 9 })
-- flag pole and flag
B.ln(c, 32, 14, 32, 6, '#aaa9b8') c:px(33, 14, '#74758c')
for _, r in ipairs{ {26,6,32},{27,7,32},{28,8,32} } do end
local fl = c:poly{ {31,6}, {24,8}, {31,10} } B.lit(c, fl, 'ember', 1.2)
-- open vent
local v = c:poly{ {40,15}, {50,19}, {50,23}, {40,19} } B.lit(c, v, 'sky', 1.5)
B.ln(c, 40, 15, 50, 19, '#fff4d6') B.ln(c, 40, 19, 50, 23, '#aaa9b8')
-- door
D.rect(c, 29, 37, 35, 49, 'wood', 1) c:px(34, 44, '#f5b82e')
D.fin()
