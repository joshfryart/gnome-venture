-- wind-harp (lean W2_39)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "wind-harp" }
local sin, pi, abs, floor = math.sin, math.pi, math.abs, math.floor
local WOOD = { "#3a2113", "#5c3519", "#84501f", "#aa6f2c", "#cf9444", "#efbc6a" }
local BRS  = { "#5a3410", "#8a5516", "#b9791f", "#e0a032", "#f5c957", "#fff0a0" }
local tk = { r = { name = "x" } }
-- curved neck (left arm up and over) + pillar
local neck, nn = G.tube({ {14, 44}, {12, 28}, {22, 12}, {43, 11} }, function(t) return 2.2 end)
G.toneN(c, neck, nn, WOOD, { tok = tk })
local pil = c:rrect(40, 9, 45, 47, 1)
local pn = X.pillow(pil, 3)
G.toneN(c, pil, pn, WOOD, { tok = tk })
pil:each(function(x, y) if x == 42 and X.hash(x, y, 7) > 0.55 then c:px(x, y, WOOD[2]) end end)
-- soundbox
local box = c:rrect(10, 43, 47, 52, 2)
G.toneN(c, box, X.pillow(box, 5), WOOD, { tok = tk })
box:each(function(x, y) if y == 47 and x % 5 ~= 0 and X.hash(x, y, 2) > 0.5 then c:px(x, y, WOOD[3]) end end)
local hole = c:ellipse(28, 48, 4, 2)
c:fillMask(hole, WOOD[1]) for x = 25, 31 do c:px(x, 49, "#1a0e08") end
-- strings
local STR = { "#fff3d0", "#e3d3a2" }
for i, x in ipairs{ 18, 21, 24, 27, 30, 33, 36 } do
  local top
  for y = 8, 43 do if neck:has(x, y) then top = y end end
  if top then
    c:px(x, top, BRS[4]) -- peg
    for y = top + 1, 42 do
      local dx = 0
      if x == 27 then dx = floor(1.6 * sin((y - top) * 0.55) + 0.5) end   -- quirk: one string mid-hum
      c:px(x + dx, y, x == 27 and "#fff8dc" or STR[(i % 2) + 1])
    end
  end
end
c:sparkle(34, 30)
c:px(15, 46, BRS[4]) c:px(15, 47, BRS[2])
G.save(c, "wind-harp")
