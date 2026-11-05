-- tallow-wax (lean P1b_O15)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local H = X.hash
local NAME = "tallow-wax"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local TIN = { "#3c4662", "#566480", "#7c8aa5", "#a3b1c6", "#cdd8e4", "#f0f5f8" }
local W = { "#7b6678", "#a58d78", "#cfb68a", "#ecd8a3", "#f9ecc0", "#fffbe3" }
-- tin dish
local dm, dn = G.oval(32, 48, 26, 7.5, 0, 2.5)
G.toneN(c, dm, dn, TIN, { amb = 0.2, wrap = 0.4 })
local well = c:ellipse(32, 47, 21, 4.5)
well:each(function(x, y) c:put(x, y, (x < 26 and y < 47) and TIN[3] or (y > 48 and TIN[1] or TIN[2])) end)
for x = 8, 18 do if dm:has(x, 44) then c:put(x, 44, TIN[6]) end end
-- tallow block with slumped lumps and drips
local body = c:rrect(13, 24, 51, 46, 8)
body:add(c:ellipse(22, 25, 6, 3)):add(c:ellipse(40, 24, 7, 3.5))
for _, d in ipairs{ {20, 48, 2.4, 3.8}, {44, 49, 2.3, 4.8}, {32, 48, 1.8, 2.6} } do body:add(c:ellipse(d[1], d[2], d[3], d[4])) end
local n = X.pillow(body, 10)
local bias = {}
body:each(function(x, y) local k = K(x, y)
  if y <= 29 then bias[k] = 1 elseif y == 30 or y == 31 then bias[k] = -1 end
end)
local _, v = G.toneN(c, body, n, W, { amb = 0.12, wrap = 0.3, bias = bias })
-- warm subsurface glow low on the lit edge
body:each(function(x, y) if y > 40 and v[K(x, y)] < 0.5 and H(x, y, 3) > 0.45 then c:put(x, y, "#c58a58") end end)
-- thumbprint dent (quirk)
local dent = c:ellipse(37, 27, 4, 2)
dent:each(function(x, y) c:put(x, y, (x < 37 and y < 27) and W[2] or W[4]) end)
-- drip streaks on the front
for _, p in ipairs{ {18,36},{18,37},{18,38},{27,34},{27,35},{46,34},{46,35},{46,36},{46,37} } do c:put(p[1], p[2], W[5]) end
local sx, sy = G.specAt(body, n, 30)
c:put(sx, sy, W[6]) c:put(sx + 1, sy, W[6]) c:put(sx, sy + 1, W[6])
-- wick stub
local wm = c:line({ {29, 24}, {29, 20}, {31, 17}, {34, 18} }, 1)
c:fillMask(wm, "#5a4234")
c:put(29, 21, "#9a7a58") c:put(31, 17, "#9a7a58") c:put(34, 18, "#d9a95a")
G.save(c, NAME)
