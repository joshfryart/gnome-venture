local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local skin = GV.ramp("skin", { gloss = "#ffe2a8", shade = "#c47a52" })
local p = c:build{
  { "thumb", c:rrect(22, 7, 35, 34, 7), skin },
  { "fist",  c:rrect(19, 27, 55, 56, 8), skin, { light = c:rrect(19, 7, 55, 56, 8) } },
  { "cuff",  c:rrect(7, 25, 19, 57, 2), "water" },
}
-- finger creases
for _, y in ipairs({ 35, 42, 49 }) do c:fill(c:rect(42, y, 52, y + 1), "#c47a52") end
c:seam({ {17, 28}, {17, 54} })
c:button(10, 36)
c:save(O .. "aseprite/ico/ico-thumbs-up.aseprite", O .. "png/ico/ico-thumbs-up.png")
print(GV.report(c:check()))
