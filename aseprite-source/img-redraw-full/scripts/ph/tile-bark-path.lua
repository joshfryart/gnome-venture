local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "scene" }

local GROUND, DEEP, SHADE, LIGHT, TOP, EDGE = "#a5663a", "#44281c", "#8c4a1a", "#dcb06a", "#ecc58a", "#7e4524"
c:fill(c:rect(0, 0, 63, 63), GROUND)

-- wrap-around stamp: chips crossing an edge continue on the opposite side
local function stamp(rows, x0, y0, legend)
  for j, row in ipairs(rows) do
    for i = 1, #row do
      local ch = row:sub(i, i)
      if legend[ch] then c:px((x0 + i - 1) % 64, (y0 + j - 1) % 64, legend[ch]) end
    end
  end
end

-- chip shapes: rounded bars, flat and tilted
local H4  = { ".xxx.", "xxxxx", ".xxx." }
local H6  = { ".xxxxx.", "xxxxxxx", ".xxxxx." }
local H5t = { ".tttt", "xxxxx", "xxxx." }                   -- light chip with a top highlight
local T1  = { "..xx", ".xxx", "xxx.", "xx.." }              -- rising tilt
local T2  = { "xx..", "xxx.", ".xxx", "..xx" }              -- falling tilt
local L6  = { ".tttt.", "xxxxxx", ".xxxx." }
local RIM = { ".eeee.", "e....e", ".eeee." }                -- ground-colour chip outline

local function chip(shape, x, y, col, top)
  stamp(shape, x, y, { x = col, t = top or col })
end

-- dark chips
chip(H4, 37, 2, DEEP); chip(T2, 18, 29, DEEP); chip(H6, 48, 44, DEEP); chip(T1, 9, 25, DEEP); chip(H4, 60, 14, DEEP)
-- mid chips
chip(H6, 15, 14, SHADE); chip(T1, 5, 53, SHADE); chip(H4, 1, 39, SHADE); chip(T2, 40, 28, SHADE)
chip(H4, 46, 20, SHADE); chip(H6, 28, 61, SHADE)            -- this one wraps to the top
-- light chips
chip(L6, 37, 52, LIGHT, TOP); chip(H5t, 26, 20, LIGHT, TOP); chip(H5t, 50, 33, LIGHT, TOP)
chip(L6, 61, 46, LIGHT, TOP); chip(H5t, 13, 5, LIGHT, TOP); chip(T1, 23, 8, LIGHT)
-- ground-colour chips with a darker rim
for _, p in ipairs{ {51, 24}, {9, 50}, {24, 55}, {43, 9}, {31, 38} } do stamp(RIM, p[1], p[2], { e = EDGE }) end
-- tiny crack lines
for _, p in ipairs{ {12, 20}, {44, 15}, {26, 46}, {55, 40}, {8, 58}, {35, 28}, {58, 2}, {2, 30} } do
  c:px(p[1], p[2], "#5e2f1e"); c:px(p[1] + 1, p[2], "#5e2f1e")
end

local t = c:save(D .. "img-redraw-full/aseprite/ph/tile-bark-path.aseprite",
                 D .. "img-redraw-full/png/ph/tile-bark-path.png")
print(GV.report(t))
