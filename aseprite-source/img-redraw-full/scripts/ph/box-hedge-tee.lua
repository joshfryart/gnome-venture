local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker", bleed = "lrb" }
-- scalloped T: bar of overlapping r8 circles every 6 px, stem down the middle
local hedge = c:mask()
for x = -3, 67, 7 do hedge:add(c:ellipse(x, 28.5, 4.5)); hedge:add(c:ellipse(x + 3, 36.5, 4.5)) end
hedge:add(c:rect(0, 28, 63, 37))
for y = 41, 70, 7 do hedge:add(c:ellipse(27.5, y, 4.5)); hedge:add(c:ellipse(36.5, y + 3, 4.5)) end
hedge:add(c:rect(27, 32, 37, 63))
-- soil shadow peeking out lower-right
local soil = c:rect(0, 37, 63, 44):add(c:rect(36, 37, 45, 63))
local p = c:build{
  { "soil", soil, "#7a4a1f", { flat = true } },
  { "hedge", hedge, GV.ramp("#58a03e"), { gloss = { 8, 27 } } },
}
-- lumpy leaf tufts: small rim-colour clumps on the lit side of each scallop
local hi = "#b8d47c"
for x = -5, 63, 7 do c:paint({ ".hh.", "hh.." }, x, 25, { h = hi }) end
for y = 39, 63, 7 do c:paint({ "h.", "hh", ".h" }, 25, y, { h = hi }) end
-- dark leaf nicks between lobes for texture
local dk = "#3f7a34"
for x = 3, 62, 7 do c:px(x, 34, dk); c:px(x + 1, 35, dk) end
for y = 45, 62, 7 do c:px(34, y, dk); c:px(35, y + 1, dk) end
local t = c:save(O .. "aseprite/ph/box-hedge-tee.aseprite", O .. "png/ph/box-hedge-tee.png")
print(GV.report(t))
