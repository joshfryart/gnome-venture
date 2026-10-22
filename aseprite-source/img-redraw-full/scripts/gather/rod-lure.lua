local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- line strands fanning from a top knot
local lines = c:line({ {32, 8}, {24, 20} }, 2)
lines:add(c:line({ {32, 8}, {32, 20} }, 2))
lines:add(c:line({ {32, 8}, {40, 20} }, 2))
local knot = c:rrect(29, 6, 34, 10, 1)

-- dome (wide mushroom cap) with curved underside band
local dome = c:ellipse(32, 36, 20, 15):cut(c:rect(0, 37, 63, 63))
local band = c:ellipse(32, 36, 20, 5):cut(c:rect(0, 0, 63, 35))
local stem = c:rrect(25, 36, 39, 52, 5)

local p = c:build{
  { "lines", lines, GV.ramp("#d9f6b8"), { flat = true } },
  { "knot",  knot,  GV.ramp("#c8d77a"), { flat = true } },
  { "stem",  stem,  GV.ramp("#f4e6c0") },
  { "band",  band,  GV.ramp("#d8a95a") },
  { "dome",  dome,  GV.ramp("#f1d28a") },
}

-- cream dots on the dome

c:spot(c:ellipse(23.5, 30.5, 2, 2), "#fff8e4", "#f5b860")
c:spot(c:ellipse(34.5, 27.5, 2, 2), "#fff8e4", "#f5b860")
c:spot(c:ellipse(43.5, 32.5, 2, 2), "#fff8e4", "#f5b860")

c:seam({ {14, 37}, {50, 37} })
c:ground(32, 54, 10, 1.5)

local t = c:save(O .. "aseprite/gather/rod-lure.aseprite", O .. "png/gather/rod-lure.png")
print(GV.report(t))
