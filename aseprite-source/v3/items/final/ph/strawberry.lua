-- strawberry (lean D2o_15)
-- Plump heart-cone berry, glossy red with yellow seed pits, five-point leafy calyx and curled stem.
-- quirk: a neat bite is gone from the lower right showing pale pink flesh.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "strawberry" }
local function shade(m, R, ramp, o) o = o or {}
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  G.tone(c, m, v, ramp, o.cuts, o.bias, o.tok)
  return n, v
end
local function inter(a, b) local m = HP.mask() a:each(function(x, y) if b:has(x, y) then m:set(x, y) end end) return m end
local RED  = { "#4a1022", "#7a1a2c", "#b02a30", "#d9453a", "#f06d52", "#ffa882" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local FLESH = { "#a24a52", "#d27a7a", "#efa6a0", "#fbd0c4", "#fff0e0" }
c:groundShadow(32, 56, 12, 2)
local Y0, Y1 = 22, 54
local function hw(y) local t = (y - Y0) / (Y1 - Y0)
  if t < 0.34 then return 15 * sin(min(1, (t + 0.05) / 0.39) * pi / 2) ^ 0.6 end
  return 15 * ((1 - t) / 0.66) ^ 0.8 + 0.6 end
local B = HP.mask()
for y = Y0, Y1 do local h = hw(y) for x = floor(32 - h + 0.5), floor(32 + h - 0.5) do B:set(x, y) end end
local bite = c:ellipse(46, 44, 5, 5) bite:add(c:ellipse(43, 51, 4, 3.5)) bite:add(c:ellipse(48, 37, 3.5, 3.5))
local fl = inter(B, bite:copy():grow(2)) fl:cut(bite)
B:cut(bite)
local n, v = shade(B, 11, RED, { amb = 0.05 })
local seedZone = B:copy():shrink(2)
for y = 27, 52, 4 do for x = 14, 52, 5 do
  local xx = x + ((y - 27) / 4 % 2) * 2.5
  xx = floor(xx)
  if seedZone:has(xx, y) and not fl:has(xx, y) and seedZone:has(xx, y + 1) then
    c:px(xx, y, "#f6d25a") c:px(xx, y + 1, "#c88a2a") c:px(xx - 1, y, RED[2])
  end end end
shade(fl, 3, FLESH)
fl:each(function(x, y) if X.hash(x, y, 3) > 0.9 then c:px(x, y, FLESH[5]) end end)
-- spec
c:px(20, 31, "#fff0e0") c:px(21, 31, "#fff0e0") c:px(20, 32, RED[6]) c:px(22, 30, RED[6]) c:px(19, 33, RED[6])
-- calyx
local dirs = { {-1, 0.15}, {-0.7, 0.75}, {0.0, 1}, {0.7, 0.75}, {1, 0.15} }
for _, d in ipairs(dirs) do
  local l = sqrt(d[1]^2 + d[2]^2) local ux, uy = d[1] / l, d[2] / l
  local m = G.rell(32 + ux * 5.5, 23 + uy * 5, ux, uy, 6, 2.2)
  shade(m, 2.5, LEAF, { amb = 0.15 })
  for t = 1, 5 do c:px(floor(32 + ux * t * 1.1 + 0.5), floor(23 + uy * t * 1.0 + 0.5), LEAF[6]) end
end
local sm, sn = G.tube({ {32, 23}, {31, 16}, {35, 11}, {39, 12} }, function(t) return 1.5 - t * 0.6 end)
G.tone(c, sm, X.light(sn, { amb = 0.2, wrap = 0.3 }), LEAF, { 0.2, 0.4, 0.6, 0.78, 0.9 })
c:px(38, 12, LEAF[5]) c:px(39, 13, LEAF[2])
G.fin(c, "strawberry")
