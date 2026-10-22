-- trek-wall-o-deep: heart of a thick open wall, one step darker than the auto-sheet interior (42x42, opaque)
local R = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(R .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 42, h = 42, mode = "scene" }
local SN = { rim = "#b3b2b0", base = "#8b8f96", shade = "#5b6470", deep = "#3c4252" }
local INK, MOSS8 = "#2b2b2b", "#2f5a2a"

-- same skeleton as trek-wall-o-auto (period 21): mortar rows 0,10,20; course A joints 0,10,20; course B joints 5,15
local function mortar(lx, ly)
  if ly == 0 or ly == 10 or ly == 20 then return true end
  if ly <= 9 then return lx == 0 or lx == 10 or lx == 20 end
  return lx == 5 or lx == 15
end
for y = 0, 41 do for x = 0, 41 do
  local lx, ly = x % 21, y % 21
  local col
  if mortar(lx, ly) then
    col = (x == 0 or y == 0 or x == 41 or y == 41) and SN.shade or SN.deep   -- tile-edge mortar like the sheet interior
  elseif ly == 1 or ly == 11 then col = SN.base                               -- stone top row
  elseif ly == 9 or ly == 19 then col = SN.deep                               -- stone bottom row
  else col = SN.shade end
  c:px(x, y, col)
end end

-- lit pits: 3x3 discs (plus shape) with a 1 px rim at the lit top
for _, p in ipairs({ {7,5},{27,13},{15,25},{33,35} }) do
  local x, y = p[1], p[2]
  for _, o in ipairs({ {1,0},{0,1},{1,1},{2,1},{1,2} }) do c:px(x + o[1], y + o[2], SN.base) end
  c:px(x + 1, y, SN.rim); c:px(x, y + 1, SN.rim)
  c:px(x + 2, y + 2, SN.deep)
end
for _, p in ipairs({ {18,6},{37,18},{8,34} }) do c:px(p[1], p[2], SN.deep) end
for y = 34, 35 do for x = 12, 14 do c:px(x, y, MOSS8) end end
for _, p in ipairs({ {26,3},{26,4},{27,5},{27,6} }) do c:px(p[1], p[2], INK) end

local P = R .. "trek-pixel/"
print(GV.report(c:save(P .. "aseprite/trek-wall-o-deep.aseprite", P .. "png/trek-wall-o-deep.png")))
