local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 48, h = 48, mode = "icon" }

local function leaf(bx, by, tx, ty, W)
  local dx, dy = tx - bx, ty - by
  local L = math.sqrt(dx * dx + dy * dy)
  local nx, ny = -dy / L, dx / L
  local a, b = {}, {}
  for i = 0, 12 do
    local t = i / 12
    local w = (W / 2) * (math.sin(math.pi * t) ^ 0.7) * (1 - 0.25 * t)
    local px, py = bx + dx * t, by + dy * t
    a[#a + 1] = { px + nx * w, py + ny * w }
    table.insert(b, 1, { px - nx * w, py - ny * w })
  end
  for _, p in ipairs(b) do a[#a + 1] = p end
  return c:poly(a)
end

local ground = c:rrect(14, 34, 33, 37, 2)
local stem = c:rect(23, 16, 25, 35)
local L = leaf(24, 31, 12, 21, 9)
local R = leaf(24, 25, 35, 14, 9)
local T = leaf(24, 18, 20, 10, 7)
c:build{
  { "ground", ground, "#7a4a1f" },
  { "stem", stem, "#4a8a3e", { flat = true } },
  { "left", L, "#7ab55c", { cres = 2 } },
  { "right", R, "#7ab55c", { cres = 2 } },
  { "top", T, "#a4b86a", { cres = 2 } },
}
-- veins
c:fill(c:line({ { 21, 29 }, { 15, 24 } }, 1):clip(L:shrink(1)), "#a4b86a")
c:fill(c:line({ { 27, 23 }, { 32, 18 } }, 1):clip(R:shrink(1)), "#a4b86a")
local t = c:save(O .. "aseprite/stops/herb.aseprite", O .. "png/stops/herb.png")
print(GV.report(t))
