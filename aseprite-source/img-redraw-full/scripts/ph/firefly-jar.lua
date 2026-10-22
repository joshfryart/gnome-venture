-- ph/firefly-jar : pointed-roof glass lantern with a glowing firefly, on a post
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local metal = GV.ramp("#6a6070")   -- stone family, warm grey
local glass = "gold"

c:build{
  { "post", c:rect(29, 40, 35, 53):add(c:rrect(23, 51, 41, 55, 2)), metal },
  { "jar",  c:rrect(19, 19, 45, 39, 5), glass, { gloss = { 23, 23 } } },
  { "base", c:rrect(21, 38, 43, 42, 2), metal, { gloss = false } },
  { "roof", c:poly({ {16,22}, {32,11}, {49,22} }):add(c:rect(17, 20, 47, 22)), metal },
  { "knob", c:rrect(30, 9, 34, 13, 2), "gold", { flat = true } },
}

-- glow inside the glass: round amber light with bright core
c:fill(c:ellipse(32, 30, 6, 6), "#f0b030")
c:fill(c:ellipse(32, 30, 4, 4), "#ffd77a")
c:fill(c:rect(31, 29, 33, 31), "#fff1c8")
-- tiny wing flecks on the firefly
c:px(30, 28, "#fff3c8"); c:px(34, 28, "#fff3c8")

-- roof hem seam
c:seam({ {18, 21}, {46, 21} })

local t = c:save(O .. "aseprite/ph/firefly-jar.aseprite", O .. "png/ph/firefly-jar.png")
print(GV.report(t))
