-- trek-drained: a drained pool, mud basin with the last sheen of water and rim cracks (family 3)
local ROOT = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(ROOT .. "gvlib/gvlib.lua")
local OUT = ROOT .. "trek-pixel/"
local NAME = "trek-drained"

local mud_base, mud_shade, soil900, so_bounce = "#7a4a1f", "#5c3520", "#3d2a1c", "#8b5a31"
local wa = { gloss = "#c8ecdc", rim = "#a9d6ea", base = "#3f8fb0", shade = "#25637d" }

local c = GV.canvas{ w = 42, h = 42, mode = "scene" }
c:fill(c:rect(0, 0, 41, 41), mud_base)

-- Basin: irregular blob inside x8..33, y9..28 (lobed so it reads as a dried-out puddle shape)
local basin = c:ellipse(19.5, 18.5, 11.5, 8.5)          -- x8..31, y10..27
basin:add(c:ellipse(26, 15, 7, 5.5))                     -- upper-right lobe to x33, y9
basin:add(c:ellipse(15, 23, 7, 5))                       -- lower-left lobe to y28
basin:cut(c:ellipse(9, 11, 2.5, 2.5))                    -- bite at the upper-left
basin:cut(c:ellipse(33, 27, 3, 3))                       -- bite at the lower-right
basin:clip(c:rect(8, 9, 33, 28))
basin = basin:closed(1)
c:fill(basin, mud_shade)
-- lit lip: basin edge pixels on the upper-left side only
basin:each(function(x, y)
  local edgeUL = (not basin:has(x - 1, y)) or (not basin:has(x, y - 1))
  if edgeUL and (x - 20.5) + (y - 18.5) < -4 then c:px(x, y, so_bounce) end
end)

-- Last water: 14x8 (x14..27, y15..22), outer wa_shade, inner 10x4 wa_base
local pool = c:ellipse(20.5, 18.5, 6.5, 3.5)
c:fill(pool, wa.shade)
local inner = c:rect(16, 17, 25, 20)
inner:del(16, 17); inner:del(25, 20)
c:fill(inner, wa.base)
for x = 16, 19 do c:px(x, 17, wa.gloss) end              -- gloss arc upper-left
c:px(16, 18, wa.gloss)
for x = 19, 21 do c:px(x, 19, wa.rim) end                -- ripple under it

-- Mud dots outside the basin (holes: the lower-right inner wall catches the light)
local d1 = c:rect(6, 31, 10, 35)
d1:del(6, 31); d1:del(10, 31); d1:del(6, 35); d1:del(10, 35)
c:fill(d1, soil900)
c:px(10, 33, so_bounce); c:px(10, 34, so_bounce); c:px(9, 35, so_bounce); c:px(8, 35, so_bounce)
local d2 = c:rect(32, 31, 35, 34)
d2:del(32, 31); d2:del(35, 31); d2:del(32, 34); d2:del(35, 34)
c:fill(d2, soil900)
c:px(35, 33, so_bounce); c:px(34, 34, so_bounce)

-- Rim cracks: three 3 px soil900 ticks pointing outward from the basin
for _, p in ipairs({ {7,18}, {6,18}, {5,19},      -- west
                     {34,20}, {35,20}, {36,21},   -- east
                     {21,29}, {21,30}, {22,31} })  -- south
do c:px(p[1], p[2], soil900) end

local t = c:save(OUT .. "aseprite/" .. NAME .. ".aseprite", OUT .. "png/" .. NAME .. ".png")
print(NAME .. ": " .. GV.report(t))
