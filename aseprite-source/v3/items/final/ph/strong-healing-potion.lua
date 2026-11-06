-- strong-healing-potion (lean D2o_15)
-- Conical (Erlenmeyer) flask of glowing crimson-rose elixir, red wax seal over the cork with a drip,
-- bright core glow near the base. quirk: a heart-shaped bubble floats up through the liquid.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "strong-healing-potion" }
local function shade(m, R, ramp, o) o = o or {}
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  G.tone(c, m, v, ramp, o.cuts, o.bias, o.tok)
  return n, v
end
local function inter(a, b) local m = HP.mask() a:each(function(x, y) if b:has(x, y) then m:set(x, y) end end) return m end
local GLASS = { "#4a5878", "#6f84a8", "#9fb4d0", "#c9d8ea", "#e8f0f8", "#f6fbff" }
local ELX = { "#4a0a2a", "#8a1238", "#c4204a", "#e84862", "#ff7a86", "#ffc0c0" }
local WAX = { "#5a0f18", "#8a1a22", "#b82a30", "#da4a44", "#f0786a" }
c:groundShadow(32, 56, 17, 2)
local function hw(y)
  if y < 27 then return 3.5 end
  local t = (y - 27) / 25
  local h = 3.5 + 13.5 * t ^ 0.85
  if y >= 50 then h = h - (y - 49) * (y - 49) * 0.55 end
  return h end
local g = HP.mask()
for y = 15, 53 do local h = hw(y) for x = floor(32 - h + 0.5), floor(32 + h - 0.5) do g:set(x, y) end end
g:add(c:rrect(27, 13, 37, 16, 1))
shade(g, 7, GLASS)
local liq = g:copy():shrink(2) liq:cut(c:rect(0, 0, 63, 31))
local n, v = shade(liq, 9, ELX, { amb = 0.08 })
liq:each(function(x, y) if y == 32 then c:px(x, y, ELX[6]) end
  if y > 44 and abs(x - 32) < 8 and X.hash(x, y, 2) > 0.5 then c:px(x, y, ELX[5]) end end)
-- heart bubble
local H = { {38, 40}, {40, 40}, {37, 41}, {38, 41}, {39, 41}, {40, 41}, {41, 41}, {38, 42}, {39, 42}, {40, 42}, {39, 43} }
for _, p in ipairs(H) do c:px(p[1], p[2], ELX[6]) end
c:px(24, 46, ELX[5]) c:px(26, 40, ELX[5]) c:px(25, 47, ELX[6])
-- glass streaks
for y = 38, 48 do c:px(32 - floor(hw(y)) + 3, y, GLASS[5]) end
c:px(32 - floor(hw(37)) + 3, 37, GLASS[6])
for y = 17, 26 do c:px(29, y, GLASS[5]) end
for x = 28, 36 do c:px(x, 13, GLASS[4]) end
-- cork + wax seal with drip
local ck = c:rect(29, 8, 35, 13)
shade(ck, 3, { "#5a3a22", "#7e5232", "#a2733f", "#c79a5c", "#e0bf86" })
local wx = c:rrect(27, 11, 37, 17, 1) wx:add(c:rect(35, 17, 36, 21)) wx:add(c:ellipse(35.5, 22, 1.8, 1.8))
shade(wx, 3, WAX)
c:px(29, 12, WAX[5]) c:px(30, 12, WAX[5])
G.fin(c, "strong-healing-potion")
