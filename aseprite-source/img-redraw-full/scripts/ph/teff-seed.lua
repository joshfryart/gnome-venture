local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local jar = c:rrect(16, 21, 47, 55, 7)
-- shoulders taper into the neck
jar:add(c:poly({ {20, 22}, {44, 22}, {40, 18}, {24, 18} }))
local p = c:build{
  { "jar",   jar, "#c8ecdc", { gloss = { 20, 27 } } },
  { "neck",  c:rect(23, 13, 40, 19), "#8fcbd8", { gloss = false } },
  { "cork",  c:rrect(24, 6, 39, 14, 2), "#d9a660", { gloss = { 27, 8 } } },
  { "grain", c:rrect(19, 40, 44, 53, 5), "#d9a660", { gloss = false, contact = false } },
}
-- cork specks
c:px(30, 10, "#8a4f2a"); c:px(35, 9, "#8a4f2a"); c:px(33, 12, "#8a4f2a")
-- grain texture
for _, q in ipairs({ {23,44},{28,46},{34,44},{39,47},{25,49},{31,50},{37,51},{41,43} }) do
  c:px(q[1], q[2], "#b07a45")
end
-- stalk
c:part(c:rect(31, 26, 32, 49), "#2f5a2a", { flat = true })
-- kernel pairs stepping down (3x5 beans), alternating pink and red
local pink, red = "#e46a9b", "#ae2a2a"
local function bean(x, y, col)
  c:part(c:ellipse(x + 1.5, y + 2.5, 2, 3), col, { gloss = false, contact = false })
end
bean(30, 21, pink)
bean(25, 27, red);  bean(35, 27, pink)
bean(24, 33, pink); bean(36, 33, red)
-- little twigs from stalk to beans
c:px(30, 30, "#2f5a2a"); c:px(33, 30, "#2f5a2a")
c:px(29, 36, "#2f5a2a"); c:px(30, 36, "#2f5a2a"); c:px(33, 36, "#2f5a2a"); c:px(34, 36, "#2f5a2a")

c:ground(31.5, 56, 15, 1.5)
local t = c:save(O .. "aseprite/ph/teff-seed.aseprite", O .. "png/ph/teff-seed.png")
print(GV.report(t))
