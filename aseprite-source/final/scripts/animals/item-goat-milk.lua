-- animals/item-goat-milk : pale tapered milk jug, wooden stopper, loop handle
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local milk = GV.ramp("#f4f1ea")
local cap  = GV.ramp("#c9a96e")

-- tapered body: narrow shoulders, wide rounded base
local body = c:poly({ {21, 22}, {44, 22}, {49, 50}, {15, 50} })
body:add(c:rrect(15, 40, 48, 57, 6))
body:add(c:rrect(20, 21, 44, 28, 3))
local label = c:rect(10, 35, 54, 45):clip(body)
local handle = c:line({ {43, 28}, {49, 29}, {52, 33}, {52, 39}, {49, 43}, {45, 45} }, 3)

c:build{
  { "handle", handle, milk },
  { "body",   body,   milk, { light = body } },
  { "label",  label,  GV.ramp("#fff3c8"), { gloss = false, contact = false } },
  { "neck",   c:rrect(23, 17, 41, 23, 1), cap, { gloss = false } },
  { "stopper", c:rrect(26, 10, 38, 18, 3), cap },
}
-- crease highlight down the jug's left (outside the label)
local crease = c:rect(24, 26, 25, 48):clip(body):cut(label)
c:fill(crease, "#d9d3c1")

-- stopper join seam + label hems
c:seam({ {24, 21}, {40, 21} })

-- label emblem: a small milk drop
c:paint({
  "..w..",
  ".www.",
  "wwwww",
  "wbwws",
  ".wss.",
}, 30, 38, { w = "#8fcbd8", b = "#c8ecdc", s = "#3f8fb0" })

c:ground(31.5, 58, 17, 1.5)
local t = c:save(O .. "aseprite/animals/item-goat-milk.aseprite", O .. "png/animals/item-goat-milk.png")
print(GV.report(t))
