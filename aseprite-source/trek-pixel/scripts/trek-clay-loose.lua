-- trek-clay-loose: dry crumbling mud, two deep cracks and three loose crumbs (family 3)
local ROOT = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(ROOT .. "gvlib/gvlib.lua")
local OUT = ROOT .. "trek-pixel/"
local NAME = "trek-clay-loose"

local mud_base, mud_shade, soil900, soil300 = "#7a4a1f", "#5c3520", "#3d2a1c", "#c9a96e"
local so_bounce, so_gloss, umber2 = "#8b5a31", "#d9ba7c", "#4a2c1a"

local c = GV.canvas{ w = 42, h = 42, mode = "scene" }
c:fill(c:rect(0, 0, 41, 41), mud_base)

-- Cracks: 2 px soil900 polylines with a 1 px so_bounce lit lip on the right side
local cracks = c:mask()
cracks:add(c:line({ {8,10}, {16,17}, {13,25}, {22,31} }, 2))
cracks:add(c:line({ {30,8}, {24,17}, {29,24} }, 2))
c:fill(cracks, soil900)
cracks:each(function(x, y)
  if not cracks:has(x + 1, y) then c:px(x + 1, y, so_bounce) end
end)

-- Flat dust specks
for _, p in ipairs({ {6,22}, {35,14}, {18,36} }) do c:px(p[1], p[2], mud_shade) end

-- Crumbs: raised 3x3 soil300 lumps, umber2 L outline on the lower-right, glint upper-left
local function crumb(x0, y0)
  c:fill(c:rect(x0, y0, x0 + 2, y0 + 2), soil300)
  c:px(x0, y0, so_gloss)
  for i = 0, 3 do c:px(x0 + 3, y0 + i, umber2); c:px(x0 + i, y0 + 3, umber2) end
end
crumb(11, 30)
crumb(30, 29)
crumb(23, 11)

local t = c:save(OUT .. "aseprite/" .. NAME .. ".aseprite", OUT .. "png/" .. NAME .. ".png")
print(NAME .. ": " .. GV.report(t))
