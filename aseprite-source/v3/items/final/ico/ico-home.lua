-- ico-home (final pass, Opus). A narrow gnome cottage with a steep gable: scalloped clay-tile roof (6 tones, lit left
-- slope / shaded right slope, dark lap line under every row), wooden bargeboards, a rubble-stone chimney, cream
-- plaster walls with timber corner posts, an arched plank door (grain, iron straps, gold knob), two mullioned windows
-- with glass glints, a round attic window, stone footing and doorstep. AO under the eaves and round the door recess.
-- quirk: a little bluebird perches on the left bargeboard.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA5_4.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new("ico-home")
local ROOF = { "#5a1a30", "#8a2236", "#b8323a", "#dc4a3c", "#f27450", "#ffa47a" }
local PL   = { "#8a6a6a", "#b39488", "#d4b8a0", "#ead2b4", "#f8e6c8", "#fff4dc" }
local WD   = { "#3e2422", "#5e3628", "#864c33", "#a86a42", "#c98e5a", "#e8b982" }
local STN  = { "#35344e", "#4e4e68", "#6e6e86", "#9292a6", "#b8b8c8", "#dcdae4" }
local GL   = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }
local GOLD = { "#8f4a1f", "#f5b82e", "#ffe38a" }
local INK, CR = A.INK, A.CREAM
local roT, plT, wdT, stT, glT = A.tok("roof"), A.tok("plaster"), A.tok("wood"), A.tok("stone"), A.tok("glass")

c:groundShadow(31, 54, 24, 2)

-- chimney (behind the roof): rubble stones
local chim = c:rect(37, 11, 42, 24)
chim:each(function(x, y)
  local row = (y - 11) // 3
  local off = (row % 2) * 2
  local bx = (x - 37 + off) % 4
  local by = (y - 11) % 3
  local t = x >= 41 and 3 or (x == 37 and 5 or 4)
  if by == 2 or bx == 3 then t = 2 end
  c:put(x, y, STN[t], stT)
end)
for x = 36, 43 do c:put(x, 10, x < 41 and STN[6] or STN[4], stT) c:put(x, 11, STN[2], stT) end

-- walls
local wall = c:rect(17, 32, 45, 50)
local wn = {}
wall:each(function(x, y) wn[K(x, y)] = { G.norm(0, 0, 1) } end)
local wb = {}
wall:each(function(x, y) if y <= 35 then wb[K(x, y)] = (y <= 33) and -2 or -1 end end)
local widx = A.shade(c, wall, wn, PL, { tok = plT, bias = wb, amb = 0.1, tilt = { 31, 41, 16, 0.25 } })
-- plaster texture: a few hairline dents
for _, p in ipairs({ { 21, 46 }, { 22, 46 }, { 40, 37 }, { 41, 38 }, { 25, 37 } }) do A.step(c, widx, PL, p[1], p[2], -1, plT) end
-- timber corner posts + sill beam
for y = 32, 50 do
  c:put(17, y, WD[5], wdT) c:put(18, y, WD[3], wdT)
  c:put(44, y, WD[3], wdT) c:put(45, y, WD[2], wdT)
  if y % 5 == 2 then c:put(18, y, WD[2], wdT) c:put(45, y, WD[1], wdT) end
end
-- footing: stone blocks
for y = 48, 50 do for x = 17, 45 do
  local off = (y == 49) and 3 or 0
  local bx = (x - 17 + off) % 6
  local t = (y == 48) and 5 or (y == 49 and 4 or 3)
  if bx == 5 or y == 50 then t = 2 end
  if x >= 40 then t = max(1, t - 1) end
  c:put(x, y, STN[t], stT)
end end

-- door: arched plank door in a dark recess
local door = c:rrect(27, 38, 35, 47, 4):add(c:rect(27, 42, 35, 47))
local recess = door:grow(1):cut(door):clip(c:rect(0, 0, 63, 47))
recess:each(function(x, y) c:put(x, y, x < 31 and WD[2] or WD[1], wdT) end)
door:each(function(x, y)
  local plank = (x - 27) % 3
  local t = plank == 0 and 5 or (plank == 1 and 4 or 3)
  if x >= 33 then t = t - 1 end
  if y <= 39 then t = t - 1 end
  if (X.hash(x, y, 3) < 0.12) and plank ~= 0 then t = t - 1 end
  c:put(x, y, WD[max(1, t)], wdT)
end)
for x = 27, 35 do c:put(x, 41, STN[2], stT) c:put(x, 45, STN[2], stT) end -- iron straps
c:put(28, 41, STN[5], stT) c:put(28, 45, STN[5], stT)
c:put(33, 43, GOLD[2], wdT) c:put(34, 43, GOLD[1], wdT) c:put(33, 42, GOLD[3], wdT) -- knob
-- doorstep
for x = 26, 36 do c:put(x, 51, x < 34 and STN[5] or STN[4], stT) c:put(x, 52, STN[2], stT) end
c:put(26, 51, STN[6], stT)

-- windows
local function window(x0, y0)
  for y = y0 - 1, y0 + 5 do for x = x0 - 1, x0 + 5 do c:put(x, y, WD[2], wdT) end end
  for y = y0, y0 + 4 do for x = x0, x0 + 4 do
    local t = (x - x0 + y - y0 < 3) and 3 or 2
    c:put(x, y, GL[t], glT)
  end end
  for i = 0, 4 do c:put(x0 + 2, y0 + i, WD[4], wdT) c:put(x0 + i, y0 + 2, WD[4], wdT) end
  c:put(x0, y0, GL[4], glT) c:put(x0 + 3, y0 + 1, GL[4], glT)
  c:put(x0 + 4, y0 + 4, GL[1], glT)
  for x = x0 - 2, x0 + 6 do c:put(x, y0 + 6, WD[5], wdT) end -- sill
  for x = x0 - 1, x0 + 6 do c:put(x, y0 + 7, PL[2], plT) end   -- shadow under sill
end
window(20, 37)
window(37, 37)

-- roof: steep gable with bargeboards
local PK = { 31, 7 }
local roof = c:poly{ { 31, 6 }, { 53, 34 }, { 52, 35.5 }, { 10, 35.5 }, { 9, 34 } }
local rn = {}
roof:each(function(x, y)
  local nx = x < 31 and -0.55 or (x > 31 and 0.5 or 0)
  rn[K(x, y)] = { G.norm(nx, -0.5, 0.7) }
end)
local ridx = A.shade(c, roof, rn, ROOF, { tok = roT, amb = 0.05, wrap = 0.2, cuts = { 0.2, 0.38, 0.56, 0.74, 0.9 },
  tilt = { 31, 22, 18, 0.18 } })
-- scalloped tile rows: lap line (dark) under each row, rounded tile bottoms, lit tile tops
roof:each(function(x, y)
  local ry = (y - 9) % 4
  local row = (y - 9) // 4
  local off = (row % 2) * 2
  local tx = (x - 31 + 40 + off) % 4
  if y < 9 then return end
  if ry == 3 then A.step(c, ridx, ROOF, x, y, -2, roT)
  elseif ry == 2 and (tx == 0) then A.step(c, ridx, ROOF, x, y, -1, roT)
  elseif ry == 0 and tx == 2 then A.step(c, ridx, ROOF, x, y, 1, roT) end
end)
-- bargeboards: 2px wood trim along both slopes, lit on the left
roof:edge():each(function(x, y)
  if y < 34 then
    local lit = x <= 31
    c:put(x, y, lit and WD[5] or WD[3], wdT)
    local ix = lit and x + 1 or x - 1
    if roof:has(ix, y) and not roof:edge():has(ix, y) then c:put(ix, y, lit and WD[3] or WD[2], wdT) end
  end
end)
-- eaves board + its shadow on the wall
for x = 9, 53 do
  if roof:has(x, 35) then c:put(x, 35, x < 31 and WD[3] or WD[2], wdT) end
  if roof:has(x, 34) then c:put(x, 34, x < 31 and WD[4] or WD[3], wdT) end
end
-- round attic window in the gable
local aw = A.ell(31, 24, 2.6, 2.6)
aw:grow(1):each(function(x, y) c:put(x, y, WD[2], wdT) end)
aw:each(function(x, y) c:put(x, y, (x + y < 55) and GL[3] or GL[2], glT) end)
c:put(30, 23, GL[4], glT) c:put(31, 22, GL[4], glT)
for y = 22, 26 do c:put(31, y, WD[4], wdT) end
for x = 29, 33 do c:put(x, 24, WD[4], wdT) end
c:put(30, 23, GL[4], glT)
-- ridge cap glint
c:put(31, 7, ROOF[6], roT) c:put(30, 8, ROOF[6], roT) c:put(30, 9, CR, roT)

-- quirk: bluebird on the left bargeboard
local bird = {
  "..bbb...",
  ".bBkBb..",
  "OBBBBbww",
  ".WBBbbw.",
  "..bbw...",
  "..d.d...",
}
local BP = { b = "#3a86b0", B = "#5fc4c8", k = INK, O = "#f5b82e", w = "#2a4a7a", W = "#f27450", d = INK }
A.map(c, bird, 15, 17, BP, A.tok("bird"))
c:put(18, 17, "#b6f0e0", A.tok("bird")) c:put(17, 18, "#b6f0e0", A.tok("bird"))

A.save(c, "ico-home")
