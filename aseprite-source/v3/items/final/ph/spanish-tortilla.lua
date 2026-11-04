-- spanish-tortilla (lean D2o_3)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "spanish-tortilla" }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(m, R, ramp, o) o = o or {}
  local n = X.pillow(m, R) local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  G.tone(c, m, v, ramp, o.cuts, o.bias) return v, n end
local function fill(m, hex) c:fillMask(m, hex) end
-- thick golden potato omelette on a white plate, a wedge cut out showing layered potato + onion, olive on top (quirk)
local SAU = { "#8e92b0", "#b4b8cc", "#d6d8e4", "#eceef4", "#fbfbfd" }
local SIDE = { "#5a2e18", "#8a4a22", "#b87430", "#d89a3c", "#ecbc58", "#f8d77c" }
local TOP = { "#a8672a", "#d09638", "#e8bb4c", "#f6d767", "#fbe99a", "#fff4c4" }
c:groundShadow(32, 59, 24, 3)
local plate = c:ellipse(32, 46, 27, 11) shade(plate, 7, SAU, { cuts = { 0.2, 0.4, 0.6, 0.8 } })
fill(c:ellipse(32, 46, 21, 8):cut(c:ellipse(32, 46, 19, 6)), "#c4c8da")
local body = HP.mask() body:add(c:ellipse(32, 29, 19, 9)) body:add(c:ellipse(32, 37, 19, 9)) body:add(c:rect(13, 29, 51, 37))
shade(body, 8, SIDE)
local top = c:ellipse(32, 29, 19, 9)
local v = shade(top, 9, TOP)
top:each(function(x, y) if X.hash(x, y, 5) > 0.88 then c:px(x, y, TOP[1]) end end)
-- cut wedge
local wedge = c:poly{ {33,30}, {53,28}, {50,43}, {44,44} }:clip(body)
local floorM = wedge:copy()
fill(floorM, "#e8bb4c")
local cutface = c:poly{ {33,30}, {44,38}, {44,44}, {33,36} }
fill(cutface, "#f6e08a")
for y = 31, 43 do for x = 33, 44 do if cutface:has(x, y) then
  local k = (y - floor((x - 33) * 0.7)) % 3
  if k == 0 then c:px(x, y, "#e0b248") elseif k == 1 and X.hash(x, y, 2) > 0.7 then c:px(x, y, "#fff2b4") end
end end end
for x = 34, 43 do c:px(x, 36 + floor((x - 34) * 0.7), "#d89a3a") end
c:px(36, 34, "#f4f0e0") c:px(37, 34, "#f4f0e0") c:px(39, 38, "#f4f0e0")
-- olive + pimiento
fill(c:ellipse(22, 27, 3, 2), "#5a7a32") c:px(21, 26, "#a8c46a") c:px(22, 27, "#d6402e") c:px(23, 27, "#8e2a2a") c:px(24, 28, "#2f4a22")
-- glints
c:px(24, 24, "#fffbe0") c:px(25, 24, "#fffbe0") c:px(26, 23, "#fffbe0")
G.fin(c, "spanish-tortilla")
