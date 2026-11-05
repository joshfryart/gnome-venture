-- tomatillo (lean P1b_O20)
-- quirk: the papery husk is nibbled on the left; the big lime fruit shows through the open front.
local NAME = "tomatillo"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local hash = X.hash
local function tk(n) return { r = { name = n } } end
local function clamp(i, n) return max(1, min(n, i)) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local ST = { "#5c4426", "#8c7236", "#b89a48", "#d8be62", "#eeda8c", "#fcf2c0" }
local FR = { "#16462c", "#287034", "#4a9c3a", "#7cc440", "#aae45e", "#e4fa94" }
c:groundShadow(33, 55, 17, 3)
c:groundShadow(33, 55, 19, 3)
local fruit, fn = G.oval(32, 38, 15, 13.5, 0, 1)
local bias0 = {}
local _, fv = G.toneN(c, fruit, fn, FR, { tok = tk("fruit"), cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 } })
local sx, sy = G.specAt(fruit, fn, 30)
for _, p in ipairs{ {-1,0},{0,0},{1,0},{-1,1},{0,-1} } do c:px(sx + p[1] - 1, sy + p[2], "#f6ffd8") end
-- sticky dark-green seam lines + rim light
fruit:edge():each(function(x, y) if x > 36 and y > 40 then c:px(x, y, "#2a8a50") end end)
-- husk: five papery petals lifting from the top, draped round the fruit, open at the front
local petals = { { -21, 40, 18 }, { -12, 46, 12 }, { 20, 41, 18 }, { 12, 47, 12 }, { 0, 21, 14 } }
local function petal(dx, ey, w, front)
  local m, n = G.tube({ {32, 15}, {32 + dx * 0.3, 18}, {32 + dx * 1.15, 27}, {32 + dx * 0.95, ey} },
    function(t) return (w / 3.2) * sin(min(1, t * 1.05) * pi) ^ 0.6 + 1.2 end)
  return m, n
end
local hm = HP.mask()
local hn = {}
for i, p in ipairs(petals) do
  local m, n = petal(p[1], p[2], p[3] / 2 + 5)
  local v = X.light(n, { amb = 0.1, wrap = 0.3 })
  local bias = {}
  m:each(function(x, y) if (x + y * 2 + i) % 6 == 0 then bias[K(x, y)] = -1 end end)
  G.toneN(c, m, n, ST, { tok = tk("husk"), bias = bias, cuts = { 0.22, 0.4, 0.56, 0.72, 0.88 } })
  m:edge():each(function(x, y) if y > 38 then c:px(x, y, ST[2]) end end)
  hm:add(m)
end
-- torn petal edge: nibbled notch (quirk) + lantern ribs
for _, p in ipairs{ {18,41},{19,42},{18,43},{20,44} } do c:px(p[1], p[2], ST[1]) end
-- calyx knot and stem
c:fillMask(c:ellipse(32, 16, 3, 2), ST[2])
c:px(31, 15, ST[5]) c:px(32, 15, ST[4])
local st, sn = G.tube({ { 32, 16 }, { 32, 11 }, { 33, 8 }, { 37, 8 } }, function(t) return 1.8 - 0.4 * t end)
X.tone(c, st, X.light(sn, { amb = 0.12, wrap = 0.3 }), { "#3a4a22", "#5e7a30", "#8aa43e", "#bcd060" }, { cuts = { 0.3, 0.55, 0.8 }, tok = tk("stem") })
G.save(c, NAME)
