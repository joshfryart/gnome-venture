-- woven-basket (lean D3o_15)
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
c = HP.canvas{ w = 64, h = 64, scale = 1, name = "woven-basket" }
local REED = { "#4a2a1a", "#6e421f", "#946028", "#bc8636", "#dcaa50", "#f4cf80" }
local RED  = { "#4a1424", "#721c30", "#9c2c3c", "#c84a48", "#e87a60", "#ffb088" }
local INSIDE = { "#1e1018", "#341a1e", "#4c2a22", "#6a3c2a" }
c:groundShadow(32, 56, 22, 3)
-- handle: twisted reed arch
local hm, hn, hT, hS = G.tube({ {11,31},{8,1},{56,1},{53,31} }, function(t) return 2.3 end)
paint(hm, hn, REED, function(x, y, k) local b = floor(hT[k] * 44 + hS[k] * 2.2) if b % 2 == 0 then return -1 end end)
-- body
local body = HP.mask()
for y = 30, 50 do local h = 21 - ((y - 30) / 20) ^ 1.7 * 5 for x = floor(32 - h + 0.5), floor(32 + h - 0.5) do body:set(x, y) end end
body:add(c:ellipse(32, 50, 16, 4))
local bn = X.pillow(body, 13)
local x0, y0 = 10, 28
paint(body, bn, REED, function(x, y, k, i)
  local cx, cy = floor((x - x0) / 4), floor((y - y0) / 4)
  local d = 0
  if (cx + cy) % 2 == 0 then local r = (y - y0) % 4 if r == 0 then d = 1 elseif r == 3 then d = -1 end d = d + 1
  else local cc = (x - x0) % 4 if cc == 0 then d = 1 elseif cc == 3 then d = -1 end end
  if y >= 40 and y <= 43 then d = d - 1 end
  return d
end, { amb = 0.05 })
-- dyed red band (reuse same texture)
local band = HP.mask() band:add(body) band:clip(c:rect(0, 40, 63, 43))
local vb = X.light(bn, { amb = 0.05, wrap = 0.25 })
band:each(function(x, y)
  local k = K(x, y) local val = vb[k] or 0.5 local i = 1
  for _, ct in ipairs(CUTS) do if val > ct then i = i + 1 end end
  local cx = floor((x - x0) / 4)
  local cc = (x - x0) % 4
  if cc == 0 then i = i + 1 elseif cc == 3 then i = i - 1 end
  if (y == 40) then i = i + 1 end if y == 43 then i = i - 1 end
  c:put(x, y, RED[max(1, min(6, i))], TOK)
end)
-- opening and rim
local op = c:ellipse(32, 30, 20, 4)
local opn = X.pillow(op, 4)
paint(op, opn, INSIDE, function(x, y) if (x + y) % 5 == 0 then return 1 end end)
local rim = c:ellipse(32, 30, 22, 5.5):cut(c:ellipse(32, 30, 19, 3.2))
local rn = X.pillow(rim, 3)
paint(rim, rn, REED, function(x, y, k)
  local a = atan2((y - 30) * 3.5, x - 32)
  if floor(a * 11) % 2 == 0 then return -1 else return 1 end
end)
-- quirk: a loose reed end curling out of the rim
G.line(c, { {52,32},{55,33},{57,32},{57,30} }, REED[5])
c:px(57, 29, REED[6]) c:px(55, 34, REED[2])
c:px(17, 36, "#fff0d0") c:px(18, 36, "#fff0d0")
G.fin(c, "woven-basket")
