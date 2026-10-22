local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- pointed-top teardrop: round bottom + tapering top
local blade = c:ellipse(31.5, 39, 19, 14)
blade:add(c:poly({ {14,36}, {20,24}, {26,15}, {32,8}, {38,15}, {44,24}, {50,36} }))
local p = c:build{
  { "stem", c:rrect(30, 50, 33, 56, 1), GV.ramp("#6a9a3a"), { gloss = false } },
  { "blade", blade, "moss", { gloss = { 22, 24 } } },
}
local V = "#2f5a2a"
local veins = c:line({ {31,52}, {31,15} }, 2)
veins:add(c:line({ {31,40}, {21,32} }, 2))
veins:add(c:line({ {32,32}, {42,24} }, 2))
veins:add(c:line({ {31,47}, {22,41} }, 2))
veins:add(c:line({ {32,45}, {42,38} }, 2))
c:fill(veins:clip(blade:shrink(3)), V)
-- bright lit edge on the spine
for y = 18, 50, 2 do c:px(31, y, "#a4b86a") end
local t = c:save(O .. "aseprite/ph/oregano.aseprite", O .. "png/ph/oregano.png")
print(GV.report(t))
