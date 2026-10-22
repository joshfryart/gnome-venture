local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local clay = GV.ramp("#8f7060")
local pts = { {12,43}, {14,37}, {18,32}, {22,30}, {27,33}, {31,37}, {35,36}, {39,32}, {43,29}, {47,28} }
local body = c:line(pts, 10)
body:add(c:ellipse(12, 43, 5, 5))
local stripe = body:copy():cut(body:shift(0, 3)):cut(body:shift(2, 2))
stripe = stripe:grow(1):clip(body):cut(body:shift(0, 4))
local head = c:ellipse(50.5, 23.5, 6.5, 6.5)
local p = c:build{
  { "body", body, clay, { stitch = false } },
  { "stripe", stripe, GV.ramp("#c4925f"), { flat = true } },
  { "head", head, clay },
}
local groove = "#44281c"
local g = c:line({ {16,35}, {19,42} }, 2):add(c:line({ {27,30}, {29,37} }, 2)):add(c:line({ {38,31}, {41,38} }, 2))
c:fill(g:clip(body), groove)

c:eye(51, 20, true)
c:ground(29, 50, 20, 1.5)
local t = c:save(D .. "img-redraw-full/aseprite/ph/creature-clay-crawler.aseprite", D .. "img-redraw-full/png/ph/creature-clay-crawler.png")
print(GV.report(t))
