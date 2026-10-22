local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(31.5, 36, 15, 18)
local sprout = c:line({{31, 21}, {32, 15}, {35, 11}}, 3)
local leaf = c:ellipse(37.5, 11.5, 3, 1.5)
sprout:add(leaf)
-- husk cap: shaggy crescent over upper third
local cap = c:ellipse(31.5, 36, 16, 19):clip(c:rect(0, 0, 63, 29))
for x = 17, 46, 3 do cap:add(c:rect(x, 28, x + 1, 31)) end
cap:clip(c:ellipse(31.5, 36, 16, 19))
local p = c:build{
  { "sprout", sprout, "#4a8a3e", { flat = true } },
  { "body", body, "#8c4a1a", { light = body } },
  { "cap", cap, "#5a3320", { light = body, gloss = { 24, 23 } } },
}
-- groove
c:paint({ "gg....", ".gg...", "..gggg" }, 33, 46, { g = "#44281c" })
-- husk hairs
c:px(21, 41, GV.C.umber); c:px(21, 42, GV.C.umber)
c:px(43, 35, GV.C.umber); c:px(43, 36, GV.C.umber)
c:px(29, 48, GV.C.umber); c:px(29, 49, GV.C.umber)
c:px(30, 25, "#7a4a2a"); c:px(36, 23, "#7a4a2a"); c:px(41, 26, "#7a4a2a")
c:ground(31.5, 55, 12, 1.5)
local t = c:save(O .. "aseprite/ph/coconut.aseprite", O .. "png/ph/coconut.png")
print(GV.report(t))
