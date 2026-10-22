local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local burlap = GV.ramp("#c9a96e")
local twine = GV.ramp("#7a4a1f")
local plum = GV.ramp("#7a5cc0")
-- lumpy slumped body, heavier to the lower right
local body = c:ellipse(31.5, 41, 18, 14)
body:add(c:ellipse(36, 45, 15, 11))
body:add(c:ellipse(25, 44, 12, 10))
body:add(c:poly({{21,22},{43,22},{48,34},{16,34}}))
-- ragged flared top, two leaning points
local top = c:poly({{24,24},{19,12},{23,14},{26,9},{30,15},{33,13},{38,6},{40,14},{46,11},{41,24}})
local p = c:build{
  { "top", top, burlap, { cres = 3 } },
  { "body", body, burlap, { stitch = { side = "lit" } } },
  { "tie", c:rrect(21, 22, 43, 25, 1), twine, { flat = true } },
  { "knot", c:rrect(30, 21, 34, 26, 1), twine },
  { "tail1", c:line({{30,26},{27,31}}, 2), twine, { flat = true } },
  { "tail2", c:line({{34,26},{38,30}}, 2), twine, { flat = true } },
  { "fruit", c:ellipse(32, 42, 8, 7.5):add(c:ellipse(32, 36, 4, 3)), plum },
  { "leaf", c:poly({{33,33},{37,29},{40,30},{37,34}}), "leaf", { flat = true } },
}
-- weave marks
c:paint({ "ww" }, 20, 38, { w = "#9a6b3f" })
c:paint({ "ww" }, 44, 40, { w = "#9a6b3f" })
c:paint({ "ww" }, 22, 50, { w = "#9a6b3f" })
c:paint({ "ww" }, 41, 52, { w = "#9a6b3f" })
c:paint({ "w", "w" }, 27, 15, { w = "#9a6b3f" })
-- stem on quince
c:px(32, 33, "#5e2f1e"); c:px(32, 32, "#5e2f1e")
-- patch stitches round the fruit
c:seam({ {22,42},{24,35},{28,32},{36,32},{40,35},{42,42},{40,49},{32,52},{24,49},{22,42} }, { free = true })
c:ground(32, 57, 17, 2.5)
local t = c:save(O .. "aseprite/ph/quince-seed.aseprite", O .. "png/ph/quince-seed.png")
print(GV.report(t))
