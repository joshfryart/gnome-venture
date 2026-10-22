local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local sack = GV.ramp("#dcb06a")

-- grains peeking (behind mouth)
local grains = c:mask()
for _, g in ipairs({ {26, 17}, {29, 15}, {32, 16}, {35, 15}, {38, 17} }) do
  grains:add(c:rect(g[1] - 1, g[2] - 1, g[1] + 1, g[2] + 1))
end
local body = c:ellipse(32, 41, 18, 15)
body:add(c:poly({ {22, 30}, {42, 30}, {46, 36}, {18, 36} }))
local mouth = c:ellipse(31.5, 21, 12, 5)
-- zigzag frill notches on top edge
mouth:cut(c:poly({ {23, 16}, {27, 16}, {25, 19} }))
mouth:cut(c:poly({ {37, 16}, {41, 16}, {39, 19} }))
mouth:add(c:rrect(24, 22, 39, 27, 2))
local cinch = c:rrect(20, 25, 43, 29, 2)
local cordL = c:line({ {27, 29}, {25, 33}, {23, 39} }, 2)
local cordR = c:line({ {36, 29}, {39, 33}, {41, 38} }, 2)
local knots = c:rect(21, 39, 23, 41):add(c:rect(40, 38, 42, 40))

local p = c:build{
  { "grains", grains, "gold", { flat = true } },
  { "body", body, sack, { stitch = { side = "lit" } } },
  { "mouth", mouth, sack, { gloss = false } },
  { "cinch", cinch, GV.ramp("#5a3008"), { gloss = false } },
  { "cords", cordL:add(cordR), GV.ramp("#5a3008"), { flat = true } },
  { "knots", knots, GV.ramp("#5a3008"), { flat = true } },
}
-- grain emblem
for _, g in ipairs({ { 29.5, 44 }, { 35.5, 46 }, { 32, 50 } }) do
  c:spot(c:ellipse(g[1], g[2], 2, 1.5), "#f5cf6a", "#fff1c8")
end
local t = c:save(O .. "aseprite/ph/millet-seed.aseprite", O .. "png/ph/millet-seed.png")
print(GV.report(t))
