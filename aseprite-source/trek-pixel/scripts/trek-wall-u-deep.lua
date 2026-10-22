-- trek-wall-u-deep: core of a thick underground wall, darker tan with slump bands and embedded pebbles (42x42, opaque)
local R = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(R .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 42, h = 42, mode = "scene" }
local WL = { gloss = "#e6cf98", base = "#c9a96e", bounce = "#b08a55", shade = "#9a6b3f", deep = "#7a4a1f" }
local SUDEEP = "#33221a"
local WAVE = { 0, -1, -1, 0, 1, 1, 0 }

-- strata centred y = 6, 16, 27, 37 (period 21), wave by x mod 7
for y = 0, 41 do for x = 0, 41 do
  local o, ly = WAVE[x % 7 + 1], y % 21
  local col = WL.shade
  if ly == 6 + o or ly == 16 + o then col = WL.deep
  elseif ly == 5 + o or ly == 15 + o then col = WL.base
  elseif ly == 4 + o or ly == 14 + o then col = WL.bounce end
  c:px(x, y, col)
end end

-- embedded pebbles 4x3: base body, gloss upper-left, deep L lower-right, no umber
for _, p in ipairs({ {9,10},{29,20},{15,31} }) do
  local x, y = p[1], p[2]
  for j = 0, 2 do for i = 0, 3 do c:px(x + i, y + j, WL.base) end end
  c:px(x, y, WL.shade); c:px(x + 3, y, WL.shade)            -- round the top corners
  c:px(x + 1, y, WL.gloss)
  for i = 1, 3 do c:px(x + i, y + 2, WL.deep) end
  c:px(x + 3, y + 1, WL.deep)
  c:px(x, y + 2, WL.shade)
end
-- root hairs hanging from strata lines
for _, p in ipairs({ {22,6},{22,7},{22,8},{23,9},  {6,28},{6,29},{7,30},{7,31} }) do c:px(p[1], p[2], WL.deep) end
c:px(34, 9, SUDEEP); c:px(12, 22, SUDEEP)

local P = R .. "trek-pixel/"
print(GV.report(c:save(P .. "aseprite/trek-wall-u-deep.aseprite", P .. "png/trek-wall-u-deep.png")))
