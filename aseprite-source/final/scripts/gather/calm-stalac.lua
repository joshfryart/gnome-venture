local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "scene" }

-- one wide stalactite, bleeding off top and sides, tip near the bottom centre
local rock = c:poly({ {0,0},{64,0},{64,7},{55,18},{47,28},{38,44},{34,51},{32,53},{30,51},{26,44},{17,28},{9,18},{0,7} })
local R = GV.ramp("#7f8f86")
local p = c:build{
  { "rock", rock, R, { gloss = false } },
}
-- lit left half: repaint base pixels left of centre with the lighter tone
local lit = rock:shrink(2):clip(c:rect(0, 0, 31, 63))
lit:each(function(x, y)
  if c:get(x, y) == R.base then c:px(x, y, "#9fb0a6") end
end)
-- veins
c:fill(c:line({ {13,6},{16,16},{20,28},{25,40},{28,47} }, 2), "#d3e0d8")
c:fill(c:line({ {48,8},{45,18},{42,30},{38,40},{35,46} }, 2), "#5e6e66")
-- horizontal ripple bands (stone layers)
c:fill(c:line({ {8,10},{20,12} }, 1), "#c3d2ca")
c:fill(c:line({ {44,12},{56,10} }, 1), "#6b7b73")
-- water drop gathering at the tip
local drop = c:ellipse(32, 56, 3.5, 3):add(c:rect(31, 51, 32, 53))
c:part(drop, GV.ramp("#7ccdef"), { gloss = false })
c:px(30, 55, "#fff3c8")
local t = c:save(O .. "aseprite/gather/calm-stalac.aseprite", O .. "png/gather/calm-stalac.png")
print(GV.report(t))
