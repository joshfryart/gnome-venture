local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- seed heap peeking over the crate top
local heap = c:ellipse(20, 26, 3, 3):add(c:ellipse(26, 24, 3, 3)):add(c:ellipse(32, 23, 3, 3))
  :add(c:ellipse(38, 24, 3, 3)):add(c:ellipse(44, 26, 3, 3))
local crate = c:rect(12, 27, 52, 54)
local postL = c:rect(12, 27, 17, 54)
local postR = c:rect(47, 27, 52, 54)
local petals = c:mask()
petals:add(c:ellipse(32, 9, 3, 4))
petals:add(c:ellipse(26.5, 13, 4, 3)):add(c:ellipse(37.5, 13, 4, 3))
petals:add(c:ellipse(28.5, 19, 3, 3.5)):add(c:ellipse(35.5, 19, 3, 3.5))
local p = c:build{
  { "heap", heap, GV.ramp("#e0501f"), { cres = 2, gloss = false } },
  { "crate", crate, "wood", { light = crate } },
  { "postL", postL, GV.ramp("#8a4f2a"), { gloss = false } },
  { "postR", postR, GV.ramp("#8a4f2a"), { gloss = false } },
  { "lily", petals, GV.ramp("#f4f0e0"), { cres = 2, gloss = { 30, 8 } } },
  { "centre", c:ellipse(32, 14.5, 2.5, 2.5), "gold", { flat = true } },
}
-- seed glints
for _, x in ipairs({ 19, 25, 31, 37, 43 }) do c:px(x, x == 31 and 22 or ((x == 25 or x == 37) and 23 or 25), "#ff9158") end
-- slat gaps between posts
for _, y in ipairs({ 34, 41, 48 }) do c:fill(c:rect(18, y, 46, y + 1), "#5e2f1e") end
-- nails on posts
for _, y in ipairs({ 30, 51 }) do c:px(14, y, "#d9a660"); c:px(49, y, "#d9a660") end
c:ground(32, 57, 21, 1.5)
local t = c:save(O .. "aseprite/ph/white-ginger-lily-seed.aseprite", O .. "png/ph/white-ginger-lily-seed.png")
print(GV.report(t))
