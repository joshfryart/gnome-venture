local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cloth = GV.ramp("#f1ece0")
local pink = GV.ramp("#e46a9b")
local body = c:ellipse(31.5, 41, 19, 16)
local neck = c:poly({ {23, 28}, {41, 28}, {37, 16}, {27, 16} })
local ruffle = c:ascii({
  "..xx..xx..xx..xx..xx..",
  ".xxxxxxxxxxxxxxxxxxxx.",
  "xxxxxxxxxxxxxxxxxxxxxx",
  "xxxxxxxxxxxxxxxxxxxxxx",
  ".xxxxxxxxxxxxxxxxxxxx.",
}, 21, 11)
local p = c:build{
  { "body", body, cloth, { stitch = true } },
  { "neck", neck, GV.ramp("#dcb06a") },
  { "ruffle", ruffle, cloth },
}
-- neck fold lines
c:line({ {29, 19}, {28, 26} }, 1):each(function(x, y) c:px(x, y, "#b07a45") end)
c:line({ {35, 19}, {36, 26} }, 1):each(function(x, y) c:px(x, y, "#b07a45") end)
-- drawstring around neck
c:part(c:rect(22, 25, 42, 26), pink, { flat = true })
-- cord tails dangling
c:part(c:line({ {28, 27}, {25, 31}, {25, 33} }, 2), pink, { flat = true })
c:part(c:line({ {36, 27}, {39, 31}, {39, 33} }, 2), pink, { flat = true })
-- bow loops and knot
c:part(c:ellipse(27.5, 25, 3, 2), pink, { gloss = false })
c:part(c:ellipse(36.5, 25, 3, 2), pink, { gloss = false })
c:part(c:rect(31, 24, 33, 27), GV.ramp("#c4507f"), { flat = true })
-- side seams
c:seam({ {16, 34}, {14, 40}, {14, 46}, {17, 52} })
c:seam({ {47, 34}, {49, 40}, {49, 46}, {46, 52} })
-- bud stem and leaf
c:part(c:rect(31, 34, 32, 38), GV.ramp("#2e5a2c"), { flat = true })
c:part(c:ellipse(35.5, 35.5, 3, 1.5), GV.ramp("#58a03e"), { flat = true })
-- pink bud (teardrop pointing up)
local bud = c:ellipse(31.5, 45, 6, 6):add(c:poly({ {28, 42}, {36, 42}, {32, 37} }))
c:part(bud, pink)
c:paint({ "d.", ".d", "d." }, 31, 44, { d = pink.shade })
c:ground(31.5, 57, 15, 1.5)
local t = c:save(O .. "aseprite/ph/busy-lizzie-seed.aseprite", O .. "png/ph/busy-lizzie-seed.png")
print(GV.report(t))
