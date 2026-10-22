local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tan = GV.ramp("#dcb06a")
local brown = GV.ramp("#a5663a")
local belly = c:ellipse(31.5, 40, 17, 14)
local foot = c:rrect(22, 51, 41, 56, 1)
local lid = c:ellipse(31.5, 25, 15, 8):cut(c:rect(0, 28, 63, 63))
lid:add(c:rrect(14, 25, 49, 30, 2))
local knob = c:ellipse(31.5, 15, 3.5, 3.5)
local badge = c:ellipse(27, 42, 6, 5):add(c:ellipse(36, 42, 6, 5))
badge:cut(c:rect(30, 37, 33, 38)):cut(c:rect(30, 46, 33, 47))
local p = c:build{
  { "foot",  foot,  tan, { gloss = false } },
  { "belly", belly, GV.ramp("#f1ece0") },
  { "badge", badge, tan, { gloss = false } },
  { "knob",  knob,  brown, { gloss = false } },
  { "lid",   lid,   tan },
}
for _, d in ipairs({ {24,40}, {27,42}, {24,44}, {28,45}, {35,40}, {38,42}, {35,44}, {39,45} }) do
  c:px(d[1], d[2], "#a5663a")
end
c:paint({ "..x", ".x.", "x..", ".x." }, 31, 40, { x = "#4a2c1a" })
c:seam({ {16, 28}, {47, 28} })
local t = c:save(O .. "aseprite/ph/peanut-seed.aseprite", O .. "png/ph/peanut-seed.png")
print(GV.report(t))
