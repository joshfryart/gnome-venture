-- stoneskin-brew (lean D2o_15)
-- Round-bellied flask with a slim neck and cork; slate granite-flecked brew inside pale glass.
-- quirk: a little pebble dangles from the neck on a twine loop.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stoneskin-brew" }
local function shade(m, R, ramp, o) o = o or {}
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  G.tone(c, m, v, ramp, o.cuts, o.bias, o.tok)
  return n, v
end
local function inter(a, b) local m = HP.mask() a:each(function(x, y) if b:has(x, y) then m:set(x, y) end end) return m end
local GLASS = { "#4a5e78", "#6f89a3", "#9fb8cc", "#c9dbe6", "#e8f2f6", "#f4fbff" }
local STONE = { "#2e2f3a", "#4a4d58", "#6b6e78", "#8f9097", "#b4b3b0", "#d6d2c8" }
local CORK  = { "#5a3a22", "#7e5232", "#a2733f", "#c79a5c", "#e0bf86" }
c:groundShadow(32, 54, 14, 2)
local g = c:ellipse(32, 40, 14, 12)
g:add(c:rect(28, 16, 36, 30)) g:add(c:rrect(26, 13, 38, 17, 1))
shade(g, 7, GLASS)
local liq = g:copy():shrink(2) liq:cut(c:rect(0, 0, 63, 27))
local n, v = shade(liq, 9, STONE, { amb = 0.05 })
liq:each(function(x, y) local h = X.hash(x, y, 7)
  if h > 0.88 then c:px(x, y, STONE[min(6, 1 + floor(v[K(x, y)] * 5) + 1)]) elseif h < 0.07 then c:px(x, y, STONE[1]) end
  if y == 28 then c:px(x, y, STONE[5]) end end)
-- glass rim + specular streak + bubble
for y = 33, 46 do c:px(20 + floor((y - 33) * 0.0), y, GLASS[5]) end
for y = 31, 44 do c:px(21 + (y < 36 and 1 or 0), y, GLASS[5]) end
c:px(22, 32, GLASS[6]) c:px(22, 33, GLASS[6])
for x = 27, 37 do c:px(x, 13, GLASS[4]) end
for y = 18, 26 do c:px(29, y, GLASS[5]) end
c:px(40, 46, STONE[5]) c:px(41, 47, STONE[5]) c:px(39, 49, STONE[4])
-- cork
local ck = c:rect(29, 6, 35, 13)
shade(ck, 4, CORK)
for _, p in ipairs{ {30, 8}, {33, 9}, {31, 11}, {34, 7} } do c:px(p[1], p[2], CORK[1]) end
-- twine loop round neck + pebble
G.line(c, { {28, 19}, {32, 21}, {36, 19} }, "#d9b878")
G.line(c, { {36, 19}, {39, 22}, {41, 25} }, "#d9b878")
local pb = c:ellipse(42, 29, 4, 3.5)
shade(pb, 3, STONE)
c:px(41, 27, STONE[6]) c:px(40, 29, STONE[5]) c:px(44, 31, STONE[1])
G.fin(c, "stoneskin-brew")
