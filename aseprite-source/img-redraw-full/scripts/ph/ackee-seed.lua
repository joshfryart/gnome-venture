local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- jar: rounded body with sloped shoulders up to a neck
local jar = c:rrect(13, 22, 50, 56, 7)
jar:add(c:poly({ {17, 23}, {21, 16}, {43, 16}, {47, 23} }))
local cork = c:rrect(18, 7, 45, 18, 3)
cork:add(c:rrect(16, 15, 47, 19, 2))
local label = c:rrect(18, 25, 45, 50, 6)
local pod = c:ellipse(31.5, 37, 8, 10)
pod:add(c:poly({ {28, 27}, {31, 23}, {35, 27} }))
local flag = c:poly({ {45, 6}, {53, 12}, {44, 14} })

local p = c:build{
  { "jar",   jar,   "cream" },
  { "label", label, "#f4f0e0", { gloss = false, bounce = false } },
  { "pod",   pod,   "moss" },
  { "cork",  cork,  "wood" },
  { "flag",  flag,  "#2e5a2c", { flat = true } },
}
-- green label border
c:fill(label:copy():cut(label:shrink(2)), "#7ab55c")
-- pod split showing a dark seed
c:fill(c:ellipse(31.5, 40, 3, 3.5), "#35161f")
c:px(30, 38, "#5e2a3a")
c:fill(c:rect(31, 31, 32, 35), "#f2e4c0")
-- pod dots
c:px(26, 33, "#58a03e"); c:px(27, 33, "#58a03e")
c:px(36, 44, "#58a03e"); c:px(37, 44, "#58a03e")
c:px(26, 42, "#58a03e"); c:px(26, 43, "#58a03e")
-- cork pores
c:px(23, 11, "#8a4f2a"); c:px(30, 13, "#8a4f2a"); c:px(37, 10, "#8a4f2a"); c:px(41, 14, "#8a4f2a")
-- flag string
c:line({ {44, 12}, {42, 15} }, 1)
c:px(43, 13, "#4a2c1a"); c:px(42, 14, "#4a2c1a")
-- base dots
for _, x in ipairs({ 25, 31, 37 }) do c:fill(c:rect(x, 52, x + 2, 54), "#8c4a1a") end
-- cork / jar join seam
c:seam({ {17, 19}, {46, 19} })

local t = c:save(O .. "aseprite/ph/ackee-seed.aseprite", O .. "png/ph/ackee-seed.png")
print(GV.report(t))
