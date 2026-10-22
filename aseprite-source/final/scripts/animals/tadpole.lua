local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- tapering curled tail: sweeps down then right, tip flicks up
local tail = c:line({ {36, 36}, {41, 41} }, 7)
tail:add(c:line({ {41, 41}, {45, 45} }, 6))
tail:add(c:line({ {45, 45}, {49, 47} }, 5))
tail:add(c:line({ {49, 47}, {52, 48} }, 4))
tail:add(c:line({ {52, 48}, {54, 46} }, 3))

local body = c:ellipse(26.5, 31, 16, 13.5)

c:build{
  { "tail", tail, "#4a8a3e", { light = body:copy():add(tail) } },
  { "body", body, GV.ramp("#7ab55c", { shade = "#4a8a3e", deep = "#2f5a2a" }) },
  { "bub1", c:ellipse(50, 14, 3), GV.ramp("#c8ecdc"), { flat = true } },
  { "bub2", c:ellipse(54, 22, 2), GV.ramp("#c8ecdc"), { flat = true } },
}
c:px(49, 13, "#fff3c8")
c:eye(14, 23); c:eye(23, 23)
-- smile
c:paint({ "m.....m", ".mmmmm." }, 15, 34, { m = "#2a1a10" })
local t = c:save(O .. "aseprite/animals/tadpole.aseprite", O .. "png/animals/tadpole.png")
print(GV.report(t))
