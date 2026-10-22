local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local lid = c:poly({ {12, 14}, {53, 4}, {54, 11}, {12, 21} })
c:build{
  { "berry", c:ellipse(29, 25, 9), GV.ramp("#7b66b4", { shade = "#3e2f66", deep = "#291d4a" }) },
  { "leaf",  c:poly({ {37, 24}, {42, 19}, {48, 18}, {46, 23}, {40, 27} }), "leaf", { flat = true } },
  { "body",  c:rrect(11, 28, 53, 56, 3), "stone" },
  { "hingeL", c:rect(13, 20, 16, 29), GV.ramp("#5b6470"), { flat = true } },
  { "hingeR", c:rect(48, 10, 51, 29), GV.ramp("#5b6470"), { flat = true } },
  { "lid",   lid, GV.ramp("#d4d2cc"), { cres = 2, deep = 1 } },
  { "label", c:rrect(20, 39, 44, 52, 3), GV.ramp("#7b66b4"), { flat = true } },
  { "card",  c:rrect(22, 41, 42, 50, 2), GV.ramp("#f4f0e0"), { flat = true, contour = false } },
}
c:fill(c:line({ {13, 20}, {53, 11} }, 1), "#5b6470")
c:seam({ {13, 31}, {51, 31} })
c:button(30, 29)
c:paint({ ".vv.", "vvvv", ".vv." }, 30, 44, { v = "#7b66b4" })
local t = c:save(O .. "aseprite/ph/naupaka-seed.aseprite", O .. "png/ph/naupaka-seed.png")
print(GV.report(t))
