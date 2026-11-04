-- wild-strawberries (lean D3o_12)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan2 = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function shade(c, m, ramp, R, o) o = o or {}
  local n = X.pillow(m, R or 4)
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  G.tone(c, m, v, ramp, o.cuts, o.bias, o.tok)
  return n, v
end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "wild-strawberries" }
-- sprig bearing three little strawberries at different heights, toothed trifoliate leaf, and one white five-petal flower. quirk: the lowest berry is still green-white at the tip.
local BER = { "#5a0f2c", "#8a1c3a", "#b8304a", "#dc4a58", "#f27a78", "#ffb09c" }
local LEAF = { "#1b3b2c", "#27583a", "#38794a", "#53984f", "#7cb85e", "#a6d26e" }
local STEM = { "#3b6449", "#5b8d5a", "#88b46e" }
local ltok = { r = { name = "leaf" } }
local function berry(cx, cy, k, tip)
  local m = c:ellipse(cx, cy - 1, 5, 5) m:add(c:ellipse(cx, cy + 3, 3, 4))
  local n, v = shade(c, m, BER, 5, { amb = 0.12, wrap = 0.25 })
  if tip then m:each(function(x, y) if y > cy + 4 then c:px(x, y, (y > cy + 5) and "#e7e6b8" or "#d6c8a0") end end) end
  m:each(function(x, y)
    if (x + y * 2 + k) % 4 == 0 and (floor(y / 2) + x) % 2 == 0 and y > cy - 4 then c:px(x, y, "#f6d880") c:px(x, y + 1, BER[1]) end
  end)
  c:px(cx - 2, cy - 3, BER[6]) c:px(cx - 3, cy - 2, BER[6])
  -- calyx
  for _, d in ipairs{ {-3, -4}, {-1, -5}, {1, -5}, {3, -4}, {0, -4} } do c:px(cx + d[1], cy + d[2], LEAF[4]) end
  c:px(cx, cy - 5, LEAF[2]) c:px(cx - 1, cy - 4, LEAF[5])
end
-- main stem + hanging pedicels
local stem = G.tube({ {32, 4}, {32, 12}, {33, 20}, {34, 26} }, function(t) return 0.8 end)
local function ped(pts) local m = G.tube(pts, function(t) return 0.7 end) m:each(function(x, y) c:px(x, y, STEM[2]) end) end
ped({ {32, 5}, {30, 8}, {26, 10}, {22, 15} })
ped({ {32, 8}, {36, 9}, {42, 11}, {46, 18} })
ped({ {33, 14}, {34, 22}, {32, 30}, {31, 35} })
berry(21, 22, 0, false) berry(46, 25, 1, false) berry(31, 42, 2, true)
-- flower top
for i = 0, 4 do
  local a = i * 2 * pi / 5 - pi / 2
  c:fillMask(c:ellipse(floor(32 + 3.5 * cos(a)), floor(7 + 3.5 * sin(a)), 2, 2), "#fbf5f0")
end
c:fillMask(c:ellipse(32, 7, 1, 1), "#f2c230")
-- trifoliate leaf at lower right with toothed edge
local function lf(ax, ay, bx, by, w)
  local len = sqrt((bx - ax)^2 + (by - ay)^2)
  local m, n, T, S = X.cyl(ax, ay, bx, by, function(t)
    if t > 0.98 then return -1 end
    if t < 0.25 then return 0.5 end
    local b = w * sin(pi * min(1, (t - 0.25) / 0.75 * 0.95 + 0.05)) ^ 0.7
    return max(0.5, b + ((floor(t * len * 0.9) % 2 == 0) and 0.6 or -0.3))
  end)
  G.tone(c, m, X.light(n, { amb = 0.12, wrap = 0.3 }), LEAF, { 0.2, 0.38, 0.55, 0.7, 0.86 }, nil, ltok)
  m:each(function(x, y) local s, t = S[K(x, y)], T[K(x, y)]
    if t < 0.3 then c:put(x, y, STEM[2], ltok) elseif abs(s) < 0.14 and t < 0.92 then c:put(x, y, LEAF[6], ltok) end end)
end
lf(34, 27, 52, 35, 4.2) lf(34, 27, 46, 48, 4.0) lf(34, 27, 52, 22, 3.6)
c:px(34, 26, STEM[1]) c:px(34, 27, STEM[1]) c:px(33, 27, STEM[2])
G.fin(c, "wild-strawberries")
