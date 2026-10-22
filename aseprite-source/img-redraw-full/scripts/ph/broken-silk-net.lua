local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local wood = GV.ramp("#b6814d", { gloss = "#f0d49a" })
-- handle in two pieces with a snapped gap
local h1 = c:line({ {11, 55}, {20, 46} }, 5)
local h2 = c:line({ {27, 39}, {32, 34} }, 5)
-- hoop rim ring and silk
local disc = c:ellipse(41.5, 22.5, 14, 14)
local silk = c:ellipse(41.5, 22.5, 11, 11)
-- tear: bite out of the lower-left of the silk
local tear = c:poly({ {30, 26}, {35, 27}, {33, 30}, {37, 32}, {34, 36}, {29, 33} })
silk:cut(tear)
local rim = disc:copy():cut(c:ellipse(41.5, 22.5, 11, 11))
local p = c:build{
  { "h1", h1, wood },
  { "h2", h2, wood, { gloss = false } },
  { "silk", silk, GV.ramp("#a9d6ea"), { gloss = false, rim = false } },
  { "rim", rim, GV.ramp("#8c4a1a"), { light = disc, gloss = { 32, 13 } } },
}
-- net threads: cross, one arm broken
local th = "#2f6290"
c:fill(c:rect(41, 12, 42, 33), th)
c:fill(c:rect(31, 22, 52, 23), th)
c:fill(c:rect(31, 22, 36, 23), "#a9d6ea")   -- broken left arm
c:fill(c:rect(31, 22, 33, 23), th)
c:fill(c:rect(34, 22, 36, 23), "#a9d6ea")
-- diagonal mesh lines
-- fine mesh grid
local mesh = c:mask()
for x = 33, 51, 3 do mesh:add(c:rect(x, 10, x, 35)) end
for y = 13, 33, 3 do mesh:add(c:rect(29, y, 54, y)) end
mesh:clip(silk:shrink(1))
c:fill(mesh, "#7fb8d0")
-- frayed threads at the tear
c:px(33, 28, th); c:px(35, 31, th); c:px(31, 31, th)
-- splintered ends at the break
c:paint({ "w.w", "ww." }, 21, 44, { w = "#b6814d" })
c:paint({ ".w", "w." }, 25, 40, { w = "#b6814d" })
-- loose splinters
c:part(c:line({ {45, 47}, {50, 50} }, 3), wood, { flat = true })
c:part(c:line({ {7, 40}, {12, 42} }, 3), wood, { flat = true })
local t = c:save(O .. "aseprite/ph/broken-silk-net.aseprite", O .. "png/ph/broken-silk-net.png")
print(GV.report(t))
