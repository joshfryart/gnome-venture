-- tomato (lean D3o_5)
-- A plump, slightly pleated beefsteak with a splayed five-sepal calyx and a short kinked vine stem.
-- quirk: a single dew drop clings to the lower right shoulder.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "tomato" }
local sin, cos, pi, sqrt, abs, floor = math.sin, math.cos, math.pi, math.sqrt, math.abs, math.floor
local function sh(m, ramp, R, amb, wrap, bias, tok)
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = amb or 0.1, wrap = wrap or 0.25 })
  G.tone(c, m, v, ramp, nil, bias, tok)
  return n, v
end
local RED = { "#4a1026", "#7a1a38", "#b0283a", "#da4238", "#f26a48", "#ffa874" }
local LF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local body = HP.mask()
for y = 20, 54 do for x = 11, 53 do
  local dy, dx = (y - 37) / 17, (x - 32) / 21
  local ang = math.atan(dy, dx)
  local r = 1 + 0.03 * cos(5 * ang)
  if dx * dx + dy * dy <= r * r * (dy < 0 and 0.97 or 1) then body:set(x, y) end
end end
body:cut(c:ellipse(32, 19, 5, 3))  -- shallow dimple at top
local n, v = sh(body, RED, 15, 0.08, 0.28)
-- pleat creases
c:line({ {24, 24}, {20, 32}, {20, 42}, {23, 50} }, 1):each(function(x, y) if body:has(x, y) then c:px(x, y, RED[3]) end end)
c:line({ {40, 24}, {44, 32}, {44, 42}, {41, 50} }, 1):each(function(x, y) if body:has(x, y) then c:px(x, y, RED[2]) end end)
-- cool bounce lower right
local rim = X.rim(n)
body:edge():each(function(x, y) if rim[K(x, y)] > 0.7 and y > 40 and x > 36 then c:px(x, y, "#c43c58") end end)
-- gloss
c:fillMask(c:rect(21, 30, 22, 33), "#ffe4d0") c:px(23, 29, "#ffe4d0") c:px(22, 29, RED[6]) c:px(23, 28, RED[6]) c:px(21, 34, RED[6])
c:px(27, 26, RED[6]) c:px(28, 26, RED[6])
-- calyx sepals
local tips = { {20, 25}, {44, 25}, {24, 31}, {40, 31}, {32, 28} }
for i, t in ipairs(tips) do
  local sm, sn = G.tube({ {32, 21}, {32 + (t[1] - 32) * 0.35, 20}, {32 + (t[1] - 32) * 0.75, 21}, {t[1], t[2]} }, function(u) return 1.9 * (1 - u) + 0.6 end)
  G.tone(c, sm, X.light(sn, { amb = 0.12, wrap = 0.3 }), LF)
end
c:fillMask(c:ellipse(32, 21, 2, 1), LF[1])
-- stem
local sm, sn = G.tube({ {32, 21}, {32, 17}, {31, 13}, {35, 9} }, function(t) return 2.0 - 0.8 * t end)
G.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), { "#3b5a2a", "#5a7e36", "#88a84a", "#bcd478" }, { 0.3, 0.55, 0.8 })
-- dew drop
c:fillMask(c:ellipse(43, 44, 2, 2.5), "#a8d4ee")
c:px(43, 46, "#5a86bc") c:px(44, 46, "#5a86bc") c:px(42, 43, "#fffff6") c:px(42, 42, "#e0f4ff")
G.fin(c, "tomato")
