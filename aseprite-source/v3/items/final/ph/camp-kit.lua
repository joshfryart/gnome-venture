-- camp-kit (dB13 first draft)
local NAME = "camp-kit"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dB13.lua")
local B, HP, X, H = D.B, D.HP, D.X, D.H
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local WOOD = {"#3a2030","#51302b","#864c33","#b97a4a","#d49c62","#e8c08a"}
local STEEL = {"#2f3350","#444663","#74758c","#9a99ab","#c4c3d0","#e8e6ee"}
local GRN = {"#163a35","#1f553f","#2b7046","#3f8f4c","#62ad55","#93cb68"}
local SEEDBR = {"#3a1a1e","#62262a","#8c3c32","#b45c3c","#d68650","#f0b878"}
local CREAM = "#fff4d6"
local c = D.new(NAME)
local RD = {"#4a1a2a","#7d2038","#b52e3f","#d9453b","#ee6a50","#ff9a78"}
local TIN = {"#2f3350","#52566e","#7e8298","#a8abbe","#cfd1de","#f0f0f6"}
c:groundShadow(32,57,26,3)
-- bedroll body (horizontal cylinder, lit by vertical shade)
local body = HP.mask() body:add(c:rrect(8,24,54,52,5))
local n = {} body:each(function(x,y) local t = max(-.97,min(.97,((y-24)/28)*2-1)) n[X.K(x,y)] = {0, t, math.sqrt(1-t*t)} end)
X.tone(c, body, X.light(n,{amb=.1,wrap=.3}), RD, {cuts={.2,.4,.58,.74,.88}})
-- spiral end cap on the right
local cap = B.ell(52, 38, 6, 14, 0) B.lit(c, cap, {"#d9b074","#e8c890","#f2d8a8","#f8e6c0","#fff0d4","#fff8e4"}, 6)
for r = 2, 10, 3 do local m = B.ell(52, 38, r*0.5+1, r*1.3, 0) m:edge():each(function(x,y) if cap:has(x,y) then c:px(x,y,"#b8904e") end end) end
-- straps
for _, x in ipairs{20, 36} do for y = 24, 52 do c:px(x,y,"#8f5a2a") c:px(x+1,y,"#b8803e") c:px(x+2,y,"#d8a458") end c:fillMask(c:rect(x,36,x+2,40), "#f5b82e") c:px(x+1,38,"#2b1c26") end
-- tin cup on top (quirk)
local cup = HP.mask() cup:add(c:rrect(24,8,40,24,2)) H.vcyl(c, cup, TIN, 24, 40)
c:fillMask(c:rect(24,8,40,10), TIN[6]) c:fillMask(c:rect(25,10,39,10), TIN[1])
local hd = H.sweep({{40,12},{50,12},{50,22},{40,21}}, function() return 1.2 end, 30) H.lit(c, hd, TIN, {R=1.2})
D.fin()
