-- soybean (lean D2o_3)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "soybean" }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(m, R, ramp, o) o = o or {}
  local n = X.pillow(m, R) local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  G.tone(c, m, v, ramp, o.cuts, o.bias) return v, n end
local function fill(m, hex) c:fillMask(m, hex) end
-- fuzzy green pod arc split open with three cream beans bulging out, two loose beans, hooked pod tip (quirk)
local POD = { "#1d3f22", "#2f5f2c", "#4a8036", "#6ea044", "#98c05a", "#c6dd88" }
local BEAN = { "#a6853a", "#c9a85a", "#e3c97c", "#f1deA0", "#fbefc4", "#fffaf0" }
c:groundShadow(32, 58, 18, 3)
local pm = G.tube({ {8,34}, {14,10}, {42,8}, {55,30} }, function(t) return 4.8 * sin(pi * min(1, t * 0.9 + 0.05)) ^ 0.5 + 0.8 * sin(t * pi * 6) end)
local v = shade(pm, 5, POD)
-- fuzz
pm:each(function(x, y) if X.hash(x, y, 3) > 0.9 then c:px(x, y, POD[6]) elseif X.hash(x, y, 8) > 0.93 then c:px(x, y, POD[2]) end end)
-- hooked tip
G.line(c, { {55,31}, {56,34}, {55,36}, {53,36} }, POD[3]) c:px(56, 33, POD[5]) c:px(54, 36, POD[1])
-- split slot with beans
local pts = { {19,18}, {32,13}, {44,17} }
fill(c:ellipse(32, 17, 15, 3), POD[1])
for i, p in ipairs(pts) do
  local b = c:ellipse(p[1], p[2] + 1, 5, 4) shade(b, 4, BEAN)
  c:px(p[1] - 2, p[2] - 1, BEAN[6]) c:px(p[1] - 1, p[2] - 1, BEAN[6]) end
-- loose beans
local function bean(cx, cy, ux, uy)
  local b = G.rell(cx, cy, ux, uy, 6, 4.5) shade(b, 4.5, BEAN)
  c:px(cx - 3, cy - 2, BEAN[6]) c:px(cx - 2, cy - 2, BEAN[6])
  c:px(cx + 1, cy + 2, "#7a5a2a") c:px(cx + 2, cy + 2, "#7a5a2a") c:px(cx + 1, cy + 1, "#9a7a3a") return b end
bean(21, 46, 0.95, 0.3) bean(36, 49, 0.9, -0.4)
bean(46, 45, 0.5, 0.85)
G.fin(c, "soybean")
