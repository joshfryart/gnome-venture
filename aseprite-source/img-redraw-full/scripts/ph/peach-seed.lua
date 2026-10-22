local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local wood = "wood"
local post = GV.ramp("#8a4f2a")

local crate = c:rrect(12, 25, 52, 55, 3)
local p = c:build{
  { "pole", c:rect(48, 5, 49, 25), post, { flat = true } },
  { "flag", c:poly({ {48,5}, {48,14}, {39,9} }), GV.ramp("#58a03e"), { gloss = false } },
  { "pod", c:poly({ {18,30}, {20,18}, {27,11}, {36,9}, {43,12}, {45,20}, {42,30} }), GV.ramp("#f08a24") },
  { "crate", crate, wood, { light = crate } },
  { "postL", c:rect(12, 25, 16, 55), post, { light = crate, gloss = false } },
  { "postR", c:rect(48, 25, 52, 55), post, { light = crate, gloss = false } },
}
-- slat gaps
for _, y in ipairs({ 33, 40, 47 }) do
  c:fill(c:rect(17, y, 47, y + 1), "#5e2f1e")
end
-- grain ticks
c:px(22, 35, "#8a4f2a"); c:px(38, 43, "#8a4f2a"); c:px(30, 51, "#8a4f2a"); c:px(41, 30, "#8a4f2a")
-- blossoms
local bl = { {23,18}, {31,13}, {37,19} }
for _, b in ipairs(bl) do
  c:paint({ ".pp.", "pccp", "pccp", ".pp." }, b[1], b[2], { p = "#e46a9b", c = "#f6b8cf" })
  c:px(b[1]+1, b[2]+1, "#fff3c8")
end
-- stalk
c:fill(c:line({ {19,27}, {16,31} }, 2), "#2e5a2c")
c:seam({ {17, 27}, {47, 27} })
c:button(29, 26)
c:ground(32, 56, 19, 1.5)
local t = c:save(O .. "aseprite/ph/peach-seed.aseprite", O .. "png/ph/peach-seed.png")
print(GV.report(t))
