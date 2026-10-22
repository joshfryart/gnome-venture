local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "icon", cy = 28 }
-- boulder: wide dome, flat base at y 42
local rock = c:ellipse(32, 42, 23, 28):cut(c:rect(0, 43, 63, 90))
rock:add(c:rrect(9, 34, 55, 43, 3))
-- moss cap: dome top with scalloped drips
local cap = c:ellipse(32, 25, 20, 12):cut(c:rect(0, 22, 63, 63))
cap:add(c:ellipse(17, 22, 4, 4)); cap:add(c:ellipse(25, 24, 4, 5))
cap:add(c:ellipse(35, 22, 4, 3)); cap:add(c:ellipse(43, 24, 4, 5)); cap:add(c:ellipse(50, 22, 3, 3))
cap:clip(c:ellipse(32, 42, 25, 30))
c:build{
  { "rock", rock, GV.ramp("#968f96") },
  { "moss", cap, GV.ramp("#6a9a3a") },
}
c:fill(c:line({ { 19, 35 }, { 23, 38 }, { 22, 41 } }, 2), "#5b6470")
c:fill(c:rrect(41, 35, 47, 38, 1), "#c9c5bc")
c:fill(c:ellipse(26, 17, 2, 1.5), "#a4b86a"); c:fill(c:ellipse(38, 16, 2, 1.5), "#a4b86a")
c:ground(32, 45, 22, 1.5)
local t = c:save(D .. "img-redraw-full/aseprite/ico/ico-moss-rock.aseprite", D .. "img-redraw-full/png/ico/ico-moss-rock.png")
print(GV.report(t))
