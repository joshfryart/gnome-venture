-- tile-bark-path (lean D3o_2)
-- Seamless bark-mulch path: overlapping curled bark chips on dark loam, ridge lines, moss specks. Quirk: one dropped acorn cap.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "tile-bark-path" }
local floor, abs, sin, cos, max = math.floor, math.abs, math.sin, math.cos, math.max
local BASE = { "#2e1d1f", "#3c2622" }
local BARK = { { "#4a2c24", "#6b4030", "#8f5a3c", "#b27a4c" }, { "#3e2a26", "#5a3a30", "#7c5440", "#9c6e52" }, { "#55321f", "#7a4a2a", "#a2683a", "#c98f55" } }
for y = 0, 63 do for x = 0, 63 do c:put(x, y, BASE[(X.hash(x, y, 3) > 0.7) and 2 or 1]) end end
local function chip(cx, cy, ang, L, W, pal)
  local ca, sa = cos(ang), sin(ang)
  local R = floor(L) + 2
  for dy = -R, R do for dx = -R, R do
    local u = dx * ca + dy * sa
    local w = -dx * sa + dy * ca
    local curl = 0.12 * u * u / L
    local ww = w - curl
    if (abs(u) / L) ^ 3 + (abs(ww) / W) ^ 2 <= 1 then
      local x, y = (floor(cx) + dx) % 64, (floor(cy) + dy) % 64
      local t = ww / W
      local i = 3
      if t < -0.45 then i = 4 elseif t > 0.55 then i = 1 elseif t > 0.15 then i = 2 end
      if abs(ww) < 0.5 and abs(u) < L - 1 then i = 1 end            -- ridge
      if (abs(u) / L) ^ 3 + (abs(ww) / W) ^ 2 > 0.72 and t > 0 then i = 1 end   -- rim shade lower side
      if X.hash(x, y, 9) > 0.9 then i = max(1, i - 1) end
      c:put(x, y, pal[i])
    end
  end end
end
local n = 0
for gy = 0, 7 do for gx = 0, 7 do
  local h1, h2, h3 = X.hash(gx, gy, 21), X.hash(gx, gy, 22), X.hash(gx, gy, 23)
  chip(gx * 8 + 2 + h1 * 6, gy * 8 + 2 + h2 * 6, h3 * 3.14, 4 + h1 * 3, 1.8 + h2 * 1.4, BARK[1 + floor(h3 * 3 * 0.999)])
end end
-- moss specks and splinters
for i = 1, 14 do
  local x, y = floor(X.hash(i, 1, 31) * 64), floor(X.hash(i, 2, 31) * 64)
  c:put(x, y, "#5e8a4a") c:put((x + 1) % 64, y, "#7fae5a")
end
for i = 1, 10 do
  local x, y = floor(X.hash(i, 3, 41) * 64), floor(X.hash(i, 4, 41) * 64)
  c:put(x, y, "#d8aa72") c:put((x + 1) % 64, (y + 1) % 64, "#d8aa72")
end
-- acorn cap quirk
local ax, ay = 40, 22
for _, p in ipairs{ {0,0,"#7a5430"},{1,0,"#8f6a3c"},{2,0,"#7a5430"},{-1,1,"#5a3a24"},{0,1,"#8f6a3c"},{1,1,"#a2803f"},{2,1,"#8f6a3c"},{3,1,"#5a3a24"},{0,2,"#5a3a24"},{1,2,"#7a5430"},{2,2,"#5a3a24"},{1,-1,"#c9a25a"},{1,3,"#2e1d1f"} } do
  c:put(ax + p[1], ay + p[2], p[3])
end
c:finish{ outline = false }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = G.out .. "tile-bark-path.aseprite", png = G.out .. "tile-bark-path.png", scale = 1 }
