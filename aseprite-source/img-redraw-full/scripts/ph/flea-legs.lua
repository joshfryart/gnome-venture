local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- pointed bean: wide arch on top, tapering to a point at the bottom
local body = c:ellipse(32, 34, 22, 14)
body:add(c:poly({ {14, 40}, {50, 40}, {40, 49}, {32, 53}, {24, 49} }))
body = body:closed(2)
c:build{
  { "body", body, GV.ramp("#e46a9b"), { gloss = { 22, 27 } } },
}
-- bent leg arch: light edge then core
local pts = { {20, 39}, {24, 34}, {28, 31}, {32, 30}, {36, 31}, {40, 34}, {44, 39} }
local arch = c:line(pts, 4)
local edge = arch:grow(1):cut(arch):clip(body)
c:fill(edge, "#c66b50")
c:fill(arch, "#f6b8cf")
c:fill(arch:copy():cut(arch:shift(0, -1)), "#c66b50")
c:fill(c:line({ {23, 35}, {26, 32}, {29, 31}, {32, 30} }, 1):clip(arch), "#fff3c8")
-- knuckles
c:fill(c:rect(19, 39, 21, 41), "#35161f"); c:px(19, 39, "#5e2a3a")
c:fill(c:rect(43, 39, 45, 41), "#35161f"); c:px(43, 39, "#5e2a3a")
c:ground(32, 57, 17, 3.5, "#6a4528")
local t = c:save(D .. "img-redraw-full/aseprite/ph/flea-legs.aseprite", D .. "img-redraw-full/png/ph/flea-legs.png")
print(GV.report(t))
