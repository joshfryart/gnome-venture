local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tail = c:poly({ {14, 29}, {10, 20}, {12, 19}, {19, 29} })
local cone = c:poly({ {15, 34}, {51, 30}, {34, 53}, {31, 55}, {29, 53} })
local rim  = c:poly({ {12, 30}, {52, 26}, {53, 32}, {13, 36} })
local pod  = c:line({ {19, 31}, {19, 23}, {22, 15}, {28, 10}, {35, 9}, {42, 12}, {46, 19}, {47, 28} }, 5)
pod:add(c:ellipse(20, 22, 3.5)):add(c:ellipse(25, 13, 3.5)):add(c:ellipse(33, 10, 3.5)):add(c:ellipse(41, 12, 3.5)):add(c:ellipse(46, 20, 3.5))
local p = c:build{
  { "tail", tail, "#f1ece0", { flat = true } },
  { "cone", cone, "#f1ece0", { gloss = false } },
  { "rim",  rim,  "#f4f0e0", { gloss = false } },
  { "pod",  pod,  GV.ramp("#3f93b2", { shade = "#2f6290", rim = "#8fcbd8", gloss = "#c8ecdc" }), { gloss = { 23, 12 } } },
}
-- twist bands on tail
c:fill(c:line({ {11, 23}, {14, 21} }, 1), "#dcb06a")
c:fill(c:line({ {13, 27}, {16, 25} }, 1), "#dcb06a")
-- bulge separations
c:fill(c:line({ {19, 17}, {23, 18} }, 1), "#256a80")
c:fill(c:line({ {29, 7}, {29, 12} }, 1), "#256a80")
c:fill(c:line({ {37, 7}, {37, 12} }, 1), "#256a80")
c:fill(c:line({ {42, 16}, {46, 15} }, 1), "#256a80")
-- cone fold lines
c:fill(c:line({ {22, 37}, {30, 50} }, 1), "#dcb06a")
c:fill(c:line({ {42, 35}, {34, 47} }, 1), "#dcb06a")
c:ground(32, 57, 14, 2)
local t = c:save(O .. "aseprite/ph/tamarind-seed.aseprite", O .. "png/ph/tamarind-seed.png")
print(GV.report(t))
