-- greenhouse-painted (dC10 first draft): hip-roofed glasshouse painted bubblegum pink and teal, striped awning, flower box.
-- quirk: the gutter was painted with a cheerful smiling face by the gardener.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC10.lua")
local B, H, HP, X, K = D.B, D.H, D.HP, D.X, D.K
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new('greenhouse-painted')
c:groundShadow(32, 56, 22, 2.5)
D.house(c, { x0 = 11, x1 = 52, wt = 34, fl = 51, pk = 20, roof = 'hip', mull = 8, fr = { '#ffc4d8', '#f5809f', '#c94f84' }, plinth = 'sea' })
-- awning
local aw = c:poly{ {9,22}, {54,22}, {58,33}, {5,33} }
B.lit(c, aw, 'petal', 1.5)
for x = 9, 56, 8 do for y = 23, 32 do c:px(x + (y - 22) * -0.5 // 1 * -1, y, '#fff4d6') c:px(x + 1 + ((y - 22) * -0.5 // 1 * -1), y, '#fff4d6') end end
for x = 5, 58, 4 do c:px(x, 33, '#c94f84') end
-- flower box with blooms
D.rect(c, 16, 46, 47, 51, 'sea', 1)
for _, p in ipairs{ {19,45},{25,44},{31,45},{37,44},{43,45} } do
  c:px(p[1], p[2], '#f5b82e') for _, d in ipairs{ {-1,0},{1,0},{0,-1} } do c:px(p[1] + d[1], p[2] + d[2], '#fff4d6') end end
-- gutter face
c:px(29, 37, '#2b1c26') c:px(34, 37, '#2b1c26') c:px(30, 40, '#2b1c26') c:px(31, 41, '#2b1c26') c:px(32, 41, '#2b1c26') c:px(33, 40, '#2b1c26')
D.fin()
