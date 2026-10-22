local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tail = c:poly({ {39,32}, {55,20}, {52,32}, {55,45}, {39,34} })
local fin = c:poly({ {22,23}, {30,13}, {35,15}, {34,23} })
local body = c:ellipse(25, 33, 17, 12)
body:add(c:poly({ {7,33}, {14,25}, {14,41} }))
local belly = c:ellipse(28, 43, 14, 6):clip(body:shrink(1))
local p = c:build{
  { "tail", tail, GV.ramp("#5a86b8") },
  { "fin", fin, GV.ramp("#8fcbd8") },
  { "body", body, "water", { gloss = { 18, 26 } } },
  { "belly", belly, "cream", { gloss = false, rim = false } },
}
local bars = c:rect(27, 23, 28, 39):add(c:rect(34, 24, 35, 39)):clip(body:shrink(1)):cut(belly)
c:fill(bars, "#2f6290")
c:fill(c:line({ {53, 23}, {51, 31} }, 2):add(c:line({ {51, 34}, {53, 42} }, 2)):clip(tail), "#f5cf6a")
c:eye(13, 29, true)
local t = c:save(O .. "aseprite/ph/rainbow-fish.aseprite", O .. "png/ph/rainbow-fish.png")
print(GV.report(t))
