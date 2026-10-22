local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local tan = GV.ramp("#dcb06a")
local dark = GV.ramp("#a5663a")
local cream = GV.ramp("#f8eed2")

local feet = c:ellipse(21, 54, 5, 2.5):add(c:ellipse(39, 54, 5, 2.5))
local ears = c:poly({ {17,24},{15,9},{27,17} }):add(c:poly({ {35,17},{47,9},{45,24} }))

c:build{
  { "tail",  c:ellipse(48, 48, 4, 4), dark },
  { "feet",  feet, dark },
  { "body",  c:ellipse(31, 43, 16, 13), tan },
  { "belly", c:ellipse(31, 47, 9, 8), cream, { gloss = false } },
  { "ears",  ears, tan, { gloss = false } },
  { "head",  c:ellipse(31, 28, 14, 12), tan },
  { "muzzle", c:ellipse(31, 33, 6, 4), cream, { gloss = false } },
}
-- body spots (on tan only)
for _, s in ipairs({ {19,40},{43,42},{22,50},{40,50} }) do
  c:fill(c:rect(s[1]-1, s[2]-1, s[1]+1, s[2]+1), "#a5663a")
end
-- inner ears
c:fill(c:poly({ {18,20},{17,13},{23,17} }), "#e46a9b")
c:fill(c:poly({ {39,17},{45,13},{44,20} }), "#e46a9b")
-- lynx tufts
c:fill(c:rect(15, 5, 16, 10), "#2a1a10")
c:fill(c:rect(46, 5, 47, 10), "#2a1a10")
-- eyes
c:eye(22, 23); c:eye(36, 23)
-- nose and mouth
c:paint({ "nnnnn", ".nnn.", "..n.." }, 29, 30, { n = "#2a1a10" })
c:paint({ "m...m.m...m", ".mmm...mmm." }, 26, 33, { m = "#4a2c1a" })

local t = c:save(O .. "aseprite/ico/ico-cat.aseprite", O .. "png/ico/ico-cat.png")
print(GV.report(t))
