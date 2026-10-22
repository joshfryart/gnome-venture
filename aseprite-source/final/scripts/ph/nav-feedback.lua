local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- speech bubble with a tail curling down-left
local bubble = c:rrect(11, 11, 52, 41, 8)
bubble:add(c:poly({ {16, 38}, {29, 38}, {14, 53} }))
bubble:add(c:rect(14, 50, 16, 52))
local p = c:build{
  { "bubble", bubble, GV.ramp("#3f93b2"), { stitch = { side = "lit" } } },
}
-- three cream dots in a row (round 7px)
local dot = { "..ccc..", ".ccccc.", "ccccccc", "ccccccc", "ccccccc", ".ccccc.", "..ccc.." }
local sh  = { "..ccc..", ".ccccc.", "ccccccc", "cccccss", "ccccsss", ".cssss.", "..sss.." }
for _, x in ipairs({ 17, 28, 39 }) do
  c:paint(sh, x, 22, { c = "#f4f0e0", s = "#c9c5bc" })
  c:px(x + 2, 23, "#fff3c8")
end
local t = c:save(O .. "aseprite/ph/nav-feedback.aseprite", O .. "png/ph/nav-feedback.png")
print(GV.report(t))
