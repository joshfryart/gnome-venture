-- tamarind (lean D2o_18)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local NAME = "tamarind"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function sh(m, ramp, R, o) o = o or {}
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  G.tone(c, m, v, ramp, o.cuts, o.bias)
  return n, v
end
local function tub(pts, wfn, ramp, o) o = o or {}
  local m, n, T, S = G.tube(pts, wfn)
  G.tone(c, m, X.light(n, { amb = o.amb or 0.12, wrap = o.wrap or 0.3 }), ramp, o.cuts)
  return m, T, S
end
local BR = { "#3a2216", "#5c3a22", "#7f5530", "#a47845", "#c89d62", "#e0be86" }
local PU = { "#2e150e", "#4e2415", "#74381e", "#a05a30", "#c28048" }
local SE = { "#2a0e0c", "#4a1a14", "#6e2c1e", "#9a4a30", "#c27a58" }
c:groundShadow(32, 55, 18, 2)
local pod, T = tub({ {10, 42}, {16, 20}, {40, 18}, {54, 38} },
  function(t) local e = min(1, t * 6, (1 - t) * 6) return 0.9 + (3.4 + 1.1 * sin(t * pi * 6.5)) * (0.4 + 0.6 * e) * (t > 0.96 and 0.5 or 1) end, BR, { amb = 0.1, wrap = 0.25 })
-- constriction creases between seed bulges
pod:each(function(x, y) local t = T[K(x, y)]
  for i = 1, 5 do if abs(t - (i + 0.5) / 6.5 * 0.96 - 0.02) < 0.006 and t > 0.1 and t < 0.92 then c:px(x, y, BR[1]) end end
  if X.hash(x, y, 3) > 0.93 and t < 0.44 then c:px(x, y, BR[2]) end
end)
-- broken-open section showing sticky pulp, strings and seeds
local op = HP.mask()
pod:each(function(x, y) local t = T[K(x, y)] if t > 0.4 and t < 0.64 then op:set(x, y) end end)
sh(op, PU, 4, { amb = 0.3, wrap = 0.4 })
op:each(function(x, y) if (x * 3 + y * 5) % 7 == 0 and X.hash(x, y, 8) > 0.4 then c:px(x, y, PU[5]) end end)
-- jagged shell lips
op:edge():each(function(x, y) c:px(x, y, BR[4]) end)
-- seeds
for _, s in ipairs{ {28, 22.5, 0.2}, {33.5, 20.5, 0.0}, {39, 21.5, -0.2} } do
  local sm = G.rell(s[1], s[2], cos(s[3]), sin(s[3]), 2.6, 1.9)
  sh(sm, SE, 2.2, { amb = 0.2, wrap = 0.3 })
  c:px(floor(s[1] - 1), floor(s[2] - 1), "#f0c8a8")
end
-- stalk end curl at left tip
c:px(9, 43, BR[3]) c:px(9, 44, BR[2]) c:px(10, 45, BR[1])
-- loose seed on the ground (quirk: it has a sprout)
local ls = G.rell(33, 50, 1, 0.1, 3.2, 2.3)
sh(ls, SE, 2.4, { amb = 0.2, wrap = 0.3 })
c:px(32, 49, "#f0c8a8") c:px(33, 49, "#f0c8a8")
c:px(33, 47, "#5a9a48") c:px(33, 46, "#7ab860") c:px(32, 45, "#7ab860") c:px(34, 45, "#9ccd6c")
G.fin(c, NAME)
