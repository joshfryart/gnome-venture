-- gather/calm-ripple : concentric water rings, inner solid, outer two dashed
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 100, h = 100, mode = "scene", out = 2 }
-- half-size grid 100x100, centre between px 49 and 50
local cx, cy = 49.5, 49.5

local function ring(r0, r1)
  local m = c:mask()
  for y = 0, 99 do for x = 0, 99 do
    local d = math.sqrt((x - cx) ^ 2 + (y - cy) ^ 2)
    if d >= r0 and d < r1 then m:set(x, y) end
  end end
  return m
end
-- dashed: keep arcs by angle; symmetric pattern (n dashes around)
local function dashed(m, n, onFrac, phase)
  local out = c:mask()
  m:each(function(x, y)
    local a = (math.atan(y - cy, x - cx) / (2 * math.pi) + 1 + phase) % 1
    if (a * n) % 1 < onFrac then out:set(x, y) end
  end)
  return out
end

local inner = ring(14, 16)
local mid   = dashed(ring(28, 30), 8, 0.72, 0.0)
local outer = dashed(ring(42, 44), 8, 0.62, 1 / 16)
c:fill(dashed(ring(30, 31), 8, 0.72, 0.0), "#8fcbd8")
c:fill(ring(16, 17), "#8fcbd8")
c:fill(mid, "#c8ecdc")
c:fill(outer, "#8fcbd8")
c:fill(inner, "#c8ecdc")
c:px(49, 49, "#c8ecdc"); c:px(50, 49, "#c8ecdc"); c:px(49, 50, "#c8ecdc"); c:px(50, 50, "#c8ecdc")

local t = c:save(O .. "aseprite/gather/calm-ripple.aseprite", O .. "png/gather/calm-ripple.png")
print(GV.report(t))
