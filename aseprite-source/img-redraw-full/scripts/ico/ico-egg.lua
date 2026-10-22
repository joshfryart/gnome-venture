local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local egg = c:ellipse(31.5, 40, 18.5, 16)
egg:add(c:ellipse(31.5, 31, 14, 22))
egg:add(c:ellipse(31.5, 36, 17, 18))
local wood = GV.ramp("#d9a066", { gloss = "#ecc58a", shade = "#8a4f2a" })
local p = c:build{ { "egg", egg, wood, { gloss = false } } }
-- bold gloss streak on the upper left
local streak = c:line({ {27, 14}, {23, 19}, {21, 25}, {21, 30} }, 3):clip(egg)
c:fill(streak, "#ecc58a")
c:px(28, 13, "#fff1c8"); c:px(27, 14, "#fff1c8"); c:px(26, 15, "#fff1c8")
c:fill(c:rect(21, 33, 22, 34), "#ecc58a")
-- three speckle beans on the lower right
local sp = { "ssa", "sss", ".s." }
local legend = { s = "#a8582f", a = "#8a4f2a" }
c:paint({ ".ss", "sss", "ss." }, 38, 35, legend)
c:paint({ "ss.", "sss", ".ss" }, 42, 43, legend)
c:paint({ ".ss", "sss", "ss." }, 34, 47, legend)
local t = c:save(O .. "aseprite/ico/ico-egg.aseprite", O .. "png/ico/ico-egg.png")
print(GV.report(t))
