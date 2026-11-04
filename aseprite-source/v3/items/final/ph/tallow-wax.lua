-- tallow-wax (lean W2_32)
-- A fat tallow candle slumped on a tin saucer, lit, with runny drips and a fallen drop; quirk: someone's thumbprint pressed in the soft wax.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "tallow-wax" }
local sin, floor = math.sin, math.floor
local WAX = { "#6e5a7a", "#a2907f", "#cfbea4", "#ecdfc2", "#f8eed4", "#fffbea" }
local TIN = { "#34344e", "#545674", "#7a7e9c", "#a2a8c0", "#c8cde0", "#eef0f8" }
local function shade(m, ramp, R, o, bias)
  local n = X.pillow(m, R)
  G.tone(c, m, X.light(n, o or { amb = 0.1, wrap = 0.3 }), ramp, nil, bias)
  return n
end
c:groundShadow(32, 58, 18, 2)
-- saucer
shade(c:ellipse(32, 53, 18, 4.5), TIN, 4)
c:fillMask(c:ellipse(32, 52, 14, 3), TIN[2])
c:fillMask(c:ellipse(32, 52, 12, 2), WAX[3])
c:fillMask(c:ellipse(30, 52, 9, 1), WAX[4])
for x = 17, 22 do c:px(x, 51, TIN[6]) end
-- body, slumping wider toward the base
local body = HP.mask()
for y = 22, 52 do
  local h = 5.4 + 0.6 * sin(y * 0.5) + ((y > 42) and (y - 42) * 0.32 or 0)
  for x = floor(32 - h + 0.5), floor(32 + h - 0.5) do body:set(x, y) end
end
local n = shade(body, WAX, 5.5, { amb = 0.08, wrap = 0.25 })
-- melted top pool
c:fillMask(c:ellipse(32, 22, 6.5, 2.3), WAX[2])
c:fillMask(c:ellipse(32, 22, 5, 1.6), WAX[4])
c:fillMask(c:ellipse(31, 22, 3, 0.8), WAX[6])
-- drips
local function drip(x, y0, y1, r)
  local m = G.rell(x, (y0 + y1) / 2, 0, 1, (y1 - y0) / 2, r):add(G.rell(x, y1 + 0.5, 0, 1, r + 0.9, r + 0.9))
  m:each(function(px, py) if body:has(px + 1, py) and not m:has(px + 1, py) then c:px(px + 1, py, WAX[2]) end end)
  shade(m, WAX, 1.6, { amb = 0.2, wrap = 0.3 })
  c:px(x - 1, y0 + 2, WAX[6])
end
drip(27, 22, 34, 1.4) drip(37, 22, 30, 1.2) drip(32, 23, 41, 1.7)
-- thumbprint (quirk)
c:ellipse(27, 44, 3, 2.4):edge():each(function(x, y) c:px(x, y, WAX[2]) end)
c:ellipse(27, 44, 1.4, 1):edge():each(function(x, y) c:px(x, y, WAX[3]) end)
-- sheen streak
for y = 26, 48 do if y % 5 ~= 0 and not (y > 31 and y < 40 and false) then c:px(25, y, WAX[6]) end end
-- fallen drop on the saucer
shade(c:ellipse(44, 52, 2.5, 1.2), WAX, 1.5)
c:px(43, 51, WAX[6])
-- wick and flame
G.line(c, { { 32, 22 }, { 32, 19 }, { 33, 16 } }, "#4a3a40")
c:fillMask(c:ellipse(33, 12.5, 2.4, 3.6), "#f0802a")
c:fillMask(c:ellipse(33, 13, 1.4, 2.4), "#ffd860")
c:px(33, 14, "#fffbe0") c:px(33, 13, "#fffbe0") c:px(33, 8, "#f0802a")
G.fin(c, "tallow-wax")
