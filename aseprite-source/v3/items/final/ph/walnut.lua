-- walnut (lean D3o_9)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w=64, h=64, scale=1, name="walnut" }
local SH = { "#2b1a1a", "#472a22", "#6a4430", "#8e6244", "#b58a62", "#d9b488" }
local KR = { "#6a4430", "#9a6a42", "#c79660", "#e6bf86", "#f6dcaa", "#fff0cc" }
c:groundShadow(30, 55, 17, 3)
-- whole nut: slightly pointed oval with a pointed tip at top
local nut = HP.mask()
for y = 12, 52 do
  local t = (y - 12) / 40
  local h = 15 * sin(min(1, t * 1.15 + 0.12) * pi / 2) ^ 0.55 * (t > 0.85 and (1 - (t - 0.85) * 2.2) or 1)
  for x = floor(27 - h + 0.5), floor(27 + h - 0.5) do nut:set(x, y) end
end
nut:set(27, 10) nut:set(26, 11) nut:set(27, 11) nut:set(28, 11)
local n = X.pillow(nut, 11)
local v = X.light(n, {amb=0.06, wrap=0.2})
local bias = {}
nut:each(function(x, y) local k = K(x, y)
  local r = (x - 27) % 5 + 0.6 * sin(y * 0.9 + x * 0.4)
  if abs(r - 2.2) < 0.55 and X.hash(x, y, 8) > 0.25 then bias[k] = -1 end
  if abs(r - 4.6) < 0.4 and X.hash(x, y, 2) > 0.7 then bias[k] = 1 end
end)
G.tone(c, nut, v, SH, nil, bias)
-- seam down the middle
for y = 11, 51 do local x = 27 + floor(sin(y * 0.35) * 1.2 + 0.5)
  c:px(x, y, SH[1]) c:px(x + 1, y, SH[2]) end
-- spec
c:px(19, 24, SH[6]) c:px(20, 23, SH[6]) c:px(19, 25, SH[5]) c:px(20, 24, SH[5])
-- kernel half in front (quirk: cracked, kernel peeking)
local kr = G.rell(46, 46, 1, 0, 9, 7.5)
local kn = X.pillow(kr, 6.5)
G.tone(c, kr, X.light(kn, {amb=0.1, wrap=0.3}), KR)
for _, p in ipairs{ {{39,46},{43,43},{47,44},{50,42}}, {{40,49},{44,48},{47,50},{51,48}}, {{46,40},{46,44},{45,47}} } do
  G.line(c, p, KR[1]) end
c:px(41, 44, KR[6]) c:px(42, 43, KR[6])
local rim = G.rell(46, 47, 1, 0, 9.5, 8):cut(kr)
rim:each(function(x, y) if y > 46 or x > 50 then c:px(x, y, SH[3]) end end)
G.fin(c, "walnut")
