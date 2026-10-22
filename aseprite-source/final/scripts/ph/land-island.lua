local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "scene", ol = 1, olx = 1, cres = 3, deep = 2 }

-- sky: hard bands, palest at the horizon
c:fill(c:rect(0, 0, 63, 63), "#a9d6ea")
c:fill(c:rect(0, 0, 63, 9), "#8fcbd8")

local sun = c:ellipse(50, 13, 5, 5)
c:part(sun, "#f5cf6a", { gloss = false, bounce = false, cres = 2, deep = 1 })
c:px(48, 10, "#fff1c8"); c:px(47, 11, "#fff1c8")

-- sea (extends past the frame so the edges do not shade)
local sea = c:rect(-8, 40, 71, 71)
c:part(sea, "#3f93b2", { gloss = false, bounce = false, outline = false })
c:fill(c:rect(0, 40, 63, 40), "#8fcbd8") -- horizon glint line
local sea2 = c:rect(0, 55, 63, 63)
c:fill(sea2, "#2f6290")
-- wave arcs
c:paint({ ".wwwwwwwwwwwwwww.", "w...............w" }, 8, 52, { w = "#a9d6ea" })
c:paint({ ".wwwwwwww.", "w........w" }, 41, 50, { w = "#a9d6ea" })
c:paint({ ".wwwww.", "w.....w" }, 30, 59, { w = "#5a9ec0" })

local sand = c:ellipse(32, 40, 20, 6)
c:part(sand, "#dcb06a", { gloss = false })
local grass = c:ellipse(32, 37.5, 14, 4)
c:part(grass, "moss", { gloss = false, contour = false })
-- foam ring where sand meets sea
c:paint({ "ff.......................................ff" }, 11, 46, { f = "#c8ecdc" })

local trunk = c:poly({ { 31, 25 }, { 34, 25 }, { 35, 38 }, { 32, 38 } })
c:part(trunk, "#b6814d", { gloss = false, bounce = false, cres = 2, deep = 0, flat = false })
for y = 28, 36, 3 do c:px(32, y, "#8a4f2a"); c:px(33, y, "#8a4f2a") end

-- four curved fronds (3 px wide, tapering tips)
local leaf = GV.ramp("#58a03e")
local fr = c:line({ { 32, 25 }, { 26, 22 }, { 21, 24 } }, 3)
fr:add(c:line({ { 21, 24 }, { 18, 28 } }, 2))
fr:add(c:line({ { 33, 25 }, { 39, 22 }, { 44, 24 } }, 3))
fr:add(c:line({ { 44, 24 }, { 47, 28 } }, 2))
fr:add(c:line({ { 32, 25 }, { 29, 18 }, { 26, 16 } }, 3))
fr:add(c:line({ { 26, 16 }, { 23, 16 } }, 2))
fr:add(c:line({ { 33, 25 }, { 36, 18 }, { 39, 16 } }, 3))
fr:add(c:line({ { 39, 16 }, { 42, 16 } }, 2))
c:part(fr, leaf, { gloss = false, cres = 2, deep = 1 })
c:px(26, 21, leaf.gloss); c:px(28, 17, leaf.gloss)

local nut = c:ellipse(32.5, 27, 1.5, 1.5)
c:part(nut, "#44281c", { flat = true })

-- hem stitch inside the frame edge
c:seam({ { 1, 1 }, { 62, 1 }, { 62, 62 }, { 1, 62 }, { 1, 1 } }, { free = true })

local t = c:save(O .. "aseprite/ph/land-island.aseprite", O .. "png/ph/land-island.png")
print(GV.report(t))
