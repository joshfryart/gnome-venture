local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tan = GV.ramp("#c9a96e", { shade = "#9a6b3f" })
local ears = c:poly({ {23,24}, {31,24}, {24,10} }):add(c:poly({ {32,24}, {41,24}, {39,10} }))
ears:add(c:rrect(25, 17, 38, 24, 2))
local body = c:ellipse(31.5, 40, 19, 11):add(c:poly({ {25,23}, {39,23}, {48,36}, {15,36} }))
body:add(c:ellipse(22, 47, 9, 5)):add(c:ellipse(41, 47.5, 9.5, 4.5))
local twine = c:rrect(23, 21, 40, 24, 1)
local patch = c:rrect(21, 30, 42, 50, 5)
local plum = c:ellipse(31.5, 41, 7.5, 7)
c:build{
  { "ears", ears, tan, { gloss = false } },
  { "body", body, tan, { stitch = { side = "lit" } } },
  { "twine", twine, GV.ramp("#7a4a1f"), { flat = true } },
  { "patch", patch, GV.ramp("#f4f0e0"), { gloss = false } },
  { "plum", plum, GV.ramp("#7b66b4", { shade = "#3e2f66", deep = "#291d4a" }) },
}
c:seam({ {23,32}, {40,32}, {40,48}, {23,48}, {23,32} })
c:part(c:ellipse(31.5, 22, 2.5, 2), GV.ramp("#7a4a1f"), { flat = true })
c:part(c:line({ {30,25}, {28,29} }, 2), GV.ramp("#7a4a1f"), { flat = true, contact = false })
c:part(c:line({ {33,25}, {35,28} }, 2), GV.ramp("#7a4a1f"), { flat = true, contact = false })
c:part(c:line({ {31,35}, {31,32} }, 2), GV.ramp("#2f5a2a"), { flat = true, contact = false })
c:part(c:ellipse(36, 33, 3, 1.5), "moss", { flat = true, contact = false })
c:paint({ "ww" }, 15, 40, { w = "#9a6b3f" })
c:paint({ "ww" }, 46, 41, { w = "#9a6b3f" })
c:paint({ "ww" }, 44, 50, { w = "#9a6b3f" })
local t = c:save(O .. "aseprite/ph/nectaplum-seed.aseprite", O .. "png/ph/nectaplum-seed.png")
print(GV.report(t))
