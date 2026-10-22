local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- lens leaf on the diagonal: build in rotated coordinates
local cx, cy = 33, 31
local L, W = 30, 13            -- half-length, half-width
local blade = c:mask()
local s2 = math.sqrt(0.5)
for y = 0, 63 do for x = 0, 63 do
  local dx, dy = x + 0.5 - cx, y + 0.5 - cy
  local u = (dx - dy) * s2      -- along axis toward upper right
  local v = (dx + dy) * s2      -- across
  if math.abs(u) <= L then
    local t = u / L
    local half = W * (1 - t * t)
    if t > 0 then half = W * (1 - t ^ 1.6) * (1 - t * 0.15) end
    if math.abs(v) <= half then blade:set(x, y) end
  end
end end

local p = c:build{
  { "stem",  c:line({ {9,56}, {16,49} }, 3), "#2f5a2a", { flat = true } },
  { "blade", blade, "#58a03e", { gloss = { 22, 24 } } },
}
c:fill(c:line({ {28,40}, {36,46} }, 3):clip(blade:shrink(2)), "#4a8a3e")
c:fill(c:line({ {33,33}, {26,25} }, 3):clip(blade:shrink(2)), "#4a8a3e")
c:fill(c:line({ {41,30}, {47,34} }, 3):clip(blade:shrink(2)), "#4a8a3e")
c:fill(c:line({ {15,49}, {44,20} }, 4):clip(blade:shrink(1)), "#f8eed2")

local t = c:save(O .. "aseprite/ico/ico-leaf.aseprite", O .. "png/ico/ico-leaf.png")
print(GV.report(t))
