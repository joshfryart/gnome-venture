-- peach (sonnet-medium test)
local LIB = "/home/user/gnome-venture/aseprite-source/v3/lib/"
local HP = dofile(LIB .. "hp.lua")
local X = dofile(LIB .. "hpx.lua").init(HP)
local K = X.K
local OUT = app.params.out or "./"
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.86 }
local function ell(cx, cy, rx, ry)
  local m = HP.mask()
  for y = floor(cy - ry) - 1, floor(cy + ry) + 1 do for x = floor(cx - rx) - 1, floor(cx + rx) + 1 do
    if ((x + 0.5 - cx) / rx) ^ 2 + ((y + 0.5 - cy) / ry) ^ 2 <= 1 then m:set(x, y) end end end
  return m
end
local function tn(c, m, ramp, R, o)
  o = o or {}
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  X.tone(c, m, v, ramp, { cuts = o.cuts or CUTS, bias = o.bias })
  return n, v
end
local function tnN(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  X.tone(c, m, v, ramp, { cuts = o.cuts or CUTS, bias = o.bias })
  return v
end
local function fin(c, name)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = OUT .. name .. ".aseprite", png = OUT .. name .. ".png", scale = 1 }
end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "peach" }
local YEL = { "#8a4a4a", "#c2685a", "#e8905a", "#f5b45e", "#fbd37c", "#fff0b4" }
local RED = { "#4a1f3e", "#7a2a4a", "#a8344f", "#cc4a50", "#e8685c", "#f89a7c" }
local LEAF = { "#1b3b4c", "#255650", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
c:groundShadow(32, 53, 15, 2)
-- leaf + stem
local lm, ln, T, S = X.cyl(33, 21, 51, 11, function(t) return max(0.5, 4.2 * sin(pi * min(1, t * 0.95 + 0.04)) ^ 0.7) end)
local lv = X.light(ln, { amb = 0.12, wrap = 0.3 })
X.tone(c, lm, lv, LEAF, { cuts = CUTS })
lm:each(function(x, y) local k = K(x, y)
  if abs(S[k]) < 0.18 and T[k] < 0.92 then c:px(x, y, S[k] <= 0 and LEAF[6] or LEAF[3]) end
  if T[k] > 0.2 and T[k] < 0.9 and abs(S[k]) > 0.3 and abs(S[k]) < 0.7 and floor((T[k] - S[k] * 0.3) * 11) % 3 == 0 then c:px(x, y, S[k] < 0 and LEAF[5] or LEAF[2]) end
end)
-- dewdrop on leaf (quirk)
c:px(43, 14, "#d6ecf0") c:px(44, 14, "#9ecbd8") c:px(43, 15, "#6e9cc0") c:px(44, 15, "#4e78a0")
-- fruit
local body = ell(32, 37, 16.5, 15.5)
local n = X.pillow(body, 12)
local v = X.light(n, { amb = 0.06, wrap = 0.2 })
local bl, yl = HP.mask(), HP.mask()
body:each(function(x, y)
  local t = (x - 32) * 0.75 + (y - 37) * 0.45 + (X.hash(x, y, 5) - 0.5) * 3.5
  if t > 4 or (x > 38 and y > 44) then bl:set(x, y) else yl:set(x, y) end
end)
X.tone(c, yl, v, YEL, { cuts = CUTS })
X.tone(c, bl, v, RED, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 } })
-- fuzz
body:each(function(x, y) local k = K(x, y)
  if v[k] > 0.55 and X.hash(x, y, 9) > 0.93 then c:px(x, y, bl:has(x, y) and RED[6] or YEL[6]) end
  if v[k] < 0.35 and X.hash(x, y, 2) > 0.95 then c:px(x, y, bl:has(x, y) and RED[1] or YEL[1]) end
end)
-- cleft: curved crease down the front, AO + lit lip
for y = 23, 47 do
  local x = 32 + floor(2.2 * sin((y - 23) / 24 * pi * 0.9) + 0.5)
  c:px(x, y, y > 40 and RED[2] or (bl:has(x, y) and RED[2] or YEL[1]))
  c:px(x + 1, y, bl:has(x + 1, y) and RED[3] or YEL[2])
  if y < 44 then c:px(x - 1, y, YEL[5]) end
end
-- stem cavity
for _, p in ipairs{ {29,22},{30,22},{31,22},{32,22},{33,22},{34,22},{30,23},{31,23},{32,23},{33,23} } do c:px(p[1], p[2], YEL[1]) end
c:px(31, 22, RED[1]) c:px(32, 22, RED[1]) c:px(32, 23, RED[2])
for _, p in ipairs{ {32,19},{32,20},{33,21},{32,21} } do c:px(p[1], p[2], "#6a4030") end
c:px(32, 19, "#9a6a40")
-- spec
c:px(23, 29, "#fffbe8") c:px(24, 29, "#fffbe8") c:px(23, 30, "#fff0b4") c:px(25, 28, "#fff0b4")
-- cool bounce
local rim = X.rim(n)
body:edge():each(function(x, y) if rim[K(x, y)] > 0.75 and y > 38 then c:px(x, y, "#c0508a") end end)
fin(c, "peach")
