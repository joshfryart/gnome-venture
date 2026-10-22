local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local wood = GV.ramp("#b6814d", { gloss = "#f0d49a" })
local steel = GV.ramp("#cdd0d2", { shade = "#9a9ea6", deep = "#646a76", bounce = "#a8a29a" })
local handle = c:line({ {31, 16}, {46, 48} }, 6)
local head = c:ellipse(32, 31, 23, 20):cut(c:ellipse(32, 38, 21, 17)):cut(c:rect(0, 30, 63, 63))
head:cut(c:poly({ {52, 22}, {57, 22}, {57, 31}, {50, 31} }))   -- chipped right tip
local p = c:build{
  { "handle", handle, wood },
  { "head", head, steel },
}
local s1 = c:poly({ {50, 41}, {53, 40}, {56, 46}, {53, 47} })
local s2 = c:poly({ {13, 38}, {16, 40}, {12, 45}, {9, 44} })
c:part(s1, wood, { flat = true }); c:part(s2, wood, { flat = true })
c:px(50, 41, "#2a1a10"); c:px(9, 44, "#2a1a10")
local crackH = c:line({ {28, 10}, {33, 14}, {29, 18}, {32, 22} }, 2)
c:fill(crackH:clip(p.head.m), "#2a1a10")
local crackW = c:line({ {33, 20}, {36, 25}, {34, 29}, {39, 34}, {37, 38}, {42, 43}, {41, 46} }, 1)
c:fill(crackW:clip(p.handle.m), "#2a1a10")
c:ground(38, 54, 13, 1.5)
local t = c:save(O .. "aseprite/ph/broken-fine-rock-hammer.aseprite", O .. "png/ph/broken-fine-rock-hammer.png")
print(GV.report(t))
