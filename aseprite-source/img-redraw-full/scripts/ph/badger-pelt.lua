local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
-- body of the hide with four leg corners
local pelt = c:poly({ {14,15},{50,15},{58,22},{56,27},{49,32},{49,37},{57,44},{55,49},{46,52},{18,52},{9,49},{7,44},{15,37},{15,32},{8,27},{6,22} })
-- scalloped top and bottom edges
for _, x in ipairs({19, 25, 39, 45}) do pelt:add(c:ellipse(x, 15, 3, 2)) end
for _, x in ipairs({22, 28, 36, 42}) do pelt:add(c:ellipse(x, 52, 3, 2)) end
for _, x in ipairs({17, 24, 40, 47}) do pelt:cut(c:ellipse(x+3.5, 54.5, 1.5, 1.5)) end
local head = c:ellipse(32, 13, 6, 4.5)
local p = c:build{
  { "head", head, GV.ramp("#8a4f2a") },
  { "pelt", pelt, "wood", { gloss = {13, 21} } },
}
-- dark central stripe running onto the head
local stripe = c:rect(29, 10, 34, 50):clip(pelt:copy():add(head))
-- flank flecks
c:fill(c:rect(19, 26, 22, 27), "#5e2f1e")
c:fill(c:rect(40, 32, 43, 33), "#5e2f1e")
c:fill(c:rect(23, 42, 26, 43), "#5e2f1e")
c:fill(c:rect(39, 43, 42, 44), "#5e2f1e")
-- edge fur tufts along top
for _, x in ipairs({17, 22, 38, 43, 48}) do c:px(x, 18, "#d9a660"); c:px(x+1, 17, "#d9a660") end
c:stitch(p.pelt.m, { side = "lit" })
c:fill(stripe, "#5e2f1e")
c:fill(c:rect(29, 10, 29, 50):clip(stripe), "#8a4f2a")
c:fill(c:rect(34, 10, 34, 50):clip(stripe), "#3e2014")
local t = c:save(O .. "aseprite/ph/badger-pelt.aseprite", O .. "png/ph/badger-pelt.png")
print(GV.report(t))
