-- animals/silk_shelf : wooden shelf with leaves, silk curl and three cocoons
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local function leaf(x0, y0, x1, y1, w)
  -- pointed leaf between two points
  local m = c:mask()
  local L = math.sqrt((x1 - x0)^2 + (y1 - y0)^2)
  local ux, uy = (x1 - x0) / L, (y1 - y0) / L
  for y = 0, 63 do for x = 0, 63 do
    local t = (x - x0) * ux + (y - y0) * uy
    local d = -(x - x0) * uy + (y - y0) * ux
    if t >= 0 and t <= L and math.abs(d) <= w * math.sin(math.pi * t / L) then m:set(x, y) end
  end end
  return m
end

-- silk curl: wavy line
local silk = {}
for x = 18, 44, 2 do silk[#silk + 1] = { x, math.floor(17 + 2 * math.sin((x - 18) / 26 * 3 * math.pi) + 0.5) } end

c:build{
  { "frame", c:rect(11, 10, 52, 53), "wood" },
  { "back",  c:rect(15, 14, 48, 49), GV.ramp("#8a4f2a"), { gloss = false, rim = false } },
  { "shelf1", c:rect(15, 21, 48, 23), "wood", { gloss = false } },
  { "shelf2", c:rect(15, 33, 48, 35), "wood", { gloss = false } },
  { "silk",  c:line(silk, 2), "cream", { flat = true } },
  { "leaf1", leaf(17, 32, 31, 26, 3.5), "moss" },
  { "leaf2", leaf(46, 32, 33, 26, 3.5), "moss" },
  { "coc1",  c:ellipse(20, 43, 4.5, 6), "cream" },
  { "coc2",  c:ellipse(31.5, 43, 5, 6), "cream" },
  { "coc3",  c:ellipse(43, 43, 4.5, 6), "cream" },
}
-- leaf veins
c:fill(c:line({ { 19, 31 }, { 29, 27 } }, 1), "#4a8a3e")
c:fill(c:line({ { 44, 31 }, { 35, 27 } }, 1), "#4a8a3e")
-- cocoon silk wraps
for _, x in ipairs({ 20, 31, 43 }) do
  c:fill(c:line({ { x - 3, 43 }, { x + 3, 46 } }, 1):clip(c:ellipse(x + 0.5, 43, 3, 4.5)), "#f5b860")
end
c:stitch(c:rect(11, 10, 52, 53):cut(c:rect(15, 14, 48, 49)):add(c:rect(15, 50, 48, 53)))

local t = c:save(O .. "aseprite/animals/silk_shelf.aseprite", O .. "png/animals/silk_shelf.png")
print(GV.report(t))
