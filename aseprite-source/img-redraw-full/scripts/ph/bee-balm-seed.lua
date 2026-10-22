local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- twisted paper tail (behind the cone mouth), leaning right
local tail = c:poly({ {27, 19}, {31, 11}, {36, 8}, {40, 10}, {37, 14}, {36, 19} })
-- cone: point-down triangle with a slightly rolled mouth
local cone = c:poly({ {13, 20}, {51, 20}, {33, 58} })
cone:add(c:rrect(13, 18, 50, 23, 2))
-- seed ball sits in the mouth
local seed = c:ellipse(32, 25, 8, 7.5)

local p = c:build{
  { "tail", tail, "#f1ece0" },
  { "cone", cone, "#f1ece0" },
  { "seed", seed, GV.ramp("#7a5cc0", { shade = "#4e3a8a" }) },
}
-- twist band on the tail
c:fill(c:line({ {29, 15}, {38, 12} }, 2):clip(p.tail.m), "#dcb06a")
-- fold line on the cone with a gold seam along it
local fold = c:line({ {19, 26}, {32, 53} }, 2):clip(p.cone.m):cut(seed)
c:fill(fold, "#dcb06a")
c:seam({ {22, 33}, {32, 52} })
-- paper dots
c:fill(c:rect(25, 38, 26, 39), "#8c4a1a")
c:fill(c:rect(33, 43, 34, 44), "#8c4a1a")
c:fill(c:rect(39, 36, 40, 37), "#8c4a1a")
-- sprout from the seed
c:fill(c:line({ {32, 17}, {32, 21} }, 2), "#2e5a2c")
local leaf = c:ellipse(37, 15, 3, 2)
c:fill(leaf, "#58a03e")
c:px(36, 14, "#a4d06a"); c:px(37, 14, "#a4d06a")
c:px(39, 16, "#2e5a2c")
local leaf2 = c:ellipse(28, 16, 2, 1.5)
c:fill(leaf2, "#58a03e")
c:px(27, 15, "#a4d06a")

local t = c:save(O .. "aseprite/ph/bee-balm-seed.aseprite", O .. "png/ph/bee-balm-seed.png")
print(GV.report(t))
