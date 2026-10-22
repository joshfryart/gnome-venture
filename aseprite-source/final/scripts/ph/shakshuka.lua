local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local bowl = c:ellipse(31.5, 29, 16, 15):cut(c:rect(0, 0, 63, 28))
local handles = c:rrect(10, 25, 17, 30, 2):add(c:rrect(46, 25, 53, 30, 2))
c:build{
  { "handles", handles, "stone" },
  { "pan", bowl, "stone" },
  { "rim", c:ellipse(31.5, 28, 16.5, 6), GV.ramp("#8b8f96") },
  { "sauce", c:ellipse(31.5, 28, 13.5, 4), GV.ramp("#d6322b"), { cres = 1, deep = 0 } },
}
local P = GV.ramp("#f1ece0")
c:part(c:ellipse(26, 27, 3.5, 2.5), P, { flat = true })
c:part(c:ellipse(37, 28.5, 3.5, 2.5), P, { flat = true })
c:paint({ "yy", "yY" }, 25, 26, { y = "#e8a317", Y = "#b8661a" })
c:paint({ "yy", "yY" }, 36, 28, { y = "#e8a317", Y = "#b8661a" })
c:px(25, 26, "#fff1c8"); c:px(36, 28, "#fff1c8")
for _, f in ipairs({ {20, 28}, {31, 26}, {32, 30}, {42, 27}, {22, 30}, {40, 30} }) do c:px(f[1], f[2], "#6a9a3a") end
c:ground(31.5, 45, 12, 1.5)
local t = c:save(O .. "aseprite/ph/shakshuka.aseprite", O .. "png/ph/shakshuka.png")
print(GV.report(t))
