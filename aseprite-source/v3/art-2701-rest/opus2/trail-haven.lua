-- trail-haven (32x32 trail map marker, Opus second pass). Landmark kind "haven": a safe stop where a gnome rests by
-- the fire, stays the night and buys from a little pantry. A snug cottage: thick golden thatch with a shaggy eave,
-- warm lavender fieldstone walls in courses, a round-topped plank door with a gold knob and a stone step, a round
-- window glowing with firelight, a stone chimney. Silhouette: a fat thatched A-frame, not the ferry's red gable.
-- quirk: the chimney smoke has puffed up into a little pink heart.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/_trail.lua")
local c = T.new("trail-haven")

local TH = { "#5e3a22", "#8a5a2a", "#b9813a", "#dba64e", "#f4cd6e", "#ffe7a0" } -- thatch deep..hi
local ST = { "#3e3656", "#5f5878", "#857e9c", "#a8a2ba", "#cbc6d6", "#e6e1ea" } -- fieldstone deep..hi
local WD = { "#51302b", "#864c33", "#b97a4a", "#e8b982" }
local GL = { "#d98322", "#f5b82e", "#ffe38a", "#fff4d6" }

-- chimney (behind the roof): fieldstone with a cap
for y = 7, 13 do for x = 20, 23 do
  local h = ST[4]
  if x == 23 then h = ST[2] elseif x == 20 then h = ST[5] end
  if (y == 9 or y == 12) and x > 20 then h = ST[2] end
  c:put(x, y, h)
end end
for x = 19, 24 do c:put(x, 7, x < 22 and ST[6] or ST[5]) end
c:put(24, 8, ST[2]) c:put(19, 8, ST[3]) for x = 20, 23 do c:put(x, 8, ST[1]) end -- cap underside

-- walls: fieldstone courses, lit left, shaded right, dark under the eave and at the foot
local wall = c:rect(4, 16, 25, 28)
wall:each(function(x, y)
  local k = (y - 16) // 3
  local off = (k % 2) * 3
  local mortar = ((y - 16) % 3 == 2) or ((x + off) % 6 == 0)
  local h
  if mortar then h = ST[2]
  else
    local top = ((y - 16) % 3 == 0) or ((x + off) % 6 == 1)
    h = top and ST[5] or ST[4]
    if x >= 22 then h = top and ST[4] or ST[3] end
  end
  if x == 25 and not mortar then h = ST[3] end
  c:put(x, y, h)
end)
for x = 4, 25 do c:put(x, 16, ST[1]) c:put(x, 17, (x % 3 == 0) and ST[1] or ST[2]) c:put(x, 28, ST[2]) end

-- round-topped plank door with a stone arch
local arch = c:rrect(5, 18, 12, 28, 3)
T.fill(c, arch, ST[6])
arch:each(function(x, y) if x == 12 or y == 28 then c:put(x, y, ST[3]) end end)
local door = c:rrect(6, 19, 11, 28, 2)
door:each(function(x, y)
  local h = WD[2]
  if x == 6 then h = WD[3] elseif x == 8 or x == 11 then h = WD[1] end
  if y == 19 and x > 6 then h = WD[1] end
  c:put(x, y, h)
end)
c:put(7, 20, WD[4]) c:put(7, 21, WD[3])
c:put(10, 24, GL[3]) c:put(10, 25, GL[1]) -- knob

-- round window glowing with firelight, wooden frame + cross mullion, sill
local frame = c:rrect(15, 18, 21, 24, 2)
T.fill(c, frame, WD[2])
frame:each(function(x, y) if x == 21 or y == 24 then c:put(x, y, WD[1]) end end)
local glass = c:rrect(16, 19, 20, 23, 1)
glass:each(function(x, y)
  local h = GL[3]
  if x + y > 39 then h = GL[2] end
  if x == 18 or y == 21 then h = WD[2] end
  c:put(x, y, h)
end)
c:put(16, 20, GL[4]) c:put(17, 19, GL[4]) c:put(17, 20, GL[4])
for x = 14, 22 do c:put(x, 25, x == 14 and WD[3] or (x == 22 and WD[1] or WD[3])) end
for x = 15, 22 do c:put(x, 26, ST[1]) end

-- stone step in front of the door
for x = 4, 13 do c:put(x, 29, x < 7 and ST[6] or ST[5]) c:put(x, 30, ST[3]) end
c:put(13, 29, ST[3]) c:put(13, 30, ST[2])

-- thatch roof: fat A-frame with a shaggy, overhanging eave; lit left slope, shade right; straw strokes
local roof = c:poly{ { 13, 4 }, { 16, 4 }, { 28, 16 }, { 28, 17 }, { 1, 17 }, { 1, 16 } }
roof:each(function(x, y)
  local lit = x < 14.5 + (y - 4) * 0.3
  local course = (y - 4) % 4          -- thatch laid in courses: each course has a lit lip and a dark underside
  local i = lit and 4 or 3
  if course == 0 then i = lit and 5 or 4 end
  if course == 3 then i = lit and 3 or 2 end
  if course == 1 and (x * 3 + y) % 5 == 0 then i = i - 1 end   -- straw strokes
  if course == 2 and (x * 3 + y) % 5 == 2 then i = i - 1 end
  if lit and not roof:has(x - 1, y) then i = 6 end
  if not lit and not roof:has(x + 1, y) then i = 2 end
  if y >= 16 then i = lit and 3 or 2 end
  if y == 17 then i = ((x % 2) == 0) and 1 or 2 end
  c:put(x, y, TH[i])
end)
-- shaggy bottom fringe
for x = 2, 28, 2 do c:put(x, 18, TH[1]) end
-- ridge cap
for x = 13, 16 do c:put(x, 4, x < 15 and TH[4] or TH[2]) c:put(x, 3, x < 15 and TH[2] or TH[1]) end
c:put(12, 5, TH[6]) c:put(11, 6, TH[6])

-- quirk: chimney smoke puffed up into a heart
T.art(c, 0, {
  "................................",
  "....................ab.ab.......",
  "...................abbbbbc......",
  "...................bbbbbbc......",
  "....................bbbcc.......",
  ".....................bc.........",
  "......................b.........",
}, { a = "#ffd6e2", b = "#f59ab4", c = "#d0688c" })

T.done(c)
