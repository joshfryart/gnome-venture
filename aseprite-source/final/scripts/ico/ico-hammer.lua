local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
c:build{
  { "handle", c:rrect(27, 22, 35, 52, 2), "#c4925f" },
  { "head", c:rect(11, 12, 44, 25), "#968f96" },
  { "claw", c:poly({{44,12},{53,9},{53,26},{44,26}}), "#6a6070", { gloss = false } },
}
for _, y in ipairs({40, 46}) do for x = 28, 34 do c:px(x, y, "#8a4f2a") end end
local t = c:save(O .. "aseprite/ico/ico-hammer.aseprite", O .. "png/ico/ico-hammer.png")
print(GV.report(t))
