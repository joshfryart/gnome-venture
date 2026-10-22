local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local glass = GV.ramp("#c8ecdc", { shade = "#8fcbd8", deep = "#5a9ab8", bounce = "#a8dce4" })
local jar = c:rrect(16, 21, 48, 54, 7)
jar:add(c:rrect(22, 18, 42, 24, 3))
local neck = c:rect(24, 15, 40, 20)
local cork = c:rrect(22, 7, 42, 15, 2)

local p = c:build{
  { "jar",  jar,  glass, { gloss = false, cres = 5, deep = 2 } },
  { "neck", neck, glass, { gloss = false, cres = 2, deep = 1 } },
  { "cork", cork, "wood", { cres = 2, deep = 1 } },
}
-- cork grain pores
c:px(30, 10, GV.R.wood.shade); c:px(36, 12, GV.R.wood.shade); c:px(27, 13, GV.R.wood.shade)

-- seed resting on the floor
local seed = c:ellipse(32, 44, 7, 7)
c:part(seed, "moss", { cres = 3, deep = 1 })
-- sprig
local stem = c:line({ {32, 37}, {32, 32} }, 2)
c:part(stem, "#4a8a3e", { flat = true })
local leaf = c:ascii({ "..xxx.", ".xxxxx", "xxxxx.", "xxx..." }, 33, 29)
c:part(leaf, "#4a8a3e", { flat = true })
local leaf2 = c:ascii({ "xx..", "xxx.", ".xxx" }, 28, 31)
c:part(leaf2, "#4a8a3e", { flat = true })

-- glass highlight strip on the upper left (the gloss)
c:fill(c:rect(20, 26, 21, 37), "#f4fff8")
c:fill(c:rect(20, 40, 21, 42), "#f4fff8")
c:px(25, 25, "#f4fff8")
-- seam on neck below the cork
c:seam({ {24, 17}, {40, 17} })

local t = c:save(O .. "aseprite/ph/oleander-seed.aseprite", O .. "png/ph/oleander-seed.png")
print(GV.report(t))
