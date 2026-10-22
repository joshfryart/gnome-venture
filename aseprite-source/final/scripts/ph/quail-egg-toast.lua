local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local toast = c:rrect(11, 19, 53, 51, 6)
toast:add(c:ellipse(21.5, 19, 9, 7)):add(c:ellipse(42.5, 19, 9, 7)):add(c:rect(14, 19, 50, 26))
local crumb = toast:shrink(3)
local white = c:ellipse(32, 36, 14, 10)
for _, b in ipairs({ {20, 32, 4}, {23, 43, 4}, {33, 46, 3.5}, {43, 41, 4}, {44, 31, 3.5}, {34, 26, 3.5}, {25, 27, 3} }) do
  white:add(c:ellipse(b[1], b[2], b[3]))
end
local yolk = c:ellipse(31, 35, 5, 5)
local p = c:build{
  { "crust", toast, GV.ramp("#a8582f"), { cres = 3 } },
  { "crumb", crumb, GV.ramp("#d9a660"), { cres = 3, contour = false, contact = false } },
  { "white", white, GV.ramp("#f1ece0"), { pale = true, cres = 3 } },
  { "yolk", yolk, "gold", { cres = 3 } },
}
for _, s in ipairs({ {22, 34}, {40, 30}, {27, 44}, {41, 42}, {35, 27} }) do c:px(s[1], s[2], "#7a4a1f") end
local t = c:save(O .. "aseprite/ph/quail-egg-toast.aseprite", O .. "png/ph/quail-egg-toast.png")
print(GV.report(t))
