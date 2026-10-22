local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- crescent head: arched top edge, thickness tapering to points, tips curving down
local head = c:mask()
for x = 10, 54 do
  local u = (x - 32) / 22
  local top = 13 + 13 * u * u
  local th = math.max(2, 9 * (1 - u * u) ^ 0.6)
  for y = math.floor(top + 0.5), math.floor(top + th + 0.5) do head:set(x, y) end
end
local handle = c:line({ { 33, 20 }, { 46, 49 } }, 6)
local band = c:rect(28, 24, 42, 26):clip(handle:copy())
local p = c:build{
  { "handle", handle, "#b6814d" },
  { "band", band, "#6a6070", { flat = true } },
  { "head", head, "#8c4a1a" },
}
c:seam({ { 31, 25 }, { 40, 25 } }, { on = 2, off = 1 })
local t = c:save(O .. "aseprite/ph/rock-pick.aseprite", O .. "png/ph/rock-pick.png")
print(GV.report(t))
