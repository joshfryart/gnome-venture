-- trek-chasm-2: a drop seen from the cliff, three stepped ledges, a falling pebble, a dull gleam (family 3)
local ROOT = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(ROOT .. "gvlib/gvlib.lua")
local OUT = ROOT .. "trek-pixel/"
local NAME = "trek-chasm-2"

local ch = { gloss = "#2d6479", rim = "#24556b", base = "#143645", shade = "#0e2433", deep = "#091623" }
local su_deep = "#33221a"

local c = GV.canvas{ w = 42, h = 42, mode = "scene" }
c:fill(c:rect(0, 0, 41, 41), ch.base)

-- Ledge band: 3 rows, top row lit (ch_rim), 2 rows ch_shade; the right end steps down
-- in a 2 px staircase (row 0 ends x1-4, row 1 ends x1-2, row 2 ends x1). The lit row
-- follows the staircase so the top face of every step catches the light.
local function ledge(x0, x1, y)
  for r = 0, 2 do
    local xe = x1 - (2 - r) * 2
    for x = x0, xe do c:px(x, y + r, ch.shade) end
  end
  for x = x0, x1 - 4 do c:px(x, y, ch.rim) end
  for x = x1 - 3, x1 - 2 do c:px(x, y + 1, ch.rim) end
  for x = x1 - 1, x1 do c:px(x, y + 2, ch.rim) end
end
ledge(6, 34, 9)
ledge(9, 31, 17)
ledge(12, 28, 25)

-- the bottom: a ch_deep slot under band 3 with a dull gleam
c:fill(c:rect(16, 30, 25, 33), ch.deep)
c:px(20, 32, ch.gloss); c:px(21, 32, ch.gloss)

-- falling pebble, just past the end of the top ledge, with a 3 px motion tick above it
c:fill(c:rect(34, 14, 36, 16), su_deep)
c:px(34, 14, ch.gloss)
for y = 10, 12 do c:px(35, y, ch.rim) end

-- speckles
for _, p in ipairs({ {5,16}, {36,22}, {10,35} }) do c:px(p[1], p[2], ch.shade) end

local t = c:save(OUT .. "aseprite/" .. NAME .. ".aseprite", OUT .. "png/" .. NAME .. ".png")
print(NAME .. ": " .. GV.report(t))
