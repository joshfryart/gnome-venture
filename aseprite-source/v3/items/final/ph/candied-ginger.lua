-- candied-ginger (dB13 first draft)
local NAME = "candied-ginger"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dB13.lua")
local B, HP, X, H = D.B, D.HP, D.X, D.H
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local WOOD = {"#3a2030","#51302b","#864c33","#b97a4a","#d49c62","#e8c08a"}
local STEEL = {"#2f3350","#444663","#74758c","#9a99ab","#c4c3d0","#e8e6ee"}
local GRN = {"#163a35","#1f553f","#2b7046","#3f8f4c","#62ad55","#93cb68"}
local SEEDBR = {"#3a1a1e","#62262a","#8c3c32","#b45c3c","#d68650","#f0b878"}
local CREAM = "#fff4d6"
local c = D.new(NAME)
local GI = {"#8a5a1a","#b98428","#dcaa3a","#f0c458","#ffdc80","#fff0b8"}
c:groundShadow(32,58,24,3)
local function cube(cx, cy, w, h, ang)
  local m = B.ell(cx, cy, w, h, ang)
  m:add(c:rrect(floor(cx - w + 1), floor(cy - h + 1), floor(cx + w - 1), floor(cy + h - 1), 2))
  H.lit(c, m, GI, {R=4})
  -- fibre lines
  B.ln(c, cx - w + 3, cy - 1, cx + w - 3, cy + 1, GI[2], m)
  B.ln(c, cx - w + 4, cy + 3, cx + w - 4, cy + 4, GI[2], m)
  m:each(function(x, y) if (x * 7 + y * 11) % 9 == 0 then c:px(x, y, "#fff4d6") end end)
  return m
end
cube(20, 46, 12, 8, 0.1) cube(42, 48, 12, 8, -0.1) cube(30, 33, 12, 8, 0.15) cube(46, 30, 8, 7, -0.3)
-- sugar crystals on the ground
for _, p in ipairs{{6,56},{9,58},{54,57},{58,55},{34,57}} do c:px(p[1],p[2],"#fff4d6") end
-- ginger root knob on top (quirk)
local knob = D.ball(c, 24, 20, 4, 3, {"#6e4a1a","#9a6a2a","#c08a3e","#dca85a","#ecc888","#f8e4b8"}, 0.3, 2)
c:px(22,18,"#fff4d6")
c:sparkle(56, 22)
D.fin()
