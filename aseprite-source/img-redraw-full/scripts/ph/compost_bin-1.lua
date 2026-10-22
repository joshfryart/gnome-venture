local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local heap = c:ellipse(32, 34, 20, 24):cut(c:rect(0, 35, 63, 63))
heap:add(c:ellipse(24, 22, 9, 8)):add(c:ellipse(41, 21, 9, 8))
heap:cut(c:rect(0, 35, 63, 63))
local wood = GV.ramp("#a5663a")
local slat = GV.ramp("#b6814d", { rim = "#f0d49a" })
local p = c:build{
  { "heap", heap, GV.ramp("#44281c") },
  { "box",  c:rrect(12, 31, 52, 55, 2), wood },
}
c:part(c:rrect(12, 34, 52, 37, 1), slat, { gloss = false, cres = 1, deep = 0 })
c:part(c:rrect(12, 42, 52, 45, 1), slat, { gloss = false, cres = 1, deep = 0 })
c:part(c:rrect(12, 50, 52, 53, 1), slat, { gloss = false, cres = 1, deep = 0 })
c:part(c:rrect(8, 28, 13, 56, 2), slat, { cres = 2 })
c:part(c:rrect(51, 28, 56, 56, 2), slat, { cres = 2 })
-- scraps on the heap
c:part(c:ellipse(24, 20, 2.5, 2), GV.ramp("#58a03e"), { flat = true })
c:part(c:ellipse(37, 15, 2.5, 2), GV.ramp("#e0501f"), { flat = true })
c:part(c:ellipse(32, 25, 2, 2), GV.ramp("#e8a317"), { flat = true })
c:part(c:poly({ {41, 28}, {46, 21}, {49, 22}, {48, 28} }), GV.ramp("#7ab55c"), { flat = true })
c:px(43, 26, "#4a8a3e"); c:px(44, 25, "#4a8a3e"); c:px(45, 24, "#4a8a3e")
-- crumbs
for _, q in ipairs({ {20,28}, {29,14}, {44,16}, {27,30}, {36,30}, {18,23} }) do c:px(q[1], q[2], "#2a1a10") end
-- nails at post ends
for _, y in ipairs({ 35, 43, 51 }) do c:px(11, y + 1, "#5e2f1e"); c:px(53, y + 1, "#5e2f1e") end
c:ground(32, 58, 24, 2)
local t = c:save(O .. "aseprite/ph/compost_bin-1.aseprite", O .. "png/ph/compost_bin-1.png")
print(GV.report(t))
