local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local pink = GV.ramp("#e89a8c")
-- four chunky tentacles, outer ones curl outward
local legs = c:line({ {19,38}, {15,45}, {12,50} }, 7)
legs:add(c:ellipse(11, 50, 4, 3.5))
legs:add(c:line({ {27,40}, {26,48}, {24,52} }, 6))
legs:add(c:ellipse(24, 51, 3.5, 3))
legs:add(c:line({ {36,40}, {37,48}, {39,52} }, 6))
legs:add(c:ellipse(39, 51, 3.5, 3))
legs:add(c:line({ {44,38}, {48,45}, {51,50} }, 7))
legs:add(c:ellipse(52, 50, 4, 3.5))
local head = c:ellipse(31.5, 28, 19, 17):cut(c:rect(0, 40, 63, 63))
head:add(c:rrect(13, 30, 50, 42, 5))
local p = c:build{
  { "legs", legs, pink, { cres = 2, deep = 1 } },
  { "head", head, pink },
}
-- suckers on outer tentacles
local S = "#c47a52"
for _, d in ipairs({ {14,44}, {11,48}, {48,44}, {51,48} }) do
  c:fill(c:rect(d[1], d[2], d[1]+1, d[2]+1), S)
end
c:eye(19, 26); c:eye(39, 26)
local t = c:save(O .. "aseprite/ico/ico-sea-creature.aseprite", O .. "png/ico/ico-sea-creature.png")
print(GV.report(t))
