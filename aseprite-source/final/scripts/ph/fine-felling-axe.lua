local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local wood = GV.ramp("#b6814d", { rim = "#d9a660", shade = "#8a4f2a" })
local steel = GV.ramp("#d6c9b6", { shade = "#8b8f96", deep = "#5b6470" })
local haft = c:line({ {17, 52}, {33, 13} }, 5)
haft:add(c:ellipse(18, 52, 3, 3))
local blade = c:poly({ {27,12}, {34,12}, {40,11}, {45,9}, {50,7}, {53,10}, {55,14}, {56,19}, {55,24}, {53,28}, {50,31},
  {47,28}, {43,25}, {38,23}, {33,22}, {27,22} })
local collar = c:line({ {24, 25}, {32, 28} }, 3)
c:build{
  { "haft", haft, wood },
  { "blade", blade, steel, { gloss = { 36, 14 } } },
  { "collar", collar, GV.ramp("#d0862a"), { flat = true } },
}
-- keen bit edge highlight along the outer curve
for _, p in ipairs({ {51,9}, {52,11}, {53,13}, {54,15}, {54,17}, {54,19}, {54,21} }) do c:px(p[1], p[2], "#fff3c8") end
c:ground(30, 57, 16, 3)
local t = c:save(O .. "aseprite/ph/fine-felling-axe.aseprite", O .. "png/ph/fine-felling-axe.png")
print(GV.report(t))
