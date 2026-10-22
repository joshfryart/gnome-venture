local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local glass = GV.ramp("#d4ecdc", { rim = "#c8ecdc" })
local jar = c:rrect(14, 21, 50, 56, 9)
jar:add(c:rrect(22, 15, 42, 24, 2))
local cork = c:rrect(21, 7, 43, 16, 2)
local seed = c:ellipse(32, 42, 8, 8)
local sprout = c:line({ {32,34},{32,28} }, 2)

local p = c:build{
  { "jar",   jar,   glass, { gloss = { 18, 26 } } },
  { "cork",  cork,  GV.ramp("#d9a660", { shade = "#b07a45" }) },
  { "seed",  seed,  GV.ramp("#a4b86a", { shade = "#7ab55c" }) },
  { "sprout", sprout, GV.ramp("#4a8a3e"), { flat = true } },
}
-- leaf up-right
c:fill(c:poly({ {34,29},{37,25},{41,24},{40,27},{36,30} }), "#4a8a3e")
c:fill(c:poly({ {35,28},{38,25},{40,25} }), "#7ab55c")
-- neck lip line
c:fill(c:rect(23, 23, 41, 23), "#a4c8c0")
-- cork texture dots
c:px(26, 10, "#b07a45"); c:px(31, 12, "#b07a45"); c:px(37, 10, "#b07a45"); c:px(35, 13, "#b07a45")
-- label dots
for _, x in ipairs({ 26, 32, 38 }) do c:fill(c:rect(x - 1, 52, x + 1, 54), "#a8582f") end

local t = c:save(O .. "aseprite/ph/bluebell-seed.aseprite", O .. "png/ph/bluebell-seed.png")
print(GV.report(t))
