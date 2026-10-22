local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local arch = c:line({ {15,37}, {16,28}, {19,20}, {24,14}, {29,11}, {34,11}, {39,14}, {44,20}, {47,28}, {48,37} }, 3)
local tray = c:poly({ {10,35}, {54,35}, {48,56}, {16,56} })
local inner = c:poly({ {14,37}, {50,37}, {49,40}, {15,40} })
local p = c:build{
  { "arch", arch, "wood", { gloss = { 20, 21 } } },
  { "tray", tray, "wood", { gloss = { 16, 43 } } },
  { "inner", inner, "#5e2f1e", { flat = true, rim = false } },
  { "band1", c:rect(12, 44, 51, 45), "gold", { flat = true } },
  { "band2", c:rect(14, 50, 49, 51), "gold", { flat = true } },
}
c:seam({ {12, 44}, {51, 44} }, { gap = "#b8661a" })
c:seam({ {14, 50}, {49, 50} }, { gap = "#b8661a" })
for _, x in ipairs({ 22, 32, 42 }) do
  c:fill(c:rect(x, 41, x, 43), "#8a4f2a"); c:fill(c:rect(x, 46, x, 49), "#8a4f2a"); c:fill(c:rect(x, 52, x, 55), "#8a4f2a")
end
c:button(13, 31); c:button(46, 31)
c:ground(32, 57, 18, 1.5)
local t = c:save(O .. "aseprite/ph/harvest-trug.aseprite", O .. "png/ph/harvest-trug.png")
print(GV.report(t))
