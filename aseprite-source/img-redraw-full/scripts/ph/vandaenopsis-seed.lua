local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tail = c:poly({ {27,22},{37,22},{36,16},{41,8},{36,10},{33,5},{30,10},{24,8},{28,16} })
local cone = c:poly({ {14,24},{51,24},{33,58},{31,58} })
local rim = c:rrect(13, 19, 50, 26, 3)
local paperR = GV.ramp("#f1ece0")
local p = c:build{
  { "tail", tail, "#dcb06a", { gloss = false } },
  { "cone", cone, paperR, { gloss = { 19, 29 } } },
  { "rim", rim, "#f4f0e0", { gloss = { 17, 21 } } },
}
-- twist lines on tail
for _, v in ipairs({ {30,17},{31,16},{32,15},{33,14},{34,13} }) do c:px(v[1], v[2], "#b8661a") end
for _, v in ipairs({ {31,21},{32,20},{33,19},{34,18},{35,17} }) do c:px(v[1], v[2], "#b8661a") end
-- spiral fold line
c:fill(c:line({ {17,27},{40,51} }, 2):clip(p.cone.m:shrink(1)), "#dcb06a")
c:seam({ {18,29},{39,50} })
-- patch ring + bud
local patch = c:ellipse(32, 36, 9)
c:fill(patch, "#3f93b2")
c:fill(c:ellipse(32, 36, 7), "#f4f0e0")
local leaf = c:poly({ {32,41},{36,38},{40,39},{37,42},{33,43} })
c:part(leaf, GV.ramp("#58a03e"), { gloss = false, contact = false, flat = true })
local bud = c:ellipse(29, 33, 2.5):add(c:ellipse(35, 33, 2.5)):add(c:ellipse(28.5, 38, 2.5, 2)):add(c:ellipse(35.5, 38, 2.5, 2)):add(c:ellipse(32, 40, 2, 2.5)):add(c:ellipse(32, 36, 3))
c:part(bud, GV.ramp("#3f93b2", { shade = "#256a80" }), { gloss = { 28, 32 }, contact = false })
c:paint({ ".y.", "yuy", ".u." }, 31, 35, { y = "#f5cf6a", u = "#256a80" })
local t = c:save(O .. "aseprite/ph/vandaenopsis-seed.aseprite", O .. "png/ph/vandaenopsis-seed.png")
print(GV.report(t))
