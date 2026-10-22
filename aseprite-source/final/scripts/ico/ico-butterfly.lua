local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
-- upper wings: big lobes tilted up and out
local ul = c:ellipse(19, 22, 11, 9):add(c:ellipse(14, 17, 6, 5)):add(c:rect(22, 24, 30, 33))
local ur = c:ellipse(44, 22, 11, 9):add(c:ellipse(49, 17, 6, 5)):add(c:rect(33, 24, 41, 33))
-- lower wings: rounded drops
local ll = c:ellipse(22, 43, 8, 8):add(c:rect(24, 34, 30, 40))
local lr = c:ellipse(41, 43, 8, 8):add(c:rect(33, 34, 39, 40))
local ember = GV.ramp("#f08a24")
local ember2 = GV.ramp("#e0501f")
local all = ul:copy():add(ur):add(ll):add(lr)
local p = c:build{
  { "ll", ll, ember2, { light = all } },
  { "lr", lr, ember2, { light = all } },
  { "ul", ul, ember, { light = all, gloss = { 11, 14 } } },
  { "ur", ur, ember, { light = all, gloss = false } },
}
-- spots
c:spot(c:ellipse(18, 24, 3, 3)); c:spot(c:ellipse(45, 24, 3, 3))
c:spot(c:ellipse(21, 45, 2, 2)); c:spot(c:ellipse(42, 45, 2, 2))
-- feelers with clubs
c:limb({ {30, 17}, {27, 12}, {25, 9} }, 2)
c:limb({ {33, 17}, {36, 12}, {38, 9} }, 2)
c:part(c:rrect(22, 5, 25, 8, 1), "dusk", { flat = true })
c:part(c:rrect(38, 5, 41, 8, 1), "dusk", { flat = true })
-- body and head
c:part(c:ellipse(31.5, 37, 3, 13), "dusk", { gloss = false })
c:part(c:ellipse(31.5, 21, 5, 4.5), "dusk", { gloss = { 29, 18 } })
c:eye(28, 20, true); c:eye(33, 20, true)
local t = c:save(O .. "aseprite/ico/ico-butterfly.aseprite", O .. "png/ico/ico-butterfly.png")
print(GV.report(t))
