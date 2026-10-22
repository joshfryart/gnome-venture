local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- slab arms (angled quads)
local armL = c:poly({ {7,40}, {18,34}, {23,47}, {11,55} })
local armR = c:poly({ {57,40}, {46,34}, {41,47}, {53,55} })
local arms = armL:copy(); arms:add(armR)
-- body: wide arch with rounded shoulders, flat bottom
local body = c:rrect(14, 27, 49, 53, 7)
body:add(c:rect(14, 40, 49, 53))
-- head block: slight trapezoid
local head = c:poly({ {19,12}, {45,12}, {47,31}, {17,31} })
head = head:closed(1)
-- moss beans
local moss1 = c:ellipse(22, 39, 5, 3)
local moss2 = c:ellipse(42.5, 47, 4.5, 2)
-- tufts growing out of shoulders
local tuft = c:poly({ {13,31}, {14,24}, {16,29}, {18,23}, {20,30} })
tuft:add(c:ellipse(17, 31, 4, 2))
local tuftR = c:poly({ {43,30}, {46,24}, {48,29}, {50,26}, {51,32} })
tuftR:add(c:ellipse(47, 31, 4, 2))
-- sprig on head
local sprig = c:poly({ {41,13}, {44,6}, {48,4}, {47,9}, {44,13} })
sprig:add(c:poly({ {36,13}, {35,8}, {39,10}, {41,13} }))
local p = c:build{
  { "arms", arms, GV.ramp("#8f7060") },
  { "body", body, GV.ramp("#a38f80") },
  { "moss1", moss1, GV.ramp("#58a03e"), { flat = false } },
  { "moss2", moss2, GV.ramp("#58a03e") },
  { "tuftL", tuft, "moss" },
  { "tuftR", tuftR, "moss" },
  { "sprig", sprig, "moss", { flat = true } },
  { "head", head, GV.ramp("#e6d2ae") },
}
-- sockets: dark rim, then locked eyes
c:fill(c:rrect(22, 17, 30, 25, 1), "#2a1a10")
c:fill(c:rrect(34, 17, 42, 25, 1), "#2a1a10")
c:eye(24, 19); c:eye(36, 19)
-- calm small mouth
c:paint({ "mmmmmmm" }, 29, 27, { m = "#2a1a10" })
-- stone cracks on body
c:paint({ "k.", ".k", ".k" }, 30, 44, { k = "#6e5a52" })
c:paint({ ".k", "k." }, 25, 48, { k = "#6e5a52" })
c:ground(32, 56, 20, 2)
local t = c:save(O .. "aseprite/ph/creature-moss-golem.aseprite", O .. "png/ph/creature-moss-golem.png")
print(GV.report(t))
