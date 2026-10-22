local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local stone = GV.ramp("#968f96")
local dark = GV.ramp("#6a6070")
local body = c:poly({ {19, 23}, {39, 23}, {43, 49}, {16, 49} })
c:build{
  { "handle", c:line({ {20, 28}, {14, 30}, {12, 36}, {14, 42}, {20, 44} }, 4), stone },
  { "body",   body, GV.ramp("#3f93b2") },
  { "spout",  c:line({ {39, 42}, {46, 26} }, 4), stone },
  { "rim",    c:rrect(16, 20, 41, 24, 2), dark },
  { "rose",   c:poly({ {42, 15}, {52, 23}, {48, 27}, {39, 20} }), dark },
}
c:part(c:line({ {22, 30}, {23, 38} }, 2), "#c8ecdc", { flat = true, gloss = false, contour = false, contact = false })
for _, d in ipairs({ {50, 33}, {52, 40}, {47, 46} }) do
  c:part(c:ellipse(d[1], d[2], 2, 2), GV.ramp("#8fcbd8"), { flat = true, gloss = false })
end
local t = c:save(O .. "aseprite/ico/ico-watering-can.aseprite", O .. "png/ico/ico-watering-can.png")
print(GV.report(t))
