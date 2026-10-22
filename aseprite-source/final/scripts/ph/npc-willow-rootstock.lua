local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
local tan, cream, pink = GV.ramp("#dcb06a"), GV.ramp("#f8eed2"), GV.ramp("#f6b8cf")
local purple, blue = GV.ramp("#7a5cc0"), GV.ramp("#3f93b2")

local earL = c:poly({ {27,40}, {22,22}, {23,8}, {27,2}, {32,4}, {35,16}, {35,40} })
local earR = c:poly({ {45,40}, {45,16}, {48,4}, {53,2}, {57,8}, {58,22}, {53,40} })
local inL = c:poly({ {28,36}, {25,22}, {26,10}, {28,6}, {31,8}, {33,18}, {33,36} })
local inR = c:poly({ {47,36}, {47,18}, {49,8}, {52,6}, {54,10}, {55,22}, {52,36} })
local body = c:rrect(7, 77, 72, 99, 12)
local apron = c:poly({ {26,85}, {54,85}, {59,100}, {21,100} })
local head = c:ellipse(39.5, 55, 22, 19.5)
local muzzle = c:ellipse(39.5, 65, 9, 6)
local nose = c:ellipse(39.5, 60.5, 2.5, 1.5)
local band = c:ellipse(39.5, 62, 27, 22):cut(c:ellipse(39.5, 67, 27, 22)):clip(head)
local knot = c:ellipse(59, 45, 3.5, 3.5)
local tails = c:poly({ {59,46}, {66,53}, {63,55}, {58,49} }):add(c:poly({ {60,46}, {67,47}, {66,50}, {60,49} }))

c:build{
  { "earL", earL, tan }, { "earR", earR, tan },
}
c:part(inL, pink, { flat = true }); c:part(inR, pink, { flat = true })
c:build{
  { "body", body, purple, { stitch = { side = "lit" } } },
  { "apron", apron, cream },
  { "head", head, tan },
  { "muzzle", muzzle, cream, { gloss = false } },
  { "nose", nose, "#d9667f", { flat = true } },
  { "band", band, blue },
  { "tails", tails, blue, { flat = true } },
  { "knot", knot, GV.ramp("#256a80"), { gloss = false } },
}
-- collar V
c:fill(c:line({ {31,78}, {36,84} }, 2):cut(apron), "#4e3a8a")
c:fill(c:line({ {48,78}, {43,84} }, 2):cut(apron), "#4e3a8a")
-- apron straps up over the shoulders
c:fill(c:line({ {27,85}, {23,77} }, 2), cream.base)
c:fill(c:line({ {52,85}, {56,77} }, 2), cream.base)
c:seam({ {23,88}, {57,88} })
c:button(37, 90)
-- face
c:eye(28, 51); c:eye(46, 51)
c:paint({ "..u..", "..u..", "u.u.u", ".u.u." }, 37, 62, { u = "#8a4234" })
for _, y in ipairs({ 63, 66 }) do
  c:fill(c:line({ {20, y - 1}, {28, y} }, 1), cream.shade)
  c:fill(c:line({ {51, y}, {59, y - 1} }, 1), cream.shade)
end
local t = c:save(O .. "aseprite/ph/npc-willow-rootstock.aseprite", O .. "png/ph/npc-willow-rootstock.png")
print(GV.report(t))
