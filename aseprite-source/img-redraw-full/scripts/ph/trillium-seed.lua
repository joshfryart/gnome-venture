local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- plump round pouch, wider than tall, pinching up into the neck
local pouch = c:ellipse(31.5, 39, 20, 16)
pouch:add(c:poly({ {22, 30}, {26, 22}, {38, 22}, {42, 30} }))
-- gathered neck with ruffle bumps on top
local neck = c:rrect(24, 17, 39, 24, 3)
neck:add(c:ellipse(25, 16, 3, 3)):add(c:ellipse(31.5, 14, 3.5, 3)):add(c:ellipse(38, 16, 3, 3))
local patch = c:rrect(22, 32, 41, 50, 5)
local bud = c:ellipse(31.5, 42, 5.5, 5.5)

local p = c:build{
  { "pouch", pouch, "#c9a96e", { stitch = { side = "lit" } } },
  { "neck",  neck,  "#9a6b3f" },
  { "patch", patch, "#f4f0e0", { pale = true, gloss = false } },
}
-- ruffle folds on the neck
c:fill(c:rect(28, 19, 28, 22), "#7a4a1f"); c:fill(c:rect(35, 19, 35, 22), "#7a4a1f")
-- patch ring and bud
c:fill(patch:copy():cut(patch:shrink(2)), "#3f93b2")
c:part(bud, GV.ramp("#3f93b2", { shade = "#256a80" }))
c:fill(c:ascii({ ".gg.", "gggg", ".gg." }, 36, 34), "#58a03e")
-- drawstring around the neck and two cord tails with knots
c:part(c:line({ {22, 22}, {41, 22} }, 2), "gold", { flat = true })
local tails = c:line({ {31, 23}, {27, 28}, {25, 31} }, 2):add(c:line({ {32, 23}, {36, 28}, {38, 31} }, 2))
c:part(tails, "gold", { flat = true })
c:part(c:rect(24, 31, 26, 33), "gold", { flat = true })
c:part(c:rect(37, 31, 39, 33), "gold", { flat = true })
-- seam stitch around the patch
c:seam({ {24, 30}, {39, 30} }); c:seam({ {24, 52}, {39, 52} })

local t = c:save(O .. "aseprite/ph/trillium-seed.aseprite", O .. "png/ph/trillium-seed.png")
print(GV.report(t))
