local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local stub1 = c:rrect(16, 17, 21, 25, 1)
local stub2 = c:rrect(31, 15, 36, 25, 1)
local bark = c:rrect(8, 22, 47, 49, 10)
local face = c:ellipse(46, 35.5, 9, 13.5)

local p = c:build{
  { "stub1", stub1, "#8a4f2a", { gloss = false } },
  { "stub2", stub2, "#8a4f2a", { gloss = false } },
  { "bark", bark, "#8a4f2a", { light = bark:copy():add(face) } },
  { "face", face, "#d9a660", { gloss = { 40, 26 } } },
}

-- cut tops of the branch stubs
c:fill(c:rect(17, 17, 20, 18), "#d9a660")
c:fill(c:rect(32, 15, 35, 16), "#d9a660")

-- bark grooves
c:fill(c:rect(14, 30, 34, 31), "#5e2f1e")
c:fill(c:rect(12, 37, 35, 38), "#5e2f1e")
c:fill(c:rect(16, 43, 36, 44), "#5e2f1e")

-- growth rings
local r1 = c:ellipse(46, 35.5, 6, 9.5)
c:fill(r1:copy():cut(r1:shrink(1)), "#b07a45")
local r2 = c:ellipse(46, 35.5, 3, 5.5)
c:fill(r2:copy():cut(r2:shrink(1)), "#b07a45")
c:fill(c:rect(45, 34, 47, 37), "#8a4f2a")

c:ground(28, 51, 18, 1.5)

local t = c:save(O .. "aseprite/ph/oak-log.aseprite", O .. "png/ph/oak-log.png")
print(GV.report(t))
