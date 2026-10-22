local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local p = c:build{
  { "bot", c:ellipse(31.5, 45, 19, 6), GV.ramp("#a5663a"), { gloss = false } },
  { "mid", c:ellipse(31.5, 39.5, 19, 6), GV.ramp("#dcb06a"), { gloss = false } },
  { "top", c:ellipse(31.5, 33.5, 17, 5.5), "gold" },
  { "dip", c:ellipse(33.5, 32, 6, 3), GV.ramp("#f08a24"), { gloss = { 31, 30 } } },
}
local F = "#8a4f2a"
for _, d in ipairs({ {17, 43}, {24, 44}, {39, 44}, {20, 49}, {30, 50}, {41, 49}, {22, 38}, {44, 37} }) do
  c:px(d[1], d[2], F); c:px(d[1] + 1, d[2], F)
end
local t = c:save(O .. "aseprite/ph/cattail-fritters.aseprite", O .. "png/ph/cattail-fritters.png")
print(GV.report(t))
