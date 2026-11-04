-- greenhouse-lantern (dC10 first draft): gabled lean glasshouse glowing warm inside, a hanging iron lantern at the door.
-- quirk: a moth circles the lantern.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dC10.lua")
local B, H, HP, X, K = D.B, D.H, D.HP, D.X, D.K
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = D.new('greenhouse-lantern')
c:groundShadow(32, 56, 22, 2.5)
D.house(c, { x0 = 10, x1 = 47, wt = 31, fl = 50, pk = 14, roof = 'gable', mull = 9, tint = { '#fff0b0', '#ffe38a', '#f5b82e' }, fr = { '#aaa9b8', '#74758c', '#444663' } })
-- post and arm
D.rect(c, 52, 22, 54, 52, 'stone', 1)
B.ln(c, 52, 23, 46, 23, '#444663') B.ln(c, 52, 24, 46, 24, '#74758c')
-- lantern
B.ln(c, 46, 24, 46, 27, '#444663')
local lm = D.rect(c, 42, 28, 50, 38, 'gold', 2)
c:fillMask(c:rect(44, 30, 48, 36), '#fff4d6')
c:px(46, 33, '#ffe38a')
D.rect(c, 41, 26, 51, 28, 'stone', 1) D.rect(c, 42, 38, 50, 40, 'stone', 1)
c:px(46, 25, '#444663')
-- moth
c:px(39, 29, '#c9b2f0') c:px(38, 28, '#aaa9b8') c:px(40, 28, '#aaa9b8') c:px(39, 30, '#8a6fd0') c:px(37, 29, '#e2e0e6')
D.fin()
