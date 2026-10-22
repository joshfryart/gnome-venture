local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "scene", bleed = "" }

local tile = c:rrect(3, 3, 60, 60, 7)
local function band(top)
  local m = c:mask()
  for x = 0, 63 do
    for y = math.floor(top(x) + 0.5), 63 do m:set(x, y) end
  end
  return m:clip(tile)
end

-- sky with hard bands
c:part(tile, "#a9d6ea", { flat = true, rim = false, contact = false })
c:bands(c:rect(4, 4, 59, 34), { "#9ccde4", "#a9d6ea", "#bfe2f0" })

-- sun
c:part(c:ellipse(48, 15, 5), "#f5cf6a", { outline = false, gloss = { 46, 13 }, contact = false, cres = 2, deep = 1 })
c:px(46, 13, "#fff1c8"); c:px(47, 13, "#fff1c8"); c:px(46, 14, "#fff1c8")

-- back and front meadows
local back = band(function(x) return 35 + 2 * math.sin(x / 7 + 0.5) end)
c:part(back, "moss", { outline = false, gloss = false, contact = false, cres = 3 })
local front = band(function(x) return 45 + 2 * math.sin(x / 6 + 3) end)
c:part(front, "#58a03e", { outline = false, gloss = false, cres = 4 })

-- grass blades
local blades = {
  { { 12, 55 }, { 12, 52 }, { 14, 50 } },
  { { 20, 57 }, { 21, 54 }, { 19, 52 } },
  { { 28, 52 }, { 28, 49 }, { 30, 47 } },
  { { 37, 56 }, { 38, 53 }, { 36, 51 } },
  { { 46, 57 }, { 46, 54 }, { 48, 52 } },
  { { 53, 52 }, { 54, 49 }, { 52, 47 } },
}
for _, b in ipairs(blades) do c:fill(c:line(b, 2):clip(front), "#2f5a2a") end

-- flowers: plus shapes with a centre
local function flower(x, y, petal, centre)
  c:paint({ ".p.", "pcp", ".p." }, x - 1, y - 1, { p = petal, c = centre })
end
flower(14, 41, "#e46a9b", "#f5cf6a")
flower(44, 50, "#e46a9b", "#f5cf6a")
flower(31, 55, "#e8a317", "#fff1c8")
flower(22, 50, "#f4f0e0", "#e8a317")
flower(38, 40, "#f4f0e0", "#e8a317")

local t = c:save(O .. "aseprite/ph/land-grassland.aseprite", O .. "png/ph/land-grassland.png")
print(GV.report(t))
