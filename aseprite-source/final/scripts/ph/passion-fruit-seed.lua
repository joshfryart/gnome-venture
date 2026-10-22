local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local whole = c:rrect(9, 18, 54, 52, 4)
local p = c:build{
  { "base", c:rrect(10, 33, 53, 52, 4), "#8b8f96", { light = whole } },
  { "lid",  c:rrect(9, 18, 54, 33, 4),  "#c9c5bc", { light = whole } },
  { "hinge", c:rect(14, 33, 49, 34), "#5b6470", { flat = true } },
  { "fruit", c:ellipse(31.5, 25, 6.5, 6), GV.ramp("#b0bc66", { shade = "#58a03e" }) },
}
c:part(c:rect(31, 16, 32, 19), "#2e5a2c", { flat = true })
c:part(c:poly({ {33, 17}, {37, 14}, {40, 15}, {37, 18} }), GV.ramp("#58a03e"), { flat = true })
-- fruit speckles
c:px(29, 27, "#6a7a2e"); c:px(34, 24, "#6a7a2e"); c:px(31, 29, "#6a7a2e")
c:seam({ {13, 31}, {51, 31} })
c:button(30, 38)
c:part(c:rect(14, 44, 15, 45), "#5b6470", { flat = true })
c:part(c:rect(48, 44, 49, 45), "#5b6470", { flat = true })
c:ground(31.5, 53, 22, 1.5)
local t = c:save(O .. "aseprite/ph/passion-fruit-seed.aseprite", O .. "png/ph/passion-fruit-seed.png")
print(GV.report(t))
