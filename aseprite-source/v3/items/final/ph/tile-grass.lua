-- tile-grass (lean D3o_2)
-- Seamless meadow turf: wrapped value-noise patches in four greens, upright blade tufts with pale tips, clover trios, a few seed-heads. Quirk: one tiny daisy.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "tile-grass" }
local floor = math.floor
local GR = { "#3f7a3e", "#5a9a48", "#76b455", "#97cc66" }
local CELL = 8
local function vn(x, y)
  local gx, gy = x / CELL, y / CELL
  local x0, y0 = floor(gx), floor(gy)
  local fx, fy = gx - x0, gy - y0
  fx, fy = fx * fx * (3 - 2 * fx), fy * fy * (3 - 2 * fy)
  local function h(a, b) return X.hash(a % 8, b % 8, 55) end
  local top = h(x0, y0) * (1 - fx) + h(x0 + 1, y0) * fx
  local bot = h(x0, y0 + 1) * (1 - fx) + h(x0 + 1, y0 + 1) * fx
  return top * (1 - fy) + bot * fy
end
for y = 0, 63 do for x = 0, 63 do
  local v = vn(x, y) * 0.8 + X.hash(x, y, 2) * 0.2
  local i = v < 0.34 and 1 or (v < 0.55 and 2 or (v < 0.72 and 3 or 4))
  if i == 1 and X.hash(x, y, 6) > 0.5 then i = 2 end
  c:put(x, y, GR[i])
end end
local function P(x, y, col) c:put(x % 64, y % 64, col) end
local function tuft(x, y, h)
  P(x, y, GR[1]) P(x, y - 1, GR[1]) P(x, y - 2, GR[2]) P(x, y - 3, GR[4])
  P(x - 1, y, GR[1]) P(x - 2, y - 1, GR[2]) P(x - 2, y - 2, GR[4])
  P(x + 1, y, GR[1]) P(x + 2, y - 1, GR[2]) P(x + 2, y - 2, GR[3]) P(x + 2, y - 3, GR[4])
  if h then P(x, y - 4, GR[4]) end
end
for i = 1, 11 do tuft(floor(X.hash(i, 1, 61) * 64), floor(X.hash(i, 2, 61) * 64), i % 3 == 0) end
for i = 1, 14 do
  local x, y = floor(X.hash(i, 5, 71) * 64), floor(X.hash(i, 6, 71) * 64)
  P(x, y, GR[1]) P(x + 1, y, GR[1])
end
local function clover(x, y)
  for _, d in ipairs{ {-1,0},{1,0},{0,-1} } do
    P(x + d[1], y + d[2], "#2f6a3c") P(x + d[1] * 2, y + d[2] * 2, "#4c9a50") P(x + d[1], y + d[2] - (d[2] == 0 and 1 or 0), "#6ac06a")
  end
  P(x, y, "#2f5a34") P(x, y + 1, "#2f5a34")
end
clover(12, 46) clover(50, 14) clover(34, 58) clover(22, 10)
-- seed-head stalks
for _, s in ipairs{ {44,40},{6,22} } do
  for k = 0, 4 do P(s[1], s[2] - k, GR[1]) end
  P(s[1] - 1, s[2] - 5, "#c6c478") P(s[1], s[2] - 5, "#e2dc90") P(s[1] + 1, s[2] - 6, "#c6c478") P(s[1], s[2] - 6, "#e2dc90")
end
-- daisy quirk
local dx, dy = 28, 30
for _, d in ipairs{ {-2,0},{2,0},{0,-2},{0,2},{-1,-1},{1,-1},{-1,1},{1,1} } do P(dx + d[1], dy + d[2], "#f7f0e6") end
P(dx, dy, "#f2c14a") P(dx + 1, dy, "#e0a030") P(dx - 2, dy, "#d8d0d8") P(dx, dy + 2, "#d8d0d8")
c:finish{ outline = false }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = G.out .. "tile-grass.aseprite", png = G.out .. "tile-grass.png", scale = 1 }
