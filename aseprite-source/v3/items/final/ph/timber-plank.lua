-- timber-plank (lean D3o_4)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function paint(c, m, ramp, f) m:each(function(x, y) local i = floor(f(x, y) + 0.5); c:put(x, y, ramp[max(1, min(#ramp, i))]) end) end
local H = function(x, y, s) return X.hash(x, y, s) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "timber-plank" }
local WD = { "#3d2216", "#633822", "#8a5230", "#b0743f", "#d29a5a", "#ecc07c" }
local EG = { "#6e4527", "#9a6a3a", "#c89558", "#e6bf86" }
c:groundShadow(34, 54, 22, 3)
local function plank(x0, y0, x1, y1, seed, knot)
  local body = c:rrect(x0, y0, x1 - 6, y1, 2)
  local cap = c:poly{ {x1 - 6, y0}, {x1, y0 + 2}, {x1, y1 - 1}, {x1 - 6, y1} }
  local h = y1 - y0
  paint(c, body, WD, function(x, y)
    local r = (y - y0) / h
    local i = 4.3 - r * 2.6
    if y == y0 or y == y0 + 1 then i = 5.6 end
    local g = sin(x * 0.11 + y * 1.9 + seed) + sin(x * 0.04 - y * 0.7)
    if g > 1.35 and H(x, y, seed) > 0.25 then i = i - 1 end
    if g < -1.5 then i = i + 0.6 end
    if y >= y1 - 1 then i = 1.4 end
    return i
  end)
  paint(c, cap, EG, function(x, y)
    local rr = ((x - (x1 - 3)) ^ 2 * 0.5 + (y - (y0 + h / 2)) ^ 2) ^ 0.5
    local i = 2 + (floor(rr * 0.9) % 2) * 1.2 - (y - y0) * 0.05
    if x == x1 - 6 then i = 1 end
    return i
  end)
  if knot then
    local k = c:ellipse(knot[1], knot[2], 3, 2)
    paint(c, k, WD, function(x, y) return 1 + floor(sqrt((x - knot[1]) ^ 2 + ((y - knot[2]) * 1.4) ^ 2)) end)
    c:put(knot[1], knot[2], WD[1])
  end
  c:put(x0 + 3, y0 + h // 2, "#9aa4b8") c:put(x0 + 3, y0 + h // 2 + 1, "#444b62") c:put(x0 + 4, y0 + h // 2, "#444b62")
end
plank(8, 14, 52, 27, 2.1, {30, 21})
plank(13, 31, 57, 45, 5.7, nil)
-- AO where the front plank meets the back one
for x = 14, 50 do c:put(x, 30, WD[1]) end
-- worm hole + moss quirk
c:put(40, 38, WD[1]) c:put(41, 38, WD[1]) c:put(41, 39, WD[2])
for _, p in ipairs{ {16,31,"#4c9440"},{17,31,"#78b84a"},{18,31,"#4c9440"},{17,32,"#2f6b34"},{16,30,"#a6d462"} } do c:put(p[1], p[2], p[3]) end
c:put(22, 18, WD[6]) c:put(23, 18, WD[6])
G.fin(c, "timber-plank")
