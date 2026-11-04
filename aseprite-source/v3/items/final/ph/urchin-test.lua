-- urchin-test (lean D3o_8)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan

local c = HP.canvas{ w=64, h=64, scale=1, name="urchin-test" }
local SH = { "#5a3d63", "#8a6486", "#b78fa6", "#dcb8bb", "#f3dccb", "#fff2e2" }
c:groundShadow(33, 56, 17, 3)
local body = c:ellipse(32, 31, 21, 20)
local n = X.pillow(body, 16)
local v = X.light(n, { amb = 0.1, wrap = 0.25 })
local bias = {}
local tub = {}
body:each(function(x, y)
  local dx, dy = x - 32, y - 31
  local r = sqrt(dx*dx + dy*dy)
  local a = atan(dy, dx)
  local k = K(x, y)
  -- five bands (pore columns), pore pairs along them
  local s = ((a + pi/2) / (2*pi/5)) % 1      -- 0 = band axis
  local off = min(s, 1 - s) * 2*pi/5 * r
  if r > 4 and off < 1.4 then bias[k] = -1 end
  if r > 4 and off < 0.6 and floor(r) % 3 == 0 then bias[k] = -2 end
end)
G.tone(c, body, v, SH, { 0.2, 0.38, 0.54, 0.7, 0.86 }, bias)
-- tubercles in interambulacral rows
for i = 0, 4 do
  local ba = -pi/2 + (i + 0.5) * 2*pi/5
  for _, r in ipairs{ 7, 11, 15, 18.5 } do
    for _, d in ipairs{ -0.16, 0.16 } do
      local a = ba + d * (r < 8 and 2 or 1) * (1 + (r-7)/20)
      local x, y = floor(32 + cos(a) * r + 0.5), floor(31 + sin(a) * r + 0.5)
      if body:has(x+1, y+1) and body:has(x, y) then
        c:px(x, y, SH[6]) c:px(x+1, y, SH[4]) c:px(x, y+1, SH[3]) c:px(x+1, y+1, SH[1])
      end
    end
  end
end
-- apical ring + hole
c:fillMask(c:ellipse(32, 31, 3, 3), SH[2])
c:fillMask(c:ellipse(32, 31, 1, 1), SH[1])
for i = 0, 4 do local a = -pi/2 + i * 2*pi/5 c:px(floor(32 + cos(a)*3.4 + 0.5), floor(31 + sin(a)*3.4 + 0.5), "#e0708f") end
-- spec
c:px(21, 18, SH[6]) c:px(22, 18, SH[6]) c:px(20, 19, SH[6]) c:px(23, 17, SH[6])
-- quirk: broken bite at lower-right edge showing the dark hollow
local bite = c:ellipse(47, 44, 4, 3):clip(body)
c:fillMask(bite, SH[1])
c:fillMask(c:ellipse(46, 43, 2, 1):clip(body), "#2b1c26")
c:px(45, 41, SH[5]) c:px(44, 42, SH[5])
G.fin(c, "urchin-test")
