-- stage-herb-2 (lean E2_10)
local NAME = "stage-herb-2"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 } }
local SOIL = { "#2a1a1c", "#4a2c26", "#6e4430", "#8f5e3c", "#b07c4c", "#cf9c62" }
local GRN  = { "#17382f", "#1f5a3a", "#2f7c3f", "#4c9a44", "#79b852", "#b0d878" }
local GOLD = { "#5a2e1c", "#8a4e22", "#b8782a", "#dca040", "#f0c460", "#fbe49a" }
local PUR  = { "#2c1a4a", "#46298a", "#6a46b0", "#8c6acc", "#b095e4", "#d9c8f6" }
local function soil()
  c:groundShadow(32, 54, 24, 5)
  local m = c:ellipse(32, 50, 22, 8)
  local n = X.pillow(m, 9)
  local tok = { r = { name = "soil" } }
  local idx = X.tone(c, m, X.light(n, { amb = 0.15, wrap = 0.3 }), SOIL, { cuts = CUTS.cuts, tok = tok })
  m:shrink(1):each(function(x, y) local h = X.hash(x, y, 7)
    if h > 0.9 then c:put(x, y, SOIL[6], tok) elseif h < 0.1 then c:put(x, y, SOIL[1], tok) end end)
  return m
end
local function stalk(pts, w0, w1, ramp)
  local m, n, T = G.tube(pts, function(t) return w0 + (w1 - w0) * t end)
  local v = X.light(n, { amb = 0.15, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    local i = v[k] > 0.62 and 4 or (v[k] > 0.4 and 3 or 2)
    c:put(x, y, ramp[i], { r = { name = "st" } }) end)
  return m
end
local function leaf(ax, ay, cx, cy, bx, by, w, ramp, veins, fold)
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local u = min(1, t * 0.9 + 0.1)
    return max(0.5, w * sin(pi * u ^ 1.1) ^ 0.75) end, { fold = fold or 0.4 })
  local tok = { r = { name = "lf" .. ax .. bx .. ay } }
  G.toneN(c, m, n, ramp, { tok = tok, cuts = CUTS.cuts, amb = 0.12, wrap = 0.22 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.12 and t > 0.05 and t < 0.92 then c:put(x, y, s <= 0 and ramp[6] or ramp[2], tok) return end
    for _, vt in ipairs(veins or {}) do
      local d = t * L - (vt + abs(s) * 3)
      if d > -0.5 and d < 0.5 and abs(s) > 0.3 and abs(s) < 0.75 then c:put(x, y, s < 0 and ramp[5] or ramp[2], tok) return end
    end end)
  return m
end
local function ball(cx, cy, rx, ry, ramp, spec)
  local m = c:ellipse(cx, cy, rx, ry)
  local n = X.pillow(m, max(rx, ry))
  local tok = { r = { name = "b" .. cx .. cy } }
  X.tone(c, m, X.light(n, { amb = 0.08, wrap = 0.22 }), ramp, { cuts = CUTS.cuts, tok = tok })
  if spec then local sx, sy = G.specAt(m, n, 20) if sx then c:put(sx, sy, spec, tok) end end
  return m
end

soil()
leaf(32, 48, 14, 46, 6, 38, 4, GRN, { 4, 8 })
leaf(32, 48, 50, 46, 58, 38, 4, GRN, { 4, 8 })
leaf(32, 48, 20, 36, 14, 24, 4, GRN, { 4, 8 })
leaf(32, 48, 44, 36, 50, 24, 4, GRN, { 4, 8 })
stalk({ {32, 50}, {31, 38}, {33, 26}, {32, 18} }, 1.5, 1.0, GRN)
leaf(32, 30, 26, 24, 24, 16, 3, GRN, { 3 })
leaf(32, 28, 38, 22, 42, 14, 3, GRN, { 3 })
ball(32, 15, 3, 3, { "#7a2a4a", "#a8406a", "#d0608a", "#ec84a8", "#f8aac4", "#ffd6e2" }, "#f4ffff")
-- quirk: dew drop on a leaf
ball(14, 40, 1, 1, { "#2a5a78", "#4a8cae", "#8cc8e0", "#bfe8f4", "#e4f8fc", "#f4ffff" }, "#f4ffff")

G.save(c, NAME)
