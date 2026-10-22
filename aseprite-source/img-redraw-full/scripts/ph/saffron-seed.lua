local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = GV.ramp("#c8ecdc")
local jar = c:rrect(14, 24, 50, 56, 8)
jar:add(c:ellipse(32, 26, 15, 5))
local neck = c:rect(23, 16, 41, 23)
local cork = c:rrect(21, 6, 43, 17, 3)
local p = c:build{
  { "neck", neck, glass, { gloss = false } },
  { "jar", jar, glass, { gloss = { 19, 29 } } },
  { "cork", cork, "wood" },
}
-- cork cut line
for x = 23, 41 do c:px(x, 13, "#a8582f") end
-- neck lip ring
for x = 24, 40 do c:px(x, 20, "#8fcbd8") end
-- saffron threads: thick crescent swoosh
local sw = c:ellipse(28, 34, 19, 16):cut(c:ellipse(25, 29, 19, 15))
sw:clip(jar:shrink(3))
local th = GV.ramp("#f08a24")
c:part(sw, th, { gloss = false, contact = false })
-- thread strands (darker lines along swoosh)
c:line({ {19, 41}, {24, 46}, {31, 48}, {38, 45}, {43, 40} }, 1):each(function(x, y) if sw:has(x, y) then c:px(x, y, "#ae2a2a") end end)
-- berry dots
c:spot(c:ellipse(26, 45, 2, 2), "#ae2a2a", "#ff9158")
c:spot(c:ellipse(33, 46, 2, 2), "#ae2a2a", "#ff9158")
c:spot(c:ellipse(40, 43, 2, 2), "#ae2a2a", "#ff9158")
-- glass shine stripe
for y = 32, 44 do c:px(18, y, "#f4f0e0"); c:px(19, y, "#f4f0e0") end
c:px(19, 47, "#f4f0e0"); c:px(19, 48, "#f4f0e0")
c:ground(32, 57, 15, 1.5)
local t = c:save(O .. "aseprite/ph/saffron-seed.aseprite", O .. "png/ph/saffron-seed.png")
print(GV.report(t))
