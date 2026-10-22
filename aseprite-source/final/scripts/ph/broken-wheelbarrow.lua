local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local woodL = GV.ramp("#b6814d")
local tray = c:poly({ {10,20}, {43,20}, {36,40}, {17,40} })
local p = c:build{
  { "handle", c:line({ {38,23}, {52,16} }, 4), woodL },
  { "leg",    c:line({ {31,37}, {41,44} }, 4), woodL },
  { "legb",   c:line({ {45,47}, {50,50} }, 4), woodL },
  { "tray",   tray, GV.ramp("#8c4a1a") },
  { "wheel",  c:ellipse(20, 45, 6.5), GV.ramp("#4a2c1a") },
  { "hub",    c:ellipse(20, 45, 2.5), GV.ramp("#a5663a"), { flat = true } },
  { "stub",   c:poly({ {28,50}, {35,48}, {36,51}, {29,53} }), woodL, { flat = true } },
}
-- plank lines
for _, y in ipairs({ 26, 31, 36 }) do
  c:fill(c:line({ {10,y}, {44,y} }, 1):clip(p.tray.m:shrink(1)), "#5e2f1e")
end
-- crack through the tray from the lip
c:fill(c:line({ {29,20}, {33,26}, {27,32}, {31,39} }, 2):clip(p.tray.m), "#2a1a10")
c:fill(c:rect(28, 20, 31, 21), "#2a1a10")
-- splintered ends of the snapped leg
c:px(42, 43, "#ecc58a"); c:px(43, 45, "#ecc58a"); c:px(44, 47, "#ecc58a")
c:seam({ {12, 22}, {27, 22} })
c:ground(30, 53, 16, 1.5)
local t = c:save(O .. "aseprite/ph/broken-wheelbarrow.aseprite", O .. "png/ph/broken-wheelbarrow.png")
print(GV.report(t))
