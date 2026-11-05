-- stage-herb-4 (lean E2_10)
local NAME = "stage-herb-4"
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
-- bushy leafy dome
local dome = c:ellipse(32, 36, 22, 14)
dome:cut(c:rect(0, 46, 63, 63))
local dn = X.pillow(dome, 16)
local dtok = { r = { name = "dome" } }
local idx = X.tone(c, dome, X.light(dn, { amb = 0.1, wrap = 0.25 }), GRN, { cuts = CUTS.cuts, tok = dtok })
dome:shrink(1):each(function(x, y) local h = X.hash(x, y, 3)
  if h > 0.86 then c:put(x, y, GRN[min(6, idx[K(x, y)] + 1)], dtok) elseif h < 0.14 then c:put(x, y, GRN[max(1, idx[K(x, y)] - 1)], dtok) end end)
-- open flower clusters sitting on the dome
local function flower(cx, cy, r)
  ball(cx, cy, r, r, PUR, "#f2e8ff")
  c:put(cx - 1, cy, PUR[6]) c:put(cx + 1, cy + 1, PUR[1])
  c:put(cx, cy - r, PUR[5]) c:put(cx + r, cy, PUR[3]) c:put(cx - r, cy + 1, PUR[4])
end
flower(32, 16, 5)
flower(20, 24, 4)
flower(44, 24, 4)
flower(26, 34, 4)
flower(39, 34, 4)
flower(14, 36, 3)
flower(50, 36, 3)
-- quirk: a fat bee on the top bloom
ball(36, 10, 2, 2, { "#3a2a08", "#6a4a10", "#b08818", "#e0b428", "#f6d048", "#fff0a0" }, "#fff8d0")
c:put(36, 9, "#1a1014") c:put(36, 11, "#1a1014")
c:put(34, 7, "#e8f4ff") c:put(35, 6, "#e8f4ff") c:put(37, 7, "#e8f4ff") c:put(38, 6, "#e8f4ff")

G.save(c, NAME)
