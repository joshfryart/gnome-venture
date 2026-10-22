local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local brown = GV.ramp("#8c4a1a")
local dark  = GV.ramp("#44281c")
-- curly tail at the right
local tail = c:line({ {47,44}, {51,43}, {54,40}, {54,37}, {52,35}, {50,36}, {50,38} }, 2)
-- sharp ears angled outward
local earL = c:poly({ {17,25}, {14,10}, {28,17} })
local earR = c:poly({ {36,17}, {50,10}, {47,25} })
local ears = earL:copy(); ears:add(earR)
local feet = c:ellipse(22.5, 52, 5.5, 3.5); feet:add(c:ellipse(41.5, 52, 5.5, 3.5))
local body = c:ellipse(32, 41, 18, 12.5)
local belly = c:ellipse(32, 45, 10, 7.5)
local head = c:ellipse(31.5, 27, 13.5, 12)
local snout = c:ellipse(31.5, 33, 8.5, 5)
local tuskL = c:ascii({ "xx...", "xxx..", "xxxx.", ".xxxx", ".xxxx", "..xxx", "...xx" }, 18, 28)
local tuskR = c:ascii({ "...xx", "..xxx", ".xxxx", "xxxx.", "xxxx.", "xxx..", "xx..." }, 40, 28)
local tusks = tuskL:copy(); tusks:add(tuskR)
local p = c:build{
  { "tail", tail, dark, { flat = true } },
  { "ears", ears, brown },
  { "feet", feet, dark },
  { "body", body, brown, { stitch = { side = "lit" } } },
  { "belly", belly, GV.ramp("#a5663a"), { gloss = false } },
  { "head", head, brown },
  { "snout", snout, GV.ramp("#f6b8cf") },
  { "tusks", tusks, GV.ramp("#f8eed2"), { gloss = false, contour = "#74462a" } },
}
-- inner ears
c:fill(c:poly({ {19,22}, {17,13}, {25,18} }), "#44281c")
c:fill(c:poly({ {39,18}, {47,13}, {45,22} }), "#44281c")
-- bristle tuft on top of head
c:paint({ "d.d.d", ".d.d." }, 29, 15, { d = "#5e2f1e" })
-- nostrils
c:paint({ "nn...nn", "nn...nn" }, 28, 32, { n = "#9c2a1e" })
c:eye(22, 20); c:eye(37, 20)
c:ground(32, 56, 19, 1.5)
local t = c:save(O .. "aseprite/ph/creature-wild-boar.aseprite", O .. "png/ph/creature-wild-boar.png")
print(GV.report(t))
