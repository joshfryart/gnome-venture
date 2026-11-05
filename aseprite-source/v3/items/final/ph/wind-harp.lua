-- wind-harp (lean P1b_O21)
local NAME = "wind-harp"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min, sqrt, sin, cos, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local WD = { "#34200f", "#5a3519", "#8a5328", "#b87a3a", "#dba458", "#f3cc88" }
local BR = { "#6b4a1c", "#a8742a", "#d9a53d", "#f6d56b" }
local SV = { "#58688a", "#9aa9c6", "#d8e4ef", "#f1f6fa" }
local RB = { "#6e1f3a", "#a8324a", "#d9564f", "#f59a73" }
c:groundShadow(32, 55, 24, 2.5)
-- sound box: top face + front face, slight taper
for y = 40, 53 do
  local xl = 9 + floor((y - 40) * 0.18 + 0.5)
  local xr = 55 - floor((y - 40) * 0.18 + 0.5)
  for x = xl, xr do
    local ix
    if y <= 43 then ix = (y == 40) and 6 or ((y == 41) and 5 or 4)
    else
      ix = 3
      if (y + floor(x / 7)) % 4 == 0 and X.hash(x, y, 2) > 0.45 then ix = 2 end
      if X.hash(x, y, 8) > 0.93 then ix = 4 end
      if y == 44 then ix = 2 end
      if y >= 52 then ix = 1 elseif y >= 50 then ix = min(ix, 2) end
    end
    if x - xl == 0 then ix = (y <= 43) and 5 or min(6, ix + 1) elseif xr - x <= 1 then ix = max(1, ix - 1) end
    c:put(x, y, WD[ix])
  end
end
-- sound holes with brass rims
for _, cx in ipairs{ 21, 32, 43 } do
  for y = 45, 50 do for x = cx - 3, cx + 3 do
    local d = sqrt((x - cx)^2 + ((y - 47.5) * 1.15)^2)
    if d <= 3.1 then
      if d > 2.1 then c:put(x, y, (x - cx) + (y - 47.5) < 0 and BR[4] or BR[2]) else c:put(x, y, "#1c0f12") end
    end
  end end
  c:put(cx - 1, 46, "#3a2430")
end
-- bridge
for x = 16, 48 do c:put(x, 41, BR[3]) c:put(x, 42, BR[1]) end
c:put(17, 41, BR[4]) c:put(25, 41, BR[4]) c:put(40, 41, BR[4])
-- posts
for y = 10, 41 do for x = 10, 13 do
  local ix = ({ 5, 4, 3, 2 })[x - 9]
  if X.hash(x, y, 4) > 0.9 then ix = ix - 1 end
  c:put(x, y, WD[ix])
end end
for y = 10, 41 do for x = 51, 54 do
  local ix = ({ 5, 4, 3, 2 })[x - 50]
  if X.hash(x, y, 6) > 0.9 then ix = ix - 1 end
  c:put(x, y, WD[ix])
end end
-- arched top rail
local function ytop(x) return floor(10 - 4 * sin(pi * (x - 10) / 44) + 0.5) end
for x = 10, 54 do
  local y0 = ytop(x)
  for k = 0, 4 do c:put(x, y0 + k, WD[({ 6, 5, 4, 3, 2 })[k + 1]]) end
  if x % 6 == 3 then c:put(x, y0 + 2, WD[2]) end
end
-- strings with pegs; the 4th is vibrating (quirk)
local sx = { 17, 22, 27, 32, 37, 42, 47 }
for i, x in ipairs(sx) do
  local y0 = ytop(x) + 5
  for y = y0, 40 do
    local dx = 0
    if i == 4 then dx = floor(1.4 * sin((y - y0) * 0.55) + (sin((y - y0) * 0.55) > 0 and 0.4 or -0.4)) end
    c:put(x + dx, y, SV[3]) c:put(x + dx + 1, y, SV[1])
    if i == 4 and abs(dx) > 0 then c:put(x - dx, y, SV[2]) end
  end
  c:put(x, y0 - 6 + 0, BR[3]) c:put(x + 1, y0 - 6, BR[1])
  c:put(x, y0 - 7, BR[4]) c:put(x + 1, y0 - 7, BR[2])
  c:put(x, y0 + 8, SV[4])
end
-- finials
for _, x in ipairs{ 11, 52 } do
  for y = 5, 8 do for xx = x, x + 2 do
    local ix = 3
    if xx == x and y < 7 then ix = 4 end
    if xx == x + 2 or y == 8 then ix = 2 end
    if xx == x and y == 5 then ix = 4 end
    c:put(xx, y, BR[ix]) end end
  c:put(x, 5, BR[4])
end
-- ribbon tied to the right finial
for i = 0, 6 do c:put(55 + (i > 0 and 1 or 0), 7 + i // 1 - 0, RB[i % 3 == 0 and 3 or 2]) end
for i = 0, 5 do c:put(54 + (i % 3), 9 + i, RB[3 - (i % 3 == 2 and 1 or 0)]) end
c:put(56, 8, RB[4]) c:put(54, 9, RB[1])
G.save(c, NAME)
