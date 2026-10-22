local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tan = GV.ramp("#c9a96e")
local sack = c:rrect(15, 22, 49, 53, 10)
local neck = c:poly({ { 25, 14 }, { 40, 14 }, { 43, 25 }, { 22, 25 } })
for _, x in ipairs({ 27, 31, 35, 39 }) do neck:del(x, 14); neck:del(x, 15); neck:del(x - 1, 14) end
local p = c:build{
  { "sack", sack, tan, { stitch = true } },
  { "neck", neck, tan },
  { "twine", c:rrect(21, 22, 43, 25, 1), GV.ramp("#8c4a1a") },
}
c:part(c:rrect(30, 21, 34, 26, 1), GV.ramp("#8c4a1a"), { flat = true })
c:fill(c:line({ { 31, 27 }, { 29, 31 } }, 2), "#6a3a1a")
c:fill(c:line({ { 34, 27 }, { 36, 30 } }, 2), "#6a3a1a")
c:seam({ { 19, 30 }, { 19, 50 } })
local clove = c:line({ { 21, 46 }, { 25, 40 }, { 31, 36 }, { 38, 34 }, { 42, 35 } }, 5)
clove:add(c:ellipse(43.5, 34.5, 5, 5))
c:part(clove, GV.ramp("#8c4a1a"), { light = clove })
c:fill(c:line({ { 24, 43 }, { 28, 39 }, { 33, 37 }, { 38, 36 } }, 1), "#44281c")
for _, d in ipairs({ { 42, 31 }, { 45, 33 }, { 42, 35 } }) do c:fill(c:rect(d[1], d[2], d[1] + 2, d[2] + 2), "#44281c") end
c:part(c:line({ { 21, 47 }, { 19, 50 } }, 3), "moss", { flat = true })
local t = c:save(O .. "aseprite/ph/clove-seed.aseprite", O .. "png/ph/clove-seed.png")
print(GV.report(t))
