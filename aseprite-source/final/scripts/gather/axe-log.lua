local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
-- half-size grid 32x50, written 2x
local c = GV.canvas{ w = 32, h = 50, mode = "sticker", out = 2 }
local bark = GV.ramp("#8a5c32")

local body = c:rect(6, 18, 26, 38):add(c:ellipse(16, 38, 10, 4))
local top = c:ellipse(16, 18, 10, 4)

c:build{
  { "stem",  c:rect(15, 9, 16, 15), "moss", { flat = true } },
  { "leafL", c:ellipse(12, 10, 3, 2), "moss", { gloss = false } },
  { "curl",  c:ellipse(19, 7.5, 3, 2.5), "moss", { gloss = false } },
  { "log",   body, bark, { gloss = false } },
  { "top",   top, GV.ramp("#e6c186"), { gloss = { 9, 16 } } },
}
-- sprout curl hollow
c:px(19, 7, GV.R.moss.deep); c:px(20, 8, GV.R.moss.deep)
-- rings
c:fill(c:ellipse(16, 18, 7, 2.5):edge(), "#c19a5e")
c:fill(c:ellipse(16, 18, 3, 1), "#b48848")
-- bark: lit strip, grooves, knots
c:fill(c:rect(8, 23, 8, 36), "#c18a52")
for _, g in ipairs({ { 11, 24, 33 }, { 20, 23, 38 }, { 24, 22, 36 } }) do
  c:fill(c:rect(g[1], g[2], g[1], g[3]), "#5e3a20")
end
c:fill(c:ellipse(22, 30, 1.5, 2.5), "#5e3a20"); c:px(21, 29, "#9a6a3c")
c:fill(c:ellipse(12, 37, 1, 1.5), "#5e3a20")

c:ground(16, 43, 11, 1)
local t = c:save(O .. "aseprite/gather/axe-log.aseprite", O .. "png/gather/axe-log.png")
print(GV.report(t))
