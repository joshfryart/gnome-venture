local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local leaf = c:mask()
for y = 10, 54 do
  local w
  if y <= 36 then w = 20.5 * math.sin(math.pi / 2 * (y - 9) / 27) ^ 1.25
  else w = 20.5 * math.sqrt(math.max(0, 1 - ((y - 36) / 18.5) ^ 2)) end
  for x = math.floor(32 - w + 0.5), math.floor(31 + w + 0.5) do leaf:set(x, y) end
end
c:build{ { "leaf", leaf, "moss", { stitch = { side = "lit" } } } }
local v = GV.R.moss.deep
c:fill(c:line({ { 31, 17 }, { 31, 50 } }, 2), v)
c:fill(c:line({ { 31, 39 }, { 22, 31 } }, 2), v)
c:fill(c:line({ { 32, 31 }, { 40, 23 } }, 2), v)
c:fill(c:line({ { 32, 44 }, { 41, 36 } }, 2), v)
c:fill(c:line({ { 31, 47 }, { 24, 41 } }, 2), v)
local t = c:save(O .. "aseprite/ph/tea.aseprite", O .. "png/ph/tea.png")
print(GV.report(t))
