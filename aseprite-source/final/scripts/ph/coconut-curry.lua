local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:rect(15, 24, 48, 38):add(c:ellipse(31.5, 38, 16.5, 12))
local p = c:build{
  { "earL", c:rrect(10, 25, 18, 32, 2), GV.ramp("#6a6070") },
  { "earR", c:rrect(45, 25, 53, 32, 2), GV.ramp("#6a6070") },
  { "pot",  body, GV.ramp("#968f96"), { gloss = { 20, 34 } } },
  { "rim",  c:ellipse(31.5, 24, 18, 7), GV.ramp("#6a6070"), { gloss = false } },
  { "curry", c:ellipse(31.5, 24, 15, 4.5), GV.ramp("#8c4a1a"), { gloss = { 22, 22 }, contact = false } },
}
c:part(c:ellipse(26, 24, 2.5, 2), GV.ramp("#5a3424"), { flat = true })
c:part(c:ellipse(37.5, 23.5, 2.5, 2), "moss", { flat = true })
c:px(36, 22, "#c8d77a")
c:px(31, 26, "#e8a317"); c:px(32, 26, "#e8a317"); c:px(42, 25, "#e8a317"); c:px(21, 23, "#e8a317")
local t = c:save(O .. "aseprite/ph/coconut-curry.aseprite", O .. "png/ph/coconut-curry.png")
print(GV.report(t))
