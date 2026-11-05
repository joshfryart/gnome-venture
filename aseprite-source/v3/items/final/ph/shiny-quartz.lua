-- shiny-quartz (lean P1b_O8)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt

local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "shiny-quartz" }
local ICE = { "#3a3f86", "#5a6cc0", "#86a0e4", "#b4ccf6", "#dcecff", "#f2f6ff" }
local VIO = { "#2a2468", "#4a3d94", "#6c62c0", "#9a90e0" }
local ROCK = { "#1e1626", "#34283e", "#503e5a", "#745c76", "#9a7e90" }
c:groundShadow(32, 56, 24, 3)
-- rock base
local rk = HP.mask() rk:add(c:ellipse(32, 52, 24, 7))
rk:add(c:ellipse(20, 49, 9, 5)) rk:add(c:ellipse(45, 50, 9, 5))
G.toneN(c, rk, X.pillow(rk, 10), ROCK, { amb = 0.1, wrap = 0.2 })
for _, p in ipairs{ {14,50},{22,55},{30,56},{40,55},{50,52},{36,51} } do c:px(p[1], p[2], ROCK[1]) c:px(p[1] - 1, p[2] - 1, ROCK[5]) end
-- crystal: bx,by base center; w half-width; h body height; tip height; lean dx at the top
local function crystal(bx, by, w, h, tip, lean)
  local topy = by - h
  local function X0(y) return lean * (by - y) / (h + tip) end
  local lx, rx, mx = bx - w, bx + w, bx - w + w * 0.7
  local L = HP.mask() L:add(c:poly{ {lx, by}, {mx, by}, {mx + lean * h / (h + tip), topy}, {lx + lean * h / (h + tip), topy} })
  local R = HP.mask() R:add(c:poly{ {mx, by}, {rx, by}, {rx + lean * h / (h + tip), topy}, {mx + lean * h / (h + tip), topy} })
  local tl = HP.mask() tl:add(c:poly{ {lx + lean * h / (h + tip), topy}, {mx + lean * h / (h + tip), topy}, {bx + lean, topy - tip} })
  local tr = HP.mask() tr:add(c:poly{ {mx + lean * h / (h + tip), topy}, {rx + lean * h / (h + tip), topy}, {bx + lean, topy - tip} })
  c:fillMask(L, ICE[4]) c:fillMask(R, ICE[2]) c:fillMask(tl, ICE[5]) c:fillMask(tr, ICE[3])
  -- gradient: lower body darker toward violet
  L:each(function(x, y) if y > by - h * 0.3 then c:px(x, y, ICE[3]) end if y > by - h * 0.12 then c:px(x, y, ICE[2]) end end)
  R:each(function(x, y) if y > by - h * 0.4 then c:px(x, y, ICE[1 + 0]) end if y > by - h * 0.7 and y <= by - h * 0.4 then c:px(x, y, ICE[2]) end end)
  -- facet edges and glints
  local ex = floor(mx + 0.5)
  for y = topy, by do local xx = floor(ex + lean * (by - y) / (h + tip) * -1 + lean * h / (h + tip) * 0 + 0.5) end
  -- bright edge on the left face
  for y = topy + 2, by - 4 do c:px(floor(lx + 1 + lean * (h - (y - topy)) / (h + tip) * 0 + lean * (by - y) / (h + tip) * 0) + 0, y, ICE[6]) end
  -- facet ridge between faces
  for y = topy, by do
    local xr = floor(mx + lean * (by - y) / h * (h / (h + tip)) * 0 + 0.5)
  end
  return L, R, tl, tr
end
-- big centre, left and right
crystal(30, 52, 8, 26, 14, 0)
crystal(15, 50, 5.5, 14, 9, -3)
crystal(47, 51, 6, 17, 10, 4)
-- bright left-edge lines to read as bevel
for y = 15, 46 do c:px(23, y, ICE[6]) end
for y = 30, 46 do c:px(10, y, ICE[6]) end
for y = 30, 46 do c:px(42, y, ICE[6]) end
-- facet ridges
for y = 12, 52 do c:px(35, y, ICE[3]) end
for y = 34, 50 do c:px(19, y, ICE[3]) end
for y = 34, 50 do c:px(51, y, ICE[3]) end
-- quirk: rainbow inclusion crack inside the big crystal
for i, col in ipairs{ "#ff7ab0", "#ffd84a", "#6ae0b0", "#6ab0ff" } do
  c:px(27 + i, 36 - i, col)
  c:px(26 + i, 37 - i, col == "#ffd84a" and "#ffeea0" or col)
end
c:sparkle(24, 12) c:sparkle(14, 30)
G.save(c, "shiny-quartz")
