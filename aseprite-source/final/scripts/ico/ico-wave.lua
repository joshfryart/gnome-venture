local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- wave body: rising slope from lower left, round crest hooking right, scoop cut out
local body = c:ellipse(34, 32, 20, 20)
body:add(c:rect(14, 40, 52, 54))
-- concave left slope so the wave leans into its curl
body:cut(c:ellipse(1, 22, 16, 19))
body:add(c:poly({ {5, 55}, {12, 47}, {17, 41}, {22, 55} }))
local scoop = c:ellipse(44, 39, 9, 10)
body:cut(scoop)
body:cut(c:rect(46, 31, 63, 47))
body:cut(c:rect(0, 55, 63, 63))
-- curl tip hooking down at right
body:add(c:ellipse(50, 30, 3.5, 3))

-- inner shade band along the scoop
local band = c:ellipse(44, 39, 13, 14):cut(scoop):clip(body):cut(c:rect(0, 0, 63, 29))
band:cut(c:rect(0, 51, 63, 63))

local p = c:build{
  { "wave", body, "water" },
  { "band", band, GV.ramp("#2f6290"), { gloss = false, rim = false, contact = false } },
  { "foam", c:ellipse(50, 23, 4.5, 4), "#f8eed2" },
}
c:fill(c:rect(54, 12, 55, 13), "#f8eed2")
c:fill(c:rect(57, 21, 58, 22), "#f8eed2")

local t = c:save(O .. "aseprite/ico/ico-wave.aseprite", O .. "png/ico/ico-wave.png")
print(GV.report(t))
