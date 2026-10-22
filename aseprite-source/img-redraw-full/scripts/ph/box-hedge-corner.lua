-- ph/box-hedge-corner
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker", bleed = "rb" }
local box = GV.ramp("#58a03e", { rim = "#a4b86a", gloss = "#c8d77a", shade = "#4a8a3e", deep = "#2f5a2a" })

-- ground shadow in the inner corner of the L
c:fill(c:rect(40, 41, 63, 46):add(c:rect(41, 41, 46, 63)), "#6a4528")

-- puffs: far ends first, corner puff last (on top)
local parts, n = {}, 0
local function puff(x, y, gl)
  n = n + 1
  parts[#parts + 1] = { "p" .. n, c:ellipse(x, y, 8, 8), box, { gloss = gl or false } }
end
for _, x in ipairs({ 68, 61, 54, 47, 40 }) do puff(x, 32) end
for _, y in ipairs({ 68, 61, 54, 47, 40 }) do puff(32, y) end
puff(30, 31, { 26, 27 })
c:build(parts)

local t = c:save(O .. "aseprite/ph/box-hedge-corner.aseprite", O .. "png/ph/box-hedge-corner.png")
print(GV.report(t))
