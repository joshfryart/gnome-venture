local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- hide: central body, wavy top, four leg flaps
local hide = c:rrect(17, 19, 47, 45, 6)
hide:add(c:ellipse(24, 18, 5, 3)); hide:add(c:ellipse(32, 16, 5, 3)); hide:add(c:ellipse(40, 18, 5, 3))
hide:add(c:poly({ {19, 20}, {10, 15}, {11, 27}, {20, 31} }))
hide:add(c:poly({ {46, 20}, {55, 15}, {54, 27}, {45, 31} }))
hide:add(c:poly({ {19, 36}, {10, 42}, {14, 50}, {24, 44} }))
hide:add(c:poly({ {46, 36}, {55, 42}, {51, 50}, {41, 44} }))

-- pinked zig-zag hem along the bottom
local hem = c:mask()
for x = 22, 39, 4 do hem:add(c:poly({ {x, 44}, {x + 5, 44}, {x + 2.5, 50} })) end
hem:add(c:rect(22, 43, 43, 45))

local ramp = GV.ramp("#dcb06a", { rim = "#d9a660" })
c:build{
  { "hem",  hem,  GV.ramp("#b07a45"), { flat = true } },
  { "hide", hide, ramp, { stitch = true, gloss = { 21, 21 } } },
}

-- six bean spots, varied tilt
local beanA = { "xx..", "xxx.", "xxxx", ".xxx", "..xx" }
local beanB = { "..xx", ".xxx", "xxxx", "xxx.", "xx.." }
local beanC = { ".xx.", "xxxx", "xxxx", "xxxx", ".xx." }
c:spot(c:ascii(beanA, 24, 23)); c:spot(c:ascii(beanB, 31, 20)); c:spot(c:ascii(beanC, 40, 24))
c:spot(c:ascii(beanB, 23, 32)); c:spot(c:ascii(beanA, 38, 33)); c:spot(c:ascii(beanC, 30, 38))

local t = c:save(O .. "aseprite/ph/spotted-hide.aseprite", O .. "png/ph/spotted-hide.png")
print(GV.report(t))
