-- puddle-hat (lean E2_05)
local NAME = "puddle-hat"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function P(x, y, col) c:put(x, y, col) end
local function RC(x0, y0, x1, y1, col) for y = y0, y1 do for x = x0, x1 do P(x, y, col) end end end
local function dome(m, ramp, R, name, o) local n = X.pillow(m, R) local t = { tok = { r = { name = name } }, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.1, wrap = 0.2 } if o then for k, v in pairs(o) do t[k] = v end end G.toneN(c, m, n, ramp, t) return n end
local W = { "#4e4e78", "#7c7ca4", "#aeaecb", "#d4d4e6", "#ecebf4", "#fbfaff" }
local D = { "#3a2418", "#5e3a22", "#8a5a30", "#ae7a40", "#cf9c58", "#e8c07c" }
local WT = { "#1c3a78", "#2c5ca8", "#4a86d4", "#7cb4ee", "#b4dcff", "#e4f6ff" }
local ST = { "#7a4a14", "#b07820", "#d8a030", "#f0c450", "#fadc7c", "#fff0a8" }
local RB = { "#5a0c1c", "#8e1a2c", "#c4303c", "#e85a52" }
-- puddle
local pd = c:ellipse(32, 46, 27, 9)
dome(pd, WT, 14, "puddle", { amb = 0.3, wrap = 0.5 })
pd:each(function(x, y) if (y % 3 == 0) and X.hash(x, y, 4) > 0.55 and y > 40 then P(x, y, WT[4]) end end)
-- ripple rings
for _, r in ipairs{ { 32, 45, 23, 6 }, { 32, 46, 17, 4 } } do
  local rg = c:ellipse(r[1], r[2], r[3], r[4]):edge()
  rg:each(function(x, y) if (x * 2 + y) % 7 < 5 then P(x, y, WT[5]) end end)
end
-- brim floating
local brim = c:ellipse(32, 40, 25, 7)
dome(brim, ST, 11, "brim", { amb = 0.2, wrap = 0.4 })
brim:each(function(x, y) if (x + y) % 4 == 0 then P(x, y, ST[2]) elseif (x - y) % 6 == 0 then P(x, y, ST[4]) end end)
for x = 9, 56 do if brim:has(x, 46) then P(x, 46, ST[1]) end end
-- crown
local cr = c:ellipse(32, 29, 14, 12)
local crm = HP.mask() crm:add(cr) crm:add(c:rect(18, 28, 46, 40))
crm:cut(c:ellipse(32, 41, 40, 2))
dome(crm, ST, 12, "crown", { amb = 0.2, wrap = 0.4 })
crm:each(function(x, y)
  if (x + y) % 4 == 0 then P(x, y, ST[2]) elseif (x - y) % 5 == 0 then P(x, y, ST[5]) end
end)
-- ribbon
for x = 18, 46 do for y = 34, 37 do
  if crm:has(x, y) then local i = (y == 34) and 4 or (y == 37) and 1 or (y == 35) and 3 or 2 P(x, y, RB[i]) end
end end
RC(40, 37, 44, 41, RB[2]) RC(41, 37, 43, 40, RB[3]) P(40, 41, RB[1]) P(44, 42, RB[1]) P(41, 38, RB[4])
-- spec on crown
P(24, 22, ST[6]) P(25, 21, ST[6]) P(26, 20, ST[6]) P(23, 24, ST[6])
-- frog quirk on top
local fg = c:ellipse(30, 15, 5, 3)
G.toneN(c, fg, X.pillow(fg, 3), { "#14502a", "#1f7a3c", "#34a448", "#62cc58", "#a0ea78" }, { tok = { r = { name = "frog" } }, cuts = { .22, .42, .62, .82 } })
RC(26, 17, 27, 18, "#1f7a3c") RC(34, 17, 35, 18, "#1f7a3c")
P(27, 12, "#fff0c0") P(28, 12, "#101018") P(33, 12, "#fff0c0") P(32, 12, "#101018") P(28, 11, "#34a448") P(32, 11, "#34a448")
P(30, 16, "#a82c3c") P(31, 16, "#a82c3c") P(29, 14, "#a0ea78")
-- tiny leaf floating
RC(52, 49, 54, 50, "#58a448") P(55, 50, "#215c36") P(52, 49, "#bfe88a")
G.save(c, NAME)
