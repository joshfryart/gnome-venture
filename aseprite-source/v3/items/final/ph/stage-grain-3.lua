-- stage-grain-3 (lean E2_10)
local NAME = "stage-grain-3"
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
local function ear(bx, by, tx, ty, w, ln)
  stalk({ {bx, by}, {bx, by - 8}, {tx, ty + ln + 6}, {tx, ty + ln} }, 1.3, 1.0, GRN)
  -- ear: stacked plump spikelets
  for i = 0, ln - 1, 3 do
    local y = ty + i
    ball(tx - 2, y + 1, 2, 2, GRN, "#d8f0a0"); ball(tx + 2, y + 1, 2, 2, GRN, "#d8f0a0")
    ball(tx, y - 1, 2, 2, GRN, nil)
  end
  -- awns
  for i = 0, ln - 2, 4 do
    local y = ty + i
    c:put(tx - 4, y, GRN[4]) c:put(tx - 5, y - 2, GRN[5]) c:put(tx - 6, y - 4, GRN[5])
    c:put(tx + 4, y, GRN[4]) c:put(tx + 5, y - 2, GRN[5]) c:put(tx + 6, y - 4, GRN[5])
  end
  c:line({ {tx, ty - 2}, {tx, ty - 8} }, 1):each(function(x, y) c:put(x, y, GRN[5]) end)
end
leaf(24, 50, 12, 44, 8, 30, 3, GRN, { 5, 10 })
leaf(40, 50, 52, 42, 56, 32, 3, GRN, { 5, 10 })
ear(32, 48, 32, 12, 4, 14)
ear(26, 49, 22, 22, 4, 9)
ear(38, 49, 42, 24, 4, 9)
-- quirk: ladybug on the left leaf
ball(14, 40, 2, 2, { "#4a0a12", "#7a1020", "#b01a28", "#d8323a", "#ef5a50", "#ff8a78" }, "#ffd0c0")
c:put(14, 39, "#1a1014") c:put(14, 41, "#1a1014") c:put(13, 40, "#1a1014")

G.save(c, NAME)
