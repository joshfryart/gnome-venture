-- salted-eggs (lean W2_16)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function cyl(m, cx, hw) local n = {} m:each(function(x, y) local nx = max(-0.97, min(0.97, (x - cx) / hw)); n[K(x, y)] = { nx, -0.1, sqrt(1 - nx * nx) } end) return n end
local function shade(c, m, n, ramp, bias, amb) G.tone(c, m, X.light(n, { amb = amb or 0.1, wrap = 0.25 }), ramp, nil, bias) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "salted-eggs" }
c:groundShadow(32, 55, 19, 3)
local TC = { "#4a2418", "#6e3a22", "#9a5530", "#c27a42", "#e0a064", "#f2c88a" }
local EG = { "#4f6a74", "#7a9aa2", "#a4c0bc", "#c8dcd2", "#e4f0e6", "#f8fff6" }
local SA = { "#6c7aa0", "#98a6c4", "#c4cee0", "#e4eaf2", "#f6f9fc", "#f8fbff" }
local YO = { "#7a2a10", "#b0420e", "#d8681a", "#f08c28", "#ffb348", "#ffd890" }
-- eggs behind
for _, e in ipairs{ { 24, 24, 0.0, 9, 6.5 }, { 36, 22, 0.3, 9.5, 6.8 } } do
  local ux, uy = -sin(e[3]), -cos(e[3])
  local m = G.rell(e[1], e[2], ux, uy, e[4], e[5])
  shade(c, m, X.pillow(m, 6), EG, nil, 0.1)
  m:each(function(x, y) local h = X.hash(x, y, 5) if h > 0.9 and X.pillow(m, 6)[K(x, y)][3] > 0.5 then c:px(x, y, SA[5]) end end)
  c:px(floor(e[1] - 3), floor(e[2] - 4), EG[6])
end
-- crock
local cr = c:rrect(14, 38, 50, 53, 5)
shade(c, cr, cyl(cr, 32, 18), TC)
for x = 16, 48 do if x % 5 ~= 0 then c:px(x, 46, TC[2]) end end
local rim = c:rrect(12, 35, 52, 40, 2)
shade(c, rim, cyl(rim, 32, 20), TC)
for x = 14, 50 do c:px(x, 40, TC[1]) end
c:px(17, 36, TC[6]) c:px(18, 36, TC[6])
-- salt mound
local mound = c:ellipse(32, 35, 17, 6):add(c:ellipse(32, 33, 11, 6))
mound:cut(c:rect(0, 38, 63, 63))
local bias = {}
mound:each(function(x, y) local h = X.hash(x, y, 3) if h > 0.78 then bias[K(x, y)] = 1 elseif h < 0.12 then bias[K(x, y)] = -1 end end)
shade(c, mound, X.pillow(mound, 5), SA, bias, 0.2)
-- halved egg with yolk (quirk)
local hf = c:ellipse(39, 34, 8, 5)
shade(c, hf, X.pillow(hf, 4), { "#9a9a8c", "#c4c4b4", "#e4e4d2", "#f4f4e6", "#fcfcf0", "#f8fbff" }, nil, 0.2)
local yk = c:ellipse(39, 34, 4, 3)
shade(c, yk, X.pillow(yk, 3), YO)
c:px(38, 33, YO[6]) c:px(37, 33, YO[5])
G.fin(c, "salted-eggs")
