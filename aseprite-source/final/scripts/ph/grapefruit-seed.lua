local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- lid tilted back: narrower top edge, propped open
local lid = c:poly({ {17, 12}, {47, 12}, {50, 27}, {14, 27} })
lid:cut(c:rect(17, 12, 17, 12)); lid:cut(c:rect(46, 12, 46, 12))
local gap = c:rect(15, 25, 49, 30)
local body = c:rrect(11, 29, 52, 52, 4)
local p = c:build{
  { "lid",  lid,  GV.ramp("#8b8f96", { shade = "#5b6470" }), { stitch = false } },
  { "gap",  gap,  GV.ramp("#2a1a10"), { flat = true, rim = false } },
  { "body", body, GV.ramp("#c9c5bc", { shade = "#8b8f96" }) },
}
-- inner lid rim line (shows it's an open lid face)
c:fill(c:rect(19, 15, 44, 15), "#5b6470")
-- hinges
c:part(c:rect(18, 27, 21, 29), GV.ramp("#5b6470"), { flat = true })
c:part(c:rect(42, 27, 45, 29), GV.ramp("#5b6470"), { flat = true })
-- grapefruit label disc
local disc = c:ellipse(31.5, 41, 8.5, 8.5)
c:part(disc, GV.ramp("#e46a9b"), { gloss = false, cres = 2, deep = 1 })
local inner = disc:shrink(2)
c:fill(inner, "#f5cf6a")
local seg = "#f6b8cf"
c:fill(c:line({ {26, 41}, {37, 41} }, 1):clip(inner), seg)
c:fill(c:line({ {31, 36}, {31, 46} }, 1):clip(inner), seg)
c:fill(c:line({ {27, 37}, {36, 46} }, 1):clip(inner), seg)
c:fill(c:line({ {36, 37}, {27, 46} }, 1):clip(inner), seg)
c:fill(c:rect(31, 41, 32, 42), "#fff3c8")
-- seam along the lid/body join
c:seam({ {14, 31}, {50, 31} })
local t = c:save(O .. "aseprite/ph/grapefruit-seed.aseprite", O .. "png/ph/grapefruit-seed.png")
print(GV.report(t))
