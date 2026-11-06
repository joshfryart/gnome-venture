-- walking-stick (lean D3o_9)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w=64, h=64, scale=1, name="walking-stick" }
local WOOD = { "#2e1c1a", "#4a2e22", "#6b4529", "#8f6236", "#b88848", "#dbb06a" }
local LEA  = { "#2a1a1c", "#4a2a28", "#6e3e30", "#965a3c", "#bd7c4c", "#dc9e6a" }
local STEEL= { "#2d3446", "#4d5a72", "#7686a0", "#a3b2c6", "#cfdbe8", "#f2f6fa" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
c:groundShadow(24, 57, 10, 2)
local function wood(m, n) G.tone(c, m, X.light(n, {amb=0.1, wrap=0.25}), WOOD) end
-- twig with leaf (quirk)
local tm, tn = G.tube({ {30,38},{25,36},{22,31},{20,27} }, function(t) return 1.5 - 0.7*t end)
wood(tm, tn)
local lm = G.rell(18.5, 24, 0.5, -0.85, 4.4, 2.3)
G.tone(c, lm, X.light(X.pillow(lm, 2.2), {amb=0.15, wrap=0.3}), LEAF)
G.line(c, { {20,27},{17,22} }, LEAF[6])
-- shaft
local sm, sn, T, S = G.tube({ {19,55},{26,40},{34,28},{41,16} }, function(t) return 2.5 + 0.5*sin(t*8)^2 end)
wood(sm, sn)
sm:each(function(x, y) local k = K(x, y)
  if X.hash(x, y, 3) > 0.9 then c:px(x, y, WOOD[2]) end
  if abs(S[k] + 0.35 + 0.25*sin(T[k]*22)) < 0.09 then c:px(x, y, WOOD[5]) end
  if T[k] < 0.06 then c:px(x, y, S[k] < 0 and STEEL[4] or STEEL[2]) end
  if T[k] >= 0.06 and T[k] < 0.1 then c:px(x, y, STEEL[3]) end
  if T[k] > 0.4 and T[k] < 0.58 then
    local band = (x + y) % 3
    c:px(x, y, S[k] > 0.4 and LEA[1] or (band == 0 and LEA[2] or (S[k] < -0.3 and LEA[5] or LEA[3])))
  end
end)
-- knot
local kn = G.rell(31, 33, 1, 0, 2.6, 2.2)
G.tone(c, kn, X.light(X.pillow(kn, 2.4), {amb=0.1, wrap=0.2}), WOOD)
c:px(31, 33, WOOD[1]) c:px(32, 33, WOOD[2])
-- leather tail
G.line(c, { {30,28},{32,31},{31,34} }, LEA[3])
-- crook
local cm, cn, cT, cS = G.tube({ {41,16},{43,6},{55,6},{54,19} }, function(t) return 2.5 - 0.7*t end)
wood(cm, cn)
cm:each(function(x, y) local k = K(x, y)
  if X.hash(x, y, 5) > 0.9 then c:px(x, y, WOOD[2]) end
  if abs(cS[k] + 0.4) < 0.1 and cT[k] < 0.9 then c:px(x, y, WOOD[6]) end end)
c:px(53, 21, WOOD[5]) c:px(54, 21, WOOD[3])
G.fin(c, "walking-stick")
