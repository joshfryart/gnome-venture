local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local wind = GV.ramp("#9fb4bf")

-- top streak with upward hook curling back
local top = c:rrect(10, 22, 38, 25, 2)
top:add(c:ellipse(37.5, 18.5, 6, 6):cut(c:ellipse(37.5, 18.5, 2.5, 2.5)):cut(c:rect(30, 18, 34, 22)))
top:cut(c:rect(30, 19, 33, 21))
-- middle streak with downward hook
local mid = c:rrect(10, 32, 46, 35, 2)
mid:add(c:ellipse(45.5, 39.5, 6, 6):cut(c:ellipse(45.5, 39.5, 2.5, 2.5)):cut(c:rect(38, 36, 43, 41)))
-- bottom streak
local bot = c:rrect(16, 43, 32, 46, 2)
c:build{
  { "top", top, wind, { gloss = { 13, 23 } } },
  { "mid", mid, wind, { gloss = { 13, 33 } } },
  { "bot", bot, wind, { gloss = { 19, 44 } } },
}
c:part(c:rect(52, 22, 54, 24), GV.ramp("#c8ecdc"), { flat = true })
local t = c:save(D .. "img-redraw-full/aseprite/ico/ico-wind.aseprite", D .. "img-redraw-full/png/ico/ico-wind.png")
print(GV.report(t))
