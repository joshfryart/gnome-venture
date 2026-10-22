local G = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gnome-parts/scripts/gnome-common.lua")
local GV = G.GV
local c = G.canvas()
-- soft ground shadow: hard pixels, soil family, checker-dithered rim (no outline: it is a shadow)
local outer = c:ellipse(40, 96, 26, 3.5)
local mid   = c:ellipse(40, 96, 23, 3)
local core  = c:ellipse(40, 96, 17, 2)
outer:each(function(x, y)
  if mid:has(x, y) or (x + y) % 2 == 0 then c:px(x, y, core:has(x, y) and "#7a4a1f" or "#9a6b3f") end
end)
G.save(c, "gnome-shadow")
