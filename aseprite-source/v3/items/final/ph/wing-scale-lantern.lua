-- wing-scale-lantern (lean D3o_13)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local function blade(ax, ay, cx, cy, bx, by, wf) return (G.tube({ {ax,ay}, {cx,cy}, {cx,cy}, {bx,by} }, wf)) end
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.2, 0.38, 0.55, 0.7, 0.86 }
local WOOD = { "#2e1d1f", "#4b2e2a", "#6e4330", "#93603b", "#b98650", "#dcb36f" }
local COPPER = { "#3a2230", "#6a3a35", "#a05a3a", "#d08a48", "#efb964", "#fff0a8" }
local STONE = { "#2f3040", "#4a4a5e", "#6a6a7c", "#8d8d98", "#b2b0b4", "#d8d4d0" }
local LEAF = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
local function sh(c, m, ramp, R, amb) local n = X.pillow(m, R or 3) G.tone(c, m, X.light(n, { amb = amb or 0.1, wrap = 0.25 }), ramp, CUTS) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "wing-scale-lantern" }
local GLOW = { "#7a3a8a", "#b0509a", "#e0709a", "#f8a07a", "#ffd080", "#fff6c0" }
-- hanging hook + ring
G.line(c, { {32,3}, {32,8} }, "#cfd6e0") c:px(31, 3, "#cfd6e0") c:px(33, 3, "#7d8aa0") c:px(32, 2, "#7d8aa0")
-- crown cap: hexagon lid
local cap = c:poly{ {32,8}, {44,14}, {47,17}, {17,17}, {20,14} }
sh(c, cap, COPPER, 4)
-- body: hexagonal glass (wide in middle)
local body = c:poly{ {19,17}, {45,17}, {49,31}, {44,46}, {20,46}, {15,31} }
local bn = X.pillow(body, 10)
local bv = X.light(bn, { amb = 0.3, wrap = 0.4 })
G.tone(c, body, bv, GLOW, { 0.15, 0.3, 0.45, 0.62, 0.8 })
-- overlapping scales (little arcs) inside as glow
for row = 0, 5 do
  for col = 0, 5 do
    local cx = 20 + col * 5 + (row % 2) * 2.5
    local cy = 21 + row * 4.5
    if body:has(floor(cx), floor(cy)) and body:has(floor(cx), floor(cy) + 2) then
      for dx = -2, 2 do
        local dy = floor(2.4 - abs(dx) * 0.9 + 0.5)
        local x, y = floor(cx) + dx, floor(cy) + dy
        if body:has(x, y) then c:px(x, y, row % 2 == 0 and "#7a2e6a" or "#a8405a") end
      end
      c:px(floor(cx), floor(cy), "#fff0b0")
    end
  end
end
-- copper ribs
for _, p in ipairs{ {{19,17},{15,31},{20,46}}, {{45,17},{49,31},{44,46}}, {{32,17},{32,46}} } do G.line(c, p, COPPER[3]) end
G.line(c, { {17,17}, {47,17} }, COPPER[5])
-- glass glint
G.line(c, { {21,21}, {18,29} }, "#fff6f2") c:px(22, 20, "#fff6f2")
-- base cap
local base = c:poly{ {20,46}, {44,46}, {40,51}, {24,51} }
sh(c, base, COPPER, 3)
-- tiny feet + tassel of dust-scale (quirk: dangling scale charm)
G.line(c, { {32,51}, {32,56} }, "#cfd6e0")
local ch = blade(32, 55, 32, 59, 32, 62, function(t) return 3 * sin(pi * t) ^ 0.7 end)
G.tone(c, ch, X.light(X.pillow(ch, 2), { amb = 0.2, wrap = 0.3 }), GLOW, CUTS)
G.fin(c, "wing-scale-lantern")
