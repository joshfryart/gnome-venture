local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local blade = GV.ramp("#d6c9b6")
local wood = GV.ramp("#b6814d", { rim = "#f0d49a" })
local function handleM(ex, ey) return c:line({ {32, 34}, {ex, ey} }, 6):add(c:ellipse(ex + 0.5, ey + 0.5, 4, 3.5)) end
-- back piece: right blade -> left handle
c:part(handleM(18, 52), wood, {})
c:part(c:poly({ {49,10},{47,6},{44,7},{29,32},{35,38} }), blade, { pale = true })
-- front piece: left blade -> right handle
c:part(handleM(45, 52), wood, {})
c:part(c:poly({ {15,10},{17,6},{20,7},{35,32},{29,38} }), blade, { pale = true })
-- inner cutting edges
c:fill(c:line({ {20, 9}, {32, 30} }, 1), "#968f96")
c:fill(c:line({ {44, 9}, {37, 21} }, 1), "#968f96")
c:part(c:ellipse(32, 34, 3.5), GV.ramp("#968f96"), { gloss = { 31, 32 } })
c:ground(32, 58, 17, 2)
local t = c:save(O .. "aseprite/ph/fine-secateurs.aseprite", O .. "png/ph/fine-secateurs.png")
print(GV.report(t))
