local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local p = c:build{
  { "sheet", c:poly({{17,12},{37,12},{48,23},{48,52},{17,52}}), "#f8eed2", { pale = true } },
  { "fold", c:poly({{37,12},{37,23},{48,23}}), "#c9a96e", { gloss = false } },
  { "bar0", c:rect(23, 25, 31, 28), "#968f96", { flat = true } },
  { "bar1", c:rect(23, 34, 41, 37), "#968f96", { flat = true } },
  { "bar2", c:rect(23, 42, 41, 45), "#968f96", { flat = true } },
}
local t = c:save(O .. "aseprite/ico/ico-page.aseprite", O .. "png/ico/ico-page.png")
print(GV.report(t))
