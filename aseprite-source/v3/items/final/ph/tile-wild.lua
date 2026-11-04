-- tile-wild (lean D3o_4)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function paint(c, m, ramp, f) m:each(function(x, y) local i = floor(f(x, y) + 0.5); c:put(x, y, ramp[max(1, min(#ramp, i))]) end) end
local H = function(x, y, s) return X.hash(x, y, s) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "tile-wild" }
local GR = { "#1f4a2c", "#2f6b34", "#4c9440", "#78b84a", "#a6d462", "#d0ea84" }
local DT = { "#3b2418", "#5c3a24", "#7d5232", "#a06c3f", "#c28c52" }
c:groundShadow(34, 53, 22, 3)
local top = c:poly{ {32,12},{55,24},{32,36},{9,24} }
local lf  = c:poly{ {9,24},{32,36},{32,53},{9,41} }
local rt  = c:poly{ {32,36},{55,24},{55,41},{32,53} }
paint(c, lf, DT, function(x, y) local h = H(x, y, 3); local i = 3.6 - (y - 24 - (x - 9) * 0.52) * 0.04 + (h - 0.5) * 1.2; if h > 0.93 then i = 5 end; if h < 0.07 then i = 1 end; return i end)
paint(c, rt, DT, function(x, y) local h = H(x, y, 5); local i = 2.5 + (x - 32) * 0.02 + (y - 36 + (x - 32) * 0.52) * -0.03 + (h - 0.5) * 1.2; if h > 0.94 then i = 4 end; if h < 0.08 then i = 1 end; return i end)
-- roots / pebble in the dirt
for _, p in ipairs{ {14,35},{15,36},{16,36},{20,39},{21,40} } do c:put(p[1], p[2], DT[1]) end
c:fillMask(c:rect(40, 42, 42, 43), "#8a8f9c") c:put(40, 42, "#c3c8d2") c:put(42, 43, "#585d70") c:put(41, 44, "#585d70")
-- grass overhang drips
local function drip(face, x0, y0, dx, dy, seed)
  face:each(function(x, y)
    local ey = (dy > 0) and (y0 + (x - x0) * 12 / 23) or (y0 - (x - x0) * 12 / 23)
    local d = y - ey
    local lim = 1.6 + 2.6 * H(floor(x / 2), 0, seed)
    if d < lim then c:put(x, y, (d < 0.8) and GR[(H(x, y, 9) > 0.6) and 4 or 3] or GR[2]) end
  end)
end
drip(lf, 9, 24, 1, 1, 21) drip(rt, 32, 36, 1, -1, 22)
paint(c, top, GR, function(x, y) local h = H(x, y, 7); local i = 4.3 - ((x - 32) * 0.045 + (y - 24) * 0.07) + (h - 0.5) * 1.6; if abs(x - 32) / 23 + abs(y - 24) / 12 > 0.88 then i = i - 0.8 end; return i end)
-- blades
local function tuft(x, y, k) for j = 0, k do c:put(x - j, y - 1 - j, GR[5]) c:put(x, y - j * 1, GR[4]) c:put(x + 1 + (j > 1 and 1 or 0), y - j, GR[3]) end c:put(x, y - k - 1, GR[6]) end
tuft(18, 25, 2) tuft(46, 27, 2) tuft(30, 30, 3) tuft(40, 17, 2) tuft(22, 18, 1) tuft(50, 22, 1)
-- flowers
local function flower(x, y, pet, cen) for _, d in ipairs{ {-1,0},{1,0},{0,-1},{0,1} } do c:put(x + d[1], y + d[2], pet) end c:put(x, y, cen) end
flower(26, 23, "#fff4e0", "#f0b82a") flower(37, 20, "#ff9fb8", "#f0b82a") flower(44, 31, "#fff4e0", "#f0b82a")
-- quirk: tiny red mushroom
c:fillMask(c:rect(14, 27, 16, 27), "#d9433f") c:put(15, 26, "#d9433f") c:put(15, 27, "#fff4e0") c:put(15, 28, "#e8d8c0") c:put(14, 28, "#e8d8c0")
c:put(14, 27, "#a82a35") c:put(16, 27, "#a82a35")
G.fin(c, "tile-wild")
