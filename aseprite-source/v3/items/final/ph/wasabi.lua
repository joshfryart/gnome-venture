-- wasabi (lean D3o_9)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w=64, h=64, scale=1, name="wasabi" }
local RH   = { "#233a24", "#35552f", "#4d7a3a", "#6e9e4c", "#95c264", "#c0e08a" }
local CUT  = { "#6a9a5a", "#93bf72", "#b8dc92", "#d6efae", "#ecf8c8", "#f8ffe0" }
local LEAF = { "#183e3a", "#22604a", "#2f8451", "#4aa55a", "#78c868", "#a8e282" }
c:groundShadow(30, 54, 18, 3)
-- heart leaf on long stalk
local sm, sn = G.tube({ {30,38},{28,28},{35,22},{36,13} }, function(t) return 1.5 - 0.4*t end)
G.tone(c, sm, X.light(sn, {amb=0.12, wrap=0.3}), { "#2c4c2e", "#406a3a", "#5e9250", "#76ac62", "#8cc070", "#c0e898" })
local l1 = G.rell(31, 9, 1, 0.2, 5.8, 5.2)
local l2 = G.rell(41, 9, 1, -0.2, 5.8, 5.2)
local lm = l1:copy():add(l2):add(c:poly{ {27,10},{45,10},{36,21} })
lm:add(c:rect(33, 5, 38, 6))
local ln = X.pillow(lm, 6)
G.tone(c, lm, X.light(ln, {amb=0.14, wrap=0.3}), LEAF)
G.line(c, { {36,6},{36,18} }, LEAF[6])
G.line(c, { {36,13},{31,9} }, LEAF[2]) G.line(c, { {36,13},{41,9} }, LEAF[5])
-- rhizome: knobby, rising to the right, cut at right end
local rm, rn, T, S = G.tube({ {10,50},{22,46},{34,45},{48,38} }, function(t)
  return 5.2 + 1.5*sin(t*14)^2*0.8 + 0.7*sin(t*5) end)
local bias = {}
rm:each(function(x, y) local k = K(x, y)
  -- leaf scars: curved dashes
  local ph = (T[k] * 9) % 1
  if ph > 0.9 and abs(S[k]) < 0.85 then bias[k] = -1 end
  if X.hash(x, y, 6) > 0.9 then if not bias[k] then bias[k] = 1 end end
end)
G.tone(c, rm, X.light(rn, {amb=0.08, wrap=0.2}), RH, nil, bias)
-- stalk stubs on top
for _, sx in ipairs{ 16, 24, 41 } do
  local tm, tn = G.tube({ {sx,44},{sx-1,41},{sx,38},{sx,36} }, function(t) return 1.5 - 0.5*t end)
  tm:cut(rm)
  G.tone(c, tm, X.light(tn, {amb=0.14, wrap=0.3}), RH, {0.3,0.5,0.7,0.85,0.95})
  c:px(sx, 36, CUT[4])
end
-- cut face at the right end (quirk: fresh slice)
local cf = G.rell(47, 40, 0.5, -0.85, 6.5, 4.5)
G.tone(c, cf, X.light(X.pillow(cf, 4), {amb=0.3, wrap=0.4}), CUT)
cf:each(function(x, y) if X.hash(x, y, 9) > 0.86 then c:px(x, y, CUT[1]) end end)
c:px(45, 38, CUT[6]) c:px(46, 38, CUT[6])
G.fin(c, "wasabi")
