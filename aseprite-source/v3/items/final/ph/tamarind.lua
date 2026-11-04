-- tamarind (lean W2_32)
-- A bumpy arching scurfy pod, split open on top to show sticky red-brown pulp, two glossy seeds and fibre strings; quirk: a spare seed and a tiny sprig below.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "tamarind" }
local abs, sin, pi, min, max, floor = math.abs, math.sin, math.pi, math.min, math.max, math.floor
local PEEL = { "#3a2218", "#5c3824", "#84563a", "#a87a50", "#caa070", "#e8c898" }
local PULP = { "#3a1a1e", "#5e2a24", "#8a4228", "#b8622e", "#dc8c48", "#f2b868" }
local SEED = { "#2a1418", "#4a2220", "#6e3226", "#94503a" }
local LEAF = { "#1e3e3a", "#2e6446", "#4a944e", "#76b85a", "#a4d06c" }
local function shade(m, ramp, R, o)
  local n = X.pillow(m, R)
  G.tone(c, m, X.light(n, o or { amb = 0.12, wrap = 0.3 }), ramp)
end
c:groundShadow(32, 58, 12, 1.6)
local P = { { 9, 38 }, { 12, 6 }, { 48, 4 }, { 56, 38 } }
local pm, pn, T, S = G.tube(P, function(t)
  local e = min(1, t * 7, (1 - t) * 7) ^ 0.6
  return max(1.1, (3.7 + 0.9 * sin(t * pi * 8)) * e)
end)
local v = X.light(pn, { amb = 0.1, wrap = 0.25 })
local bias = {}
pm:each(function(x, y) local k = K(x, y)
  local ph = (T[k] * 8) % 1
  if ph < 0.09 or ph > 0.94 then bias[k] = -1 end                    -- constrictions between seeds
  if X.hash(x, y, 7) > 0.88 then bias[k] = (bias[k] or 0) + 1 end    -- scurf specks
end)
G.tone(c, pm, v, PEEL, { 0.2, 0.38, 0.54, 0.7, 0.86 }, bias)
-- split window showing pulp
local win = HP.mask()
pm:each(function(x, y) local k = K(x, y)
  if T[k] > 0.36 and T[k] < 0.62 and abs(S[k]) < 0.5 - 0.5 * abs(T[k] - 0.49) * 3 then win:set(x, y) end
end)
G.tone(c, win, X.light(X.pillow(win, 2.5), { amb = 0.15, wrap = 0.4 }), PULP)
win:copy():edge():each(function(x, y) c:px(x, y, PULP[1]) end)
-- seeds in the pulp
for _, t in ipairs{ 0.43, 0.55 } do
  local x, y = G.bez(P, t)
  local sm = G.rell(x, y, 1, 0, 2.3, 1.6)
  shade(sm, SEED, 2, { amb = 0.1, wrap = 0.2 })
  c:px(floor(x - 1), floor(y - 1), "#e8b8a0")
end
-- fibre strings across the opening
local fx, fy = G.bez(P, 0.49)
G.line(c, { { floor(fx), floor(fy - 3) }, { floor(fx + 1), floor(fy) }, { floor(fx), floor(fy + 3) } }, PULP[5])
-- stalk stub and tiny sprig on the right end
G.line(c, { { 56, 40 }, { 57, 43 }, { 57, 46 } }, PEEL[2])
-- loose seed under the arch
shade(G.rell(31, 49, 1, -0.3, 3.2, 2.2), SEED, 2.2, { amb = 0.1, wrap = 0.2 })
c:px(29, 48, "#e8b8a0") c:px(30, 47, "#d09880")
-- sprout from the loose seed: two leaflet pairs on a stalk
G.line(c, { { 32, 47 }, { 32, 43 }, { 33, 40 } }, LEAF[3])
for _, l in ipairs{ { 30, 43, -1 }, { 35, 42, 1 }, { 30, 40, -1 }, { 35, 39, 1 } } do
  shade(G.rell(l[1] + (l[3] > 0 and 0 or 0), l[2], l[3], -0.4, 2, 1), LEAF, 1.2, { amb = 0.2, wrap = 0.3 })
end
c:px(33, 38, LEAF[5])
G.fin(c, "tamarind")
