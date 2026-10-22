local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cream = GV.ramp("#f4f0e0")
local frill = c:poly({ {16, 12}, {25, 16}, {31.5, 10}, {38, 16}, {47, 12}, {41, 21}, {37, 24}, {37, 29}, {27, 29}, {27, 24}, {22, 21} })
local green = GV.ramp("#58a03e")
c:build{
  { "frill", frill, cream },
  { "sack",  c:ellipse(31.5, 41, 18, 15), cream, { stitch = true } },
  { "seed",  c:ellipse(31.5, 44, 8.5, 7.5), GV.ramp("#3f93b0") },
}
c:fill(c:ellipse(31.5, 44, 8.5, 7.5):edge(), "#2a3c6c")
c:part(c:rect(31, 33, 32, 37), green, { flat = true })
c:part(c:poly({ {33, 34}, {36, 31}, {41, 30}, {39, 34}, {34, 36} }), green, { flat = true })
c:part(c:rect(25, 23, 38, 25), "gold", { flat = true })
c:part(c:ellipse(26.5, 20.5, 3, 2.5), "gold", { flat = true })
c:part(c:ellipse(36.5, 20.5, 3, 2.5), "gold", { flat = true })
c:part(c:line({ {30, 26}, {28, 30} }, 2), "gold", { flat = true })
c:part(c:line({ {33, 26}, {35, 30} }, 2), "gold", { flat = true })
c:part(c:rrect(30, 21, 33, 25, 1), "gold", { flat = true })
local t = c:save(O .. "aseprite/ph/coneflower-seed.aseprite", O .. "png/ph/coneflower-seed.png")
print(GV.report(t))
