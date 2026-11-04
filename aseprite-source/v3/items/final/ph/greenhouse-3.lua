-- greenhouse-3 (dC10 first draft): tier 3, a grand domed conservatory on a brick plinth with a lantern cupola and flag.
-- quirk: a tiny bird sits in the cupola window.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC10.lua")
local B, H, HP, X, K = D.B, D.H, D.HP, D.X, D.K
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new('greenhouse-3')
c:groundShadow(32, 58, 26, 2.5)
D.house(c, { x0 = 8, x1 = 55, wt = 33, fl = 52, pk = 14, roof = 'dome', mull = 8, plinth = 'ember', fr = { '#ffe38a', '#f5b82e', '#d98322' } })
-- cupola
D.rect(c, 27, 7, 36, 15, 'stone', 1)
c:fillMask(c:rect(29, 9, 34, 13), '#cdeaf5') c:px(31, 9, D.CREAM)
local cap = c:poly{ {26,8}, {31,3}, {37,8} } B.lit(c, cap, 'ember', 1.5)
c:px(31, 1, '#ffe38a') c:px(31, 2, '#f5b82e')
-- bird
c:px(31, 12, '#e8493b') c:px(32, 12, '#e8493b') c:px(32, 11, '#e8493b') c:px(33, 12, '#f5b82e') c:px(31, 11, '#2b1c26')
D.fin()
