local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- arrowhead blade: oval body plus a pointed tip
local blade = c:ellipse(32, 30, 13, 18)
blade:add(c:poly({ {32, 7}, {42, 20}, {22, 20} }))
blade:add(c:poly({ {32, 7}, {43, 20}, {32, 20} }))
-- backward-curled basal lobes
local lobes = c:poly({ {24, 38}, {14, 49}, {17, 51}, {28, 45} })
lobes:add(c:poly({ {40, 38}, {51, 49}, {48, 51}, {36, 45} }))
local stem = c:rect(31, 46, 33, 55)

c:build{
  { "stem",  stem,  GV.ramp("#4a8a3e"), { flat = true } },
  { "lobes", lobes, GV.ramp("#6a9a3a") },
  { "blade", blade, "moss", { gloss = { 22, 20 } } },
}
-- pale midrib
c:fill(c:rect(32, 13, 33, 46), "#a4b86a")
-- side veins (1 px diagonals rising outward)
for _, y in ipairs({ 22, 30, 38 }) do
  for i = 1, 5 do
    c:px(31 - i, y - math.floor(i * 0.7), "#4a8a3e")
    c:px(34 + i, y - math.floor(i * 0.7), "#4a8a3e")
  end
end

local t = c:save(O .. "aseprite/ph/sorrel.aseprite", O .. "png/ph/sorrel.png")
print(GV.report(t))
