-- reindeer-lichen (lean W2_15)
-- Upright branching tuft of pale grey-green antler-like lichen on a small mossy pebble; red pixie-cup tips are the quirk.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "reindeer-lichen" }
local cos, sin, pi, sqrt = math.cos, math.sin, math.pi, math.sqrt
local LICH = { "#4d6a63", "#6f8c7e", "#93ae9a", "#b6cbb0", "#d6e4c8", "#f0f6e0" }
local SOIL = { "#2c1e24", "#4a3030", "#6b4a3c", "#8f6a4c", "#b08a5c" }
local MOSS = { "#24472f", "#386c3e", "#58944a", "#86bc5c" }
local RED  = { "#7a1c2c", "#b52f38", "#e0584a", "#f8a07c" }
-- pebble / soil base
local base = c:ellipse(32, 54, 14, 5)
local bv = X.light(X.pillow(base, 8), { amb = 0.2, wrap = 0.3 })
base:each(function(x, y) if X.hash(x, y, 4) > 0.85 then bv[K(x, y)] = bv[K(x, y)] + 0.15 end end)
G.tone(c, base, bv, SOIL, { 0.2, 0.4, 0.6, 0.8 })
base:each(function(x, y) if y < 54 and X.hash(x, y, 7) > 0.5 and (x * 3 + y) % 4 < 2 then c:px(x, y, (x % 2 == 0) and MOSS[3] or MOSS[2]) end end)
c:px(22, 53, MOSS[4]) c:px(25, 52, MOSS[4]) c:px(41, 53, MOSS[4])
-- branching
local tips = {}
local function branch(x, y, ang, len, w, d, seed)
  local ex, ey = x + cos(ang) * len, y + sin(ang) * len
  local bend = (X.hash(seed, d, 3) - 0.5) * len * 0.5
  local px, py = -sin(ang) * bend, cos(ang) * bend
  local p = { {x, y}, {x + (ex - x) * 0.33 + px, y + (ey - y) * 0.33 + py}, {x + (ex - x) * 0.66 + px, y + (ey - y) * 0.66 + py}, {ex, ey} }
  local m, n = G.tube(p, function(t) return w * (1 - 0.4 * t) end, { steps = 24 })
  local v = X.light(n, { amb = 0.3, wrap = 0.4 })
  G.tone(c, m, v, LICH, { 0.2, 0.38, 0.55, 0.72, 0.88 })
  if d >= 3 then tips[#tips + 1] = { ex, ey } return end
  local s = X.hash(seed, d, 9)
  branch(ex, ey, ang - 0.5 - s * 0.2, len * 0.72, w * 0.8, d + 1, seed * 3 + 1)
  branch(ex, ey, ang + 0.5 + s * 0.2, len * 0.72, w * 0.8, d + 1, seed * 3 + 2)
  if d == 0 then
    local mx, my = G.bez(p, 0.55)
    branch(mx, my, ang + (s > 0.5 and 0.9 or -0.9), len * 0.6, w * 0.7, d + 2, seed * 3 + 7)
  end
end
-- back stalks first, then front
local mains = { {-90 - 8, 15}, {-90 + 6, 17}, {-90 - 24, 12}, {-90 + 26, 12}, {-90 - 44, 8}, {-90 + 46, 8} }
for i, mm in ipairs(mains) do
  local a = mm[1] * pi / 180
  branch(32 + (mm[1] + 90) * 0.08, 53, a, mm[2], 1.15, 0, 11 + i * 5)
end
-- small bulb of lichen at the root
local root = c:ellipse(32, 51, 6, 2)
G.tone(c, root, X.light(X.pillow(root, 4), { amb = 0.3, wrap = 0.3 }), LICH, { 0.2, 0.4, 0.6, 0.8, 0.9 })
-- red pixie-cup tips (quirk): 3 of the tips
local picks = { 1, 4, 7 }
for _, i in ipairs(picks) do local t = tips[i * 2 > #tips and #tips or i * 2]
  if t then local x, y = math.floor(t[1] + 0.5), math.floor(t[2] + 0.5)
    c:px(x, y, RED[3]) c:px(x + 1, y, RED[2]) c:px(x, y - 1, RED[4]) c:px(x + 1, y - 1, RED[3]) end end
c:sparkle(37, 31)
G.fin(c, "reindeer-lichen")
