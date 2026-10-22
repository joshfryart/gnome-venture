local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local claw = c:poly({
  {41, 6}, {34, 9}, {26, 14}, {19, 21}, {14, 29}, {12, 37}, {13, 45}, {15, 51}, {16, 56},
  {46, 56}, {44, 50}, {39, 44}, {35, 38}, {33, 31}, {34, 23}, {37, 15},
})
local amber = GV.ramp("#dcb06a")
c:build{
  { "claw", claw, amber, { gloss = { 19, 27 }, cres = 5, deep = 2 } },
}
-- shadow side: curved band along the inner (right) edge
local sh = claw:copy():cut(claw:copy():shift(-7, 0)):cut(c:rect(0, 52, 63, 63))
c:fill(sh:clip(claw:shrink(1)), "#a5663a")
local inner = claw:shrink(2)
-- bone stripe
c:fill(c:line({ {19, 49}, {17, 43}, {16, 37}, {18, 31}, {23, 23} }, 3):clip(inner), "#f1ece0")
c:fill(c:line({ {18, 45}, {17, 39} }, 1):clip(inner), "#fff3c8")
-- growth ridges: three arcs across the body
local RG = "#8a4f2a"
c:fill(c:line({ {24, 21}, {29, 19}, {35, 17} }, 1):clip(inner), RG)
c:fill(c:line({ {16, 33}, {24, 31}, {33, 30} }, 1):clip(inner), RG)
c:fill(c:line({ {15, 44}, {25, 42}, {36, 41} }, 1):clip(inner), RG)
-- dark amber tip
c:fill(claw:copy():clip(c:poly({ {30, 0}, {64, 0}, {64, 14}, {30, 14} })):cut(c:rect(0, 12, 34, 14)), "#7a3a14")
c:px(35, 9, "#b8661a"); c:px(36, 8, "#b8661a")
-- flat cut base
c:fill(c:rect(16, 54, 45, 55):clip(claw), "#5e2f1e")
local t = c:save(O .. "aseprite/ph/titan-claw.aseprite", O .. "png/ph/titan-claw.png")
print(GV.report(t))
