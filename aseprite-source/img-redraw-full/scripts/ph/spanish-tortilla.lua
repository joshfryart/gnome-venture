local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- plate
local plate = c:ellipse(31.5, 44, 22, 9)
-- tortilla volume: top ellipse swept down 6 px
local topE = c:ellipse(31.5, 34, 18, 8)
local slab = topE:copy()
for d = 1, 6 do slab:add(topE:shift(0, d)) end
-- wedge cut: apex near centre, opening to lower right
local W = c:poly({ {31, 34}, {60, 33}, {60, 60}, {46, 60} })
-- visible cut wall hangs 6 px below the left cut edge
local wall = c:poly({ {31, 34}, {46, 60}, {46, 66}, {31, 40} }):clip(slab):clip(W)
local side = slab:copy():cut(W)
local top = topE:copy():cut(W)

local p = c:build{
  { "plate", plate, GV.ramp("#f1ece0") },
  { "side",  side,  "wood" },
  { "wall",  wall,  GV.ramp("#f5cf6a"), { gloss = false } },
  { "top",   top,   "gold", { gloss = { 21, 30 } } },
}
-- layered potato lines on the cut wall
for _, dy in ipairs({ 2, 4 }) do
  wall:each(function(x, y)
    if not wall:has(x, y - 1) then
      if wall:has(x, y + dy) then c:px(x, y + dy, "#fff1c8") end
    end
  end)
end
-- browned mottling beans on the top
c:spot(c:ellipse(26, 31, 2, 1), "#d0862a", false)
c:spot(c:ellipse(35, 29, 2, 1), "#d0862a", false)
c:spot(c:ellipse(22, 36, 1.5, 1), "#d0862a", false)
c:spot(c:ellipse(30, 38, 2, 1), "#d0862a", false)

local t = c:save(D .. "img-redraw-full/aseprite/ph/spanish-tortilla.aseprite",
                 D .. "img-redraw-full/png/ph/spanish-tortilla.png")
print(GV.report(t))
