local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local rod = c:line({ {14, 51}, {50, 10} }, 4)
local grip = c:line({ {10, 56}, {21, 43} }, 5)
local line = c:line({ {50, 10}, {54, 14}, {56, 20}, {56, 27}, {54, 32}, {51, 35} }, 2)
local float = c:ellipse(50.5, 39, 3.5, 3.5)
local reel = c:ellipse(25, 46, 6, 6)
c:build{
  { "line", line, GV.ramp("#d6c9b6"), { flat = true } },
  { "rod", rod, GV.ramp("#b6814d", { rim = "#f0d49a" }) },
  { "grip", grip, GV.ramp("#d9a660") },
  { "float", float, GV.ramp("#d6c9b6") },
  { "reel", reel, GV.ramp("#968f96") },
}
-- red cap on the float
c:fill(c:rect(48, 36, 53, 37):clip(float), "#d6322b")
c:fill(c:rect(49, 35, 52, 35):clip(float), "#d6322b")
-- reel hub and spoke
c:fill(c:rect(24, 45, 26, 47), "#5b6470")
c:px(24, 45, "#8b8f96")
c:fill(c:line({ {27, 49}, {29, 51} }, 1):clip(reel), "#5b6470")
-- guide wraps across the shaft
for _, t in ipairs({ 0.45, 0.65, 0.85 }) do
  local x, y = 14 + 36 * t, 51 - 41 * t
  c:fill(c:line({ {math.floor(x - 1.5), math.floor(y - 1.5)}, {math.floor(x + 1.5), math.floor(y + 1.5)} }, 1):clip(rod), "#8a4f2a")
end
c:ground(32, 57, 17, 3.5, "#6a4528")
local t = c:save(O .. "aseprite/ph/fine-fly-rod.aseprite", O .. "png/ph/fine-fly-rod.png")
print(GV.report(t))
