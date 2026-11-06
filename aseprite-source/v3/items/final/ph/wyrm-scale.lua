-- wyrm-scale (lean D3o_15)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan2 = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan2 or function(y,x) return math.atan(y,x) end
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.86 }
local TOK = { r = { name = "p" } }
local c
local function paint(m, n, ramp, tex, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  m:each(function(x, y)
    local k = K(x, y)
    local val = v[k] or 0.5
    local i = 1
    for _, ct in ipairs(CUTS) do if val > ct then i = i + 1 end end
    if tex then i = i + (tex(x, y, k, i) or 0) end
    c:put(x, y, ramp[max(1, min(#ramp, i))], TOK)
  end)
  return v
end
local function hline(pts, hex) G.line(c, pts, hex) end
c = HP.canvas{ w = 64, h = 64, scale = 1, name = "wyrm-scale" }
local EM = { "#14323f", "#1b5e5c", "#238a6a", "#3fb070", "#7bd68a", "#c4f0a8" }
local GOLD = { "#5a3320", "#8a5224", "#b87a2c", "#dca64a", "#f2cf7a", "#fff0b0" }
c:groundShadow(33, 57, 15, 2)
local body = HP.mask()
for y = 8, 54 do
  local h
  if y < 28 then h = 19 * sqrt(max(0, 1 - ((28 - y) / 20) ^ 2)) else h = 19 * (1 - ((y - 28) / 27)) ^ 0.8 end
  local sh = (y - 30) * 0.13
  for x = floor(32 + sh - h + 0.5), floor(32 + sh + h - 0.5) do body:set(x, y) end
end
body:cut(c:ellipse(46, 44, 3, 3))   -- chipped bite
local rim = body:copy():cut(body:copy():shrink(2))
local inner = body:copy():cut(rim)
local gn = X.pillow(body, 12)
local ox, oy = 32, 12
paint(inner, gn, EM, function(x, y, k)
  local th = atan2(x - ox, y - oy)
  local d = sqrt((x - ox) ^ 2 + (y - oy) ^ 2)
  local r = 0
  if (th * 9) % 1 < 0.2 then r = r - 1 end
  if d % 8 < 1.0 and d > 10 then r = r + 1 end
  if (y + x) % 7 == 0 and G.X.hash(x, y, 9) > 0.7 then r = r - 1 end
  return r
end)
paint(rim, gn, GOLD, function(x, y, k) if (x + y) % 5 == 0 then return -1 end end)
-- glint, ember fleck (quirk)
for _, p in ipairs{ {24,20},{25,19},{24,21} } do c:px(p[1], p[2], EM[6]) end
c:px(27, 17, "#fffaf0")
c:px(37, 38, "#ff8a30") c:px(38, 38, "#ffc060") c:px(37, 39, "#c0481c")
G.fin(c, "wyrm-scale")
