local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local blue = GV.ramp("#3f93b2")
local pale = GV.ramp("#f8eed2")
local whole = c:rect(16, 8, 48, 56)
local roof = c:poly({ {16, 28}, {24, 12}, {41, 12}, {49, 28} })
local drop = c:ellipse(32, 45, 5, 5)
drop:add(c:poly({ {27, 44}, {32, 36}, {33, 36}, {38, 44} }))
c:build{
  { "fin",  c:rect(23, 8, 41, 12), blue, { flat = true } },
  { "roof", roof, blue, { light = whole } },
  { "body", c:rect(16, 27, 48, 56), pale, { light = whole } },
  { "band", c:rect(16, 35, 48, 51), blue, { light = whole, gloss = { 19, 37 } } },
  { "drop", drop, pale, { gloss = false, bounce = false } },
}
for x = 24, 40 do c:px(x, 13, "#256a80") end
-- darker right slope: 3 px strip inside the right roof edge
for y = 15, 26 do
  local x0 = 40 + math.floor((y - 12) * 8 / 16)
  for x = x0 - 2, x0 do if roof:has(x, y) then c:px(x, y, "#2f6290") end end
end
c:px(30, 42, "#fff3c8"); c:px(30, 43, "#fff3c8"); c:px(31, 41, "#fff3c8")
c:seam({ {17, 27}, {47, 27} })
local t = c:save(O .. "aseprite/ico/ico-milk.aseprite", O .. "png/ico/ico-milk.png")
print(GV.report(t))
