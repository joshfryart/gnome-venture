local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tail = c:poly({ {40, 32}, {57, 20}, {52, 32}, {57, 45} })
local body = c:ellipse(27, 32, 18, 10)
body:add(c:ellipse(15, 32.5, 8, 7))
local belly = c:ellipse(26, 38.5, 15, 4):clip(body:shrink(1)):cut(c:rect(0, 0, 63, 35))
local f1 = c:rrect(27, 24, 29, 38, 1):clip(body:shrink(2))
local f2 = c:rrect(33, 25, 35, 37, 1):clip(body:shrink(2))
c:build{
  { "tail", tail, GV.ramp("#3f93b2") },
  { "body", body, GV.ramp("#3f93b2") },
  { "belly", belly, GV.ramp("#f4f0e0"), { flat = true, contour = false } },
  { "f1", f1, GV.ramp("#256a80"), { flat = true, contour = false, contact = false } },
  { "f2", f2, GV.ramp("#256a80"), { flat = true, contour = false, contact = false } },
}
-- dorsal fin nub and mouth
c:paint({ "..d", ".dd", "ddd" }, 22, 20, { d = "#2f6290" })
c:paint({ "uu" }, 9, 35, { u = "umber" })
c:eye(15, 29, true)
c:paint({ ".p..p..p..p..p", "p.pp.pp.pp.pp." }, 16, 35, { p = "#c8ecdc" })
local t = c:save(O .. "aseprite/ph/trout.aseprite", O .. "png/ph/trout.png")
print(GV.report(t))
