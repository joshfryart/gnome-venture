-- candied-citrus-peel (dB13 first draft)
local NAME = "candied-citrus-peel"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dB13.lua")
local B, HP, X, H = D.B, D.HP, D.X, D.H
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local WOOD = {"#3a2030","#51302b","#864c33","#b97a4a","#d49c62","#e8c08a"}
local STEEL = {"#2f3350","#444663","#74758c","#9a99ab","#c4c3d0","#e8e6ee"}
local GRN = {"#163a35","#1f553f","#2b7046","#3f8f4c","#62ad55","#93cb68"}
local SEEDBR = {"#3a1a1e","#62262a","#8c3c32","#b45c3c","#d68650","#f0b878"}
local CREAM = "#fff4d6"
local c = D.new(NAME)
local OR = {"#8f3a1a","#c25a1a","#e8801e","#ffa030","#ffbe54","#ffdc88"}
local YL = {"#8f6a1a","#c29a1e","#e8c030","#ffd848","#ffe878","#fff4b8"}
local CHOC = {"#2a140e","#4a2210","#5e3016","#7a4420","#946034","#b88050"}
-- three curled ribbons
local function rib(pts, ramp, w)
  local m = H.sweep(pts, function(t) return w * (0.7 + 0.3 * sin(pi * t)) end, 70)
  H.lit(c, m, ramp, {R=2})
  m:each(function(x, y) if (x * 3 + y * 5) % 7 == 0 then c:px(x, y, "#fff4d6") end end)
  return m
end
rib({{8,48},{12,20},{34,8},{30,30}}, OR, 3.2)
rib({{24,56},{48,52},{56,26},{40,24}}, YL, 3.2)
local mc = rib({{12,52},{22,34},{44,40},{36,54}}, OR, 3.2)
-- chocolate dip on half (quirk)
mc:each(function(x, y) if x < 22 and y > 42 then c:px(x, y, (x + y) % 5 == 0 and CHOC[5] or CHOC[3]) end end)
c:sparkle(52, 14) c:px(8,14,"#fff4d6") c:px(44,10,"#fff4d6")
D.fin()
