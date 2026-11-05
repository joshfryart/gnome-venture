-- strawberry (lean P1b_O15)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local H = X.hash
local NAME = "strawberry"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local RED = { "#4b0f2a", "#7d1530", "#b01f33", "#d93a3a", "#f06a4c", "#ff9b6e" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
c:groundShadow(32, 55, 15, 2)
local Y0, Y1 = 22, 55
local function hw(y)
  local t = (y - Y0) / (Y1 - Y0)
  if t < 0.35 then return 17.5 * sin(min(1, (t + 0.04) / 0.39) * pi / 2) ^ 0.55 end
  return 17.5 * ((1 - t) / 0.65) ^ 0.85 + 0.4
end
local berry = HP.mask()
for y = Y0, Y1 do local h = hw(y) for x = floor(32 - h + 0.5), floor(32 + h - 0.5) do berry:set(x, y) end end
local n = X.pillow(berry, 10)
local idx, v = G.toneN(c, berry, n, RED, { amb = 0.08, wrap = 0.25 })
-- cool-warm bounce on lower right rim
local rim = X.rim(n)
berry:edge():each(function(x, y) if rim[K(x, y)] > 0.75 and y > 36 then c:px(x, y, "#c0506a") end end)
-- seeds on a staggered lattice
local inner = berry:copy():shrink(2)
for row = 0, 8 do
  local y = 29 + row * 3.4
  for col = -4, 4 do
    local x = 32 + col * 4.4 + ((row % 2) * 2.2) - 1.1 + ((y - 29) * -0.0)
    local xi, yi = floor(x + 0.5), floor(y + 0.5)
    if inner:has(xi, yi) and inner:has(xi, yi + 1) and inner:has(xi + 1, yi) then
      c:put(xi + 1, yi + 1, RED[2])
      c:put(xi, yi, "#ffe58a") c:put(xi, yi + 1, "#d9a63a")
    end
  end
end
-- glossy highlight + dew drop (quirk)
local sx, sy = G.specAt(berry, n, 30)
for _, p in ipairs{ {sx,sy},{sx+1,sy},{sx,sy+1},{sx+2,sy+2} } do c:put(p[1], p[2], "#fff1e0") end
c:put(sx - 1, sy + 3, RED[6]) c:put(sx - 1, sy + 4, RED[6])
local drop = c:ellipse(39, 42, 2, 3)
local DR = { "#4f6fa8", "#86b2d6", "#c4e4f2" }
drop:each(function(x, y) c:put(x, y, (x >= 40 and y >= 43) and DR[1] or (x <= 38 and y <= 41) and DR[3] or DR[2]) end)
c:put(38, 40, "#fffdf5")
-- calyx leaves
local function leaf(cx, cy, rx, ry, ang)
  local m, nn = G.oval(cx, cy, rx, ry, ang, 1.2)
  G.toneN(c, m, nn, LEAF, { amb = 0.1, wrap = 0.3 })
  local ca, sa = cos(ang), sin(ang)
  for t = -rx + 1, rx - 1.5, 1 do c:put(floor(cx + ca * t + 0.5), floor(cy + sa * t + 0.5), LEAF[5]) end
  return m
end
leaf(21, 25, 8, 3.2, 0.25) leaf(43, 25, 8, 3.2, -0.25)
leaf(25, 30, 6.5, 2.8, 0.85) leaf(39, 30, 6.5, 2.8, -0.85)
leaf(32, 21, 5.5, 3, 1.57)
local sm, sn = G.tube({ {32, 25}, {32, 20}, {33, 15}, {36, 11} }, function(t) return 1.7 - 0.5 * t end)
G.toneN(c, sm, sn, LEAF, { amb = 0.15, wrap = 0.3 })
c:fillMask(c:rect(31, 24, 33, 25), LEAF[1])
G.save(c, NAME)
