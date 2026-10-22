local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- slumped pouch: wider at the bottom
local body = c:ellipse(31.5, 39, 17, 14)
body:add(c:ellipse(31.5, 46, 18, 8))
body:add(c:poly({ {23, 28}, {40, 28}, {46, 36}, {17, 36} }))
-- gathered ruffled neck, wavy top & bottom
local neck = c:rrect(25, 16, 38, 26, 3)
neck:add(c:ellipse(24.5, 16.5, 2.5, 2)); neck:add(c:ellipse(31.5, 15, 2.5, 2)); neck:add(c:ellipse(38.5, 16.5, 2.5, 2))
neck:add(c:poly({ {22, 26}, {41, 26}, {39, 29}, {24, 29} }))
-- sprig
local stem = c:rect(35, 9, 37, 16)
local leaf = c:poly({ {37, 11}, {41, 7}, {46, 6}, {45, 10}, {40, 13} })
local leaf2 = c:poly({ {35, 12}, {31, 9}, {28, 10}, {30, 13}, {34, 14} })

local p = c:build{
  { "stem",  stem,  "#4a8a3e", { flat = true } },
  { "leaf",  leaf,  "moss" },
  { "leaf2", leaf2, "moss", { flat = true } },
  { "body",  body,  "#f1ece0", { stitch = true } },
  { "neck",  neck,  "#dcb06a" },
  { "patch", c:rrect(23, 34, 40, 48, 4), "#f4f0e0", { pale = true } },
  { "pod",   c:ellipse(31.5, 41.5, 6.5, 3.5):add(c:poly({ {25, 41}, {28, 37}, {37, 37}, {38, 40} })), "#a8582f" },
}
-- carob seeds on pod
c:paint({ ".s.", "sss", ".s." }, 27, 40, { s = "#5e2f1e" })
c:paint({ ".s.", "sss", ".s." }, 31, 39, { s = "#5e2f1e" })
c:paint({ ".s.", "sss", ".s." }, 35, 40, { s = "#5e2f1e" })
-- gather pleats on neck
c:px(28, 20, "#b07a45"); c:px(28, 21, "#b07a45"); c:px(28, 22, "#b07a45")
c:px(35, 20, "#b07a45"); c:px(35, 21, "#b07a45"); c:px(35, 22, "#b07a45")
-- drawstring band and tails
c:fill(c:rect(23, 25, 40, 26), "#8c4a1a")
c:fill(c:rect(24, 25, 39, 25), "#a8582f")
c:fill(c:line({ {24, 27}, {22, 30}, {21, 32} }, 2), "#8c4a1a")
c:fill(c:line({ {39, 27}, {41, 30}, {42, 32} }, 2), "#8c4a1a")
c:paint({ "kkk", "kKk", "kkk" }, 19, 32, { k = "#8c4a1a", K = "#5e2f1e" })
c:paint({ "kkk", "kKk", "kkk" }, 41, 32, { k = "#8c4a1a", K = "#5e2f1e" })
c:seam({ {18, 38}, {17, 44}, {19, 50} })
c:button(30, 18)
c:ground(31.5, 54, 15, 1.5)
local t = c:save(O .. "aseprite/ph/carob-seed.aseprite", O .. "png/ph/carob-seed.png")
print(GV.report(t))
