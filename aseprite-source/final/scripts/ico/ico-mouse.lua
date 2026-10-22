local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local fur = GV.ramp("#a38f80")
local cream = GV.ramp("#e6d2ae")

local head = c:ellipse(32, 30, 11.5, 11)
local ears = c:ellipse(19.5, 18.5, 6, 6):add(c:ellipse(44.5, 18.5, 6, 6))
local p = c:build{
  { "tail", c:line({ {44, 50}, {48, 52}, {52, 51}, {55, 48}, {55, 43}, {53, 40}, {50, 41}, {50, 44} }, 3), GV.ramp("#b79775"), { gloss = false } },
  { "ears", ears, fur, { gloss = false } },
  { "feet", c:ellipse(23.5, 54, 6, 3.5):add(c:ellipse(40.5, 54, 6, 3.5)), GV.ramp("#8f7060"), { gloss = false } },
  { "body", c:ellipse(32, 44, 15, 12), fur, { gloss = false } },
  { "belly", c:ellipse(32, 47.5, 8.5, 7), cream, { gloss = false, contour = false } },
  { "head", head, fur, { light = head:copy():add(ears) } },
  { "muzzle", c:ellipse(32, 35.5, 5.5, 5), cream, { gloss = false } },
}
-- inner ears, only where not covered by the head
c:fill(c:ellipse(19.5, 18.5, 3, 3):cut(head:grow(1)), "#e6d2ae")
c:fill(c:ellipse(44.5, 18.5, 3, 3):cut(head:grow(1)), "#e6d2ae")
-- nose
c:paint({ ".nnn.", "nnnnn", ".nnn." }, 30, 31, { n = "#2a1a10" })
c:px(31, 31, "#5e2a3a")
-- mouth
c:paint({ "n.n", ".n." }, 31, 36, { n = "#4a2c1a" })
-- eyes
c:eye(23, 23); c:eye(36, 23)
-- whiskers
c:line({ {14, 33}, {20, 33} }, 1); c:fill(c:line({ {14, 33}, {20, 33} }, 1), "#2a1a10")
c:fill(c:line({ {15, 37}, {20, 35} }, 1), "#2a1a10")
c:fill(c:line({ {44, 33}, {50, 33} }, 1), "#2a1a10")
c:fill(c:line({ {44, 35}, {49, 37} }, 1), "#2a1a10")
local t = c:save(O .. "aseprite/ico/ico-mouse.aseprite", O .. "png/ico/ico-mouse.png")
print(GV.report(t))
