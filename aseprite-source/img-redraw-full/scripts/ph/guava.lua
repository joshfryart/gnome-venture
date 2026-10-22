local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local fruit = c:ellipse(31.5, 37, 16, 15)
fruit:cut(c:ellipse(31.5, 21, 3, 1.5))
local stem = c:line({ {32, 24}, {33, 15} }, 3)
local leaf = c:poly({ {34, 19}, {36, 13}, {40, 8}, {46, 5}, {48, 6}, {46, 11}, {42, 16}, {37, 20} })
c:build{
  { "fruit", fruit, "gold" },
  { "stem",  stem, GV.ramp("#5e3a1e"), { flat = true } },
  { "leaf",  leaf, "moss", { cres = 2, deep = 1 } },
}
c:fill(c:line({ {37, 17}, {46, 7} }, 1), "#4a8a3e")
c:paint({ "u.u.u", ".uuu.", "..u.." }, 29, 48, { u = "#7a3a14" })
c:px(38, 30, "#d0862a"); c:px(41, 37, "#d0862a"); c:px(35, 42, "#d0862a")
local t = c:save(O .. "aseprite/ph/guava.aseprite", O .. "png/ph/guava.png")
print(GV.report(t))
