-- marzipan (lean E2_03)
local NAME = "marzipan"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local T = { r = { name = "d" } }
local function body(m, ramp, R, name, amb)
  local n = X.pillow(m, R)
  local idx = X.tone(c, m, X.light(n, { amb = amb or 0.1, wrap = 0.25 }), ramp, { cuts = { .22, .4, .56, .72, .86 }, tok = { r = { name = name } } })
  return n, idx
end
local function draw(lm, hex, within) lm:each(function(x, y) if (not within) or within:has(x, y) then c:put(x, y, hex, T) end end) end
local function dot(x, y, hex, within) if (not within) or within:has(x, y) then c:put(x, y, hex, T) end end
c:groundShadow(32, 54, 20, 3)
local R = { "#8e4a56", "#bc6c6c", "#e0907e", "#f0b09a", "#f9ceb0", "#fdeacc" }
-- tail curl (behind)
local tail = c:line({ {12,36},{8,34},{8,30},{11,29},{12,31} }, 2)
body(tail, R, 2, "tail")
-- legs
for _, lx in ipairs{ 14, 21, 33, 40 } do
  local lg = c:rect(lx, 44, lx + 4, 52)
  body(lg, R, 3, "leg" .. lx, 0.0)
end
local bd = c:ellipse(27, 38, 19, 13)
body(bd, R, 14, "body")
local hd = c:ellipse(45, 36, 9, 9)
body(hd, R, 9, "head")
local ear = c:poly{ {40,29},{44,22},{49,28} }
body(ear, R, 4, "ear")
local ear_in = c:poly{ {42,28},{44,25},{46,28} } draw(ear_in, "#e6808a")
local sn = c:ellipse(53, 39, 4, 3)
body(sn, { "#a8505e", "#d27a80", "#ee9c9a", "#f8b8ac", "#fcd0c0", "#fde8d4" }, 3, "snout")
dot(52, 39, "#7a3040") dot(54, 39, "#7a3040")
-- eye + blush
c:put(46, 33, "#2a1620", T) c:put(46, 34, "#2a1620", T) c:put(47, 33, "#2a1620", T) c:put(47, 34, "#2a1620", T) dot(46, 33, "#fff4e0")
for _, p in ipairs{ {43,38},{44,38},{43,39},{44,39},{45,38} } do dot(p[1], p[2], "#e8707c") end
-- crimped fork marks across the back
bd:each(function(x, y) if y < 33 and (x % 3 == 0) and (y % 3 == 0) and x < 36 then c:put(x, y, R[2], T) end end)
-- cheek/belly shade line
bd:each(function(x, y) if y >= 48 then c:put(x, y, R[1], T) end end)
-- quirk: clover sprig with a red marzipan cherry on its back
local G1 = { "#1e4a2a", "#2e7a3a", "#58b04c", "#9ce068" }
for _, p in ipairs{ {24,24,-3,-1},{24,24,3,-1},{24,24,0,-4} } do
  local lf = c:ellipse(24 + p[3], 24 + p[4] , 2.3, 2.3)
  body(lf, { G1[1], G1[2], G1[2], G1[3], G1[4], G1[4] }, 2.5, "cl" .. p[3] .. p[4])
end
dot(24, 24, G1[1])
local ch = c:ellipse(30, 25, 2, 2)
body(ch, { "#5a1020", "#8c1a2c", "#c02a38", "#e0504c", "#f08a7a", "#fff0e0" }, 2.4, "cherry")
G.save(c, NAME)
