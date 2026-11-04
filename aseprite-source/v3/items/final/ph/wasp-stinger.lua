-- wasp-stinger (lean W2_37)
-- A severed striped abdomen tip (amber and black bands, fuzzy rim) with a long curved glossy-black needle that hooks back;
-- one tiny barb on the inner curve. quirk: a bead of green venom swells at the tip.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "wasp-stinger" }
local sin, pi, sqrt, floor = math.sin, math.pi, math.sqrt, math.floor
local NE = { "#120e1c", "#241b33", "#3a2d4e", "#574a70", "#8478a0", "#c9c0e0" }
local AM = { "#6b3510", "#9a5612", "#c98616", "#ecb524", "#f8d84c", "#fff2a4" }
local BK = { "#100c18", "#1e1729", "#30263f", "#463a58", "#625479", "#8a7ca4" }
local tok = { r = { name = "p" } }
c:groundShadow(34, 58, 11, 2)
-- needle
local P = { {26, 26}, {43, 24}, {53, 38}, {43, 55} }
local m, n, T, S = G.tube(P, function(t) return 3.0 * (1 - t) ^ 0.9 + 0.35 end)
local v = X.light(n, { amb = 0.08, wrap = 0.2 })
G.tone(c, m, v, NE, { 0.25, 0.45, 0.62, 0.78, 0.92 }, nil, tok)
m:each(function(x, y) local k = K(x, y)
  if S[k] < -0.3 and S[k] > -0.65 and T[k] > 0.1 and T[k] < 0.8 then c:put(x, y, NE[5], tok) end
  if S[k] < -0.4 and S[k] > -0.6 and T[k] > 0.25 and T[k] < 0.5 then c:put(x, y, NE[6], tok) end end)
-- barb on the inner curve
for _, p in ipairs{ {47, 46}, {46, 47}, {45, 49}, {47, 47}, {46, 48} } do c:px(p[1], p[2], NE[3]) end
c:px(46, 45, NE[5])
-- venom bead
c:px(43, 56, "#6bd66a") c:px(43, 57, "#2f9a54") c:px(42, 57, "#a8f090") c:px(44, 57, "#2f9a54") c:px(43, 58, "#1f6a44")
-- abdomen
local ux, uy = 0.72, 0.69
local ab = G.rell(18, 19, ux, uy, 12.5, 8.6)
local an = X.pillow(ab, 8)
local av = X.light(an, { amb = 0.08, wrap = 0.25 })
local amber, black = HP.mask(), HP.mask()
ab:each(function(x, y)
  local a = (x - 18) * ux + (y - 19) * uy
  local band = floor((a + 12.5) / 4.2)
  if band % 2 == 0 or band > 5 then black:set(x, y) else amber:set(x, y) end
end)
G.tone(c, amber, av, AM, nil, nil, tok)
G.tone(c, black, av, BK, nil, nil, tok)
-- band seams (dark creases) + fuzz specks
amber:each(function(x, y) if X.hash(x, y, 7) > 0.93 then c:px(x, y, AM[5]) end end)
-- specular
c:px(11, 13, "#fffbe8") c:px(12, 12, "#fffbe8") c:px(10, 14, AM[5])
-- stinger socket ring
c:px(27, 26, BK[3]) c:px(26, 27, BK[3]) c:px(28, 27, BK[2])
G.fin(c, "wasp-stinger")
