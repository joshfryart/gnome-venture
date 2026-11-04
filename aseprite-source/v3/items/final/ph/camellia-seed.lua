-- camellia-seed (dB13 first draft)
local NAME = "camellia-seed"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dB13.lua")
local B, HP, X, H = D.B, D.HP, D.X, D.H
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local WOOD = {"#3a2030","#51302b","#864c33","#b97a4a","#d49c62","#e8c08a"}
local STEEL = {"#2f3350","#444663","#74758c","#9a99ab","#c4c3d0","#e8e6ee"}
local GRN = {"#163a35","#1f553f","#2b7046","#3f8f4c","#62ad55","#93cb68"}
local SEEDBR = {"#3a1a1e","#62262a","#8c3c32","#b45c3c","#d68650","#f0b878"}
local CREAM = "#fff4d6"
local c = D.new(NAME)
local CS = {"#2a140e","#4a2210","#6e3414","#94501e","#b87030","#e0a058"}
local CL = {"#12342c","#1a4a3a","#24644a","#348458","#4ca470","#8ad098"}
D.scene(c, {leaf=CL, a={5,53}, b={58,47}, w=8, veins={8,15,22,29,36,43},
  seeds={{18,49,5,4.2,0.2,CS},{32,53,4.4,3.6,-0.3,CS},{44,46,5,4.2,0.6,CS}},
  stem={44,41,40,22,hex="#6a8a4a",leaves={{33,18,8,4,-0.6},{47,18,8,4,0.6}},ramp=CL}})
-- pale hilum scars + serrations on sprout leaves (glossy)
for _, s in ipairs{{18,49},{32,53},{44,46}} do D.ball(c, s[1]+2, s[2]+1, 1.6, 1.2, {"#8a6a4a","#b8956a","#d9bb8a","#ecd9b0","#f6ecd6","#fff4d6"}, 0, 1) end
c:px(30,16,CL[6]) c:px(36,17,CL[6]) c:px(44,16,CL[6]) c:px(50,17,CL[6])
D.fin()
