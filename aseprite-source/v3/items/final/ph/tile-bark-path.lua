-- tile-bark-path (lean P1b_O16)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function pick(r, v, cuts) cuts = cuts or {.22,.4,.56,.72,.86} local i = 1 for _, t in ipairs(cuts) do if v > t then i = i + 1 end end return r[min(i, #r)] end

local c = HP.canvas{ w=64, h=64, scale=1, name="tile-bark-path" }
local BARK = { "#2e1c18", "#51301f", "#7b4a2a", "#a46c3a", "#cf9650", "#efc274" }
local MOSS = { "#1c4426", "#34753a", "#68ac46", "#a4d868" }
local X0, X1, Y0, Y1 = 6, 57, 6, 57
local seeds = {}
for j = 0, 3 do for i = 0, 3 do
  seeds[#seeds + 1] = { X0 + (i + 0.5) * 13 + (X.hash(i, j, 1) - 0.5) * 8, Y0 + (j + 0.5) * 13 + (X.hash(i, j, 2) - 0.5) * 8, i + j * 4 }
end end
local tile = c:rrect(X0, Y0, X1, Y1, 5)
tile:each(function(x, y)
  local d1, d2, s1 = 1e9, 1e9, nil
  for _, s in ipairs(seeds) do
    local d = sqrt((x - s[1]) ^ 2 + ((y - s[2]) * 0.8) ^ 2)
    if d < d1 then d2 = d1 d1 = d s1 = s elseif d < d2 then d2 = d end
  end
  if d2 - d1 < 1.7 then c:px(x, y, BARK[1]) return end
  local v = 0.62 + (s1[1] - x) * 0.03 + (s1[2] - y) * 0.03 + (X.hash(s1[3], 0, 9) - 0.5) * 0.3
  if (x + floor(s1[3] * 1.7)) % 4 == 0 and X.hash(x, y, 6) > 0.3 then v = v - 0.22 end
  if d2 - d1 < 3 then v = v - 0.12 end
  c:px(x, y, pick(BARK, v))
end)
-- moss in gaps
for _, p in ipairs{ {15,14}, {16,14}, {16,15}, {40,12}, {41,12}, {41,13}, {22,34}, {23,34}, {50,38}, {50,39}, {49,39}, {35,50}, {36,50}, {14,48}, {13,48}, {13,49} } do
  c:px(p[1], p[2], MOSS[(p[1] + p[2]) % 3 + 1])
end
-- quirk: a tiny mushroom
for _, p in ipairs{ {44,46,"#e2c8a8"}, {44,47,"#e2c8a8"}, {43,45,"#d8403a"}, {44,45,"#d8403a"}, {45,45,"#d8403a"}, {44,44,"#ee6a58"}, {43,44,"#ee6a58"}, {45,44,"#a82a30"}, {44,43,"#d8403a"} } do c:px(p[1], p[2], p[3]) end
c:px(43, 44, "#fff0e0")
G.save(c, "tile-bark-path")
