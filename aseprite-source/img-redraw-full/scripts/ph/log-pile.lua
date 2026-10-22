local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local bark = GV.ramp("#8a4f2a", { rim = "#a8582f" })
local face = GV.ramp("#d9a660")
-- log centres: top, middle row, bottom row (back to front = top first)
local logs = {
  { 31, 19, 4, true },
  { 24, 31, 3 }, { 38, 31, 4 },
  { 17, 43, 4 }, { 31, 43, 3 }, { 45, 43, 4 },
}
local whole = c:mask()
for _, L in ipairs(logs) do whole:add(c:ellipse(L[1], L[2], 7, 7)) end

for i, L in ipairs(logs) do
  local x, y = L[1], L[2]
  c:part(c:ellipse(x, y, 7, 7), bark, { light = whole, gloss = false })
  c:part(c:ellipse(x - 0.5, y - 0.5, 4.5, 4.5), face,
    { gloss = L[4] and { x - 3, y - 3 } or false, contact = false, bounce = false })
  -- growth ring and core
  local ring = c:ellipse(x, y, L[3], L[3]):edge()
  if L[4] then ring:cut(c:rect(x - 4, y - 4, x - 2, y - 3)) end
  c:fill(ring, "#b07a45")
  c:fill(c:rect(x - 1, y - 1, x, y), "#8a4f2a")
end

-- binding strap across the middle row
c:seam({ { 15, 31 }, { 47, 31 } }, { free = true })
c:button(30, 29)

local t = c:save(O .. "aseprite/ph/log-pile.aseprite", O .. "png/ph/log-pile.png")
print(GV.report(t))
