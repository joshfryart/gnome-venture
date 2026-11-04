-- nav-today (final, Opus single pass). A slim three-quarter cottage: cream plaster gable front with a round attic
-- window, a shaded side wall with a mullioned window and sill, a steep terracotta tile roof (courses with dark drip
-- rows and staggered joints, lit ridge), a wooden bargeboard with grain, a round-top plank door with a brass knob,
-- a stone plinth with mortar courses, a brick chimney with a cap, a 2-tone ground shadow.
-- quirk: a little blue tit has perched on the chimney cap to see what today brings.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r1_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, max, min, abs = math.floor, math.sin, math.max, math.min, math.abs
local c = A.new("nav-today")
local PL   = { "#7d5f5a", "#a8857a", "#cfae97", "#e8cdb0", "#f6e3c6", "#fff3dc" }
local TILE = { "#5a1f2e", "#8a2c33", "#b8423a", "#d9603f", "#f08a58", "#ffb98a" }
local WOOD = { "#3f2422", "#5e3529", "#82503a", "#a66d48", "#c99263", "#e6bb8a" }
local STONE= { "#3e3f58", "#5e5f78", "#7f7f96", "#a3a2b4", "#c6c5d2", "#e4e2ea" }
local BRICK= { "#4e1f2a", "#73303a", "#9c4640", "#bf6450", "#da8a6a", "#f2b08e" }
local GLASS= { "#2a4a7a", "#3a6ea0", "#5aa0c4", "#8fd0dc", "#c4f0ea", "#eefcf6" }

c:groundShadow(33, 57, 21, 2)

-- geometry
local R1, R2 = { 25, 17 }, { 43, 15 }        -- ridge front / back
local EL, ER, BR = { 12, 36 }, { 38, 36 }, { 53, 33 }
local front = c:rect(16, 36, 34, 55):add(c:poly{ { 16, 36 }, { 25, 20 }, { 34, 36 } })
local side = c:poly{ { 35, 36 }, { 49, 33 }, { 49, 53 }, { 35, 55 } }
local roof = c:poly{ R1, R2, BR, ER }
local chim = c:rect(40, 13, 44, 24)
local cap = c:rect(39, 12, 45, 13)

-- chimney (behind roof)
chim:each(function(x, y)
  local row = floor((y - 13) / 2)
  local joint = (y - 13) % 2 == 1 or ((x + row * 2) % 4 == 0)
  local t = (x <= 41) and 4 or 3
  if x == 44 then t = 2 end
  if joint then t = t - 1 end
  if x == 40 and not joint then t = 5 end
  c:put(x, y, BRICK[max(1, t)])
end)
cap:each(function(x, y) c:put(x, y, y == 12 and (x < 43 and STONE[6] or STONE[5]) or (x < 44 and STONE[4] or STONE[3])) end)
for x = 40, 44 do c:put(x, 14, BRICK[1]) end

-- side wall (shade side, still warm)
side:each(function(x, y)
  local t = 3
  if X.hash(x, y, 7) < 0.08 then t = 2 end
  if x == 35 then t = 2 end
  c:put(x, y, PL[t])
end)
-- front wall
local fb = {}
front:each(function(x, y) local k = K(x, y)
  local t = 5
  if x <= 17 then t = 6 end
  if x >= 33 then t = 4 end
  if X.hash(x, y, 11) < 0.07 then t = t - 1 end
  c:put(x, y, PL[t])
end)

-- plinth (stone courses)
for y = 51, 55 do for x = 16, 49 do
  local inF, inS = front:has(x, y), side:has(x, y)
  if inF or inS then
    local row = (y - 51) // 2
    local joint = (y - 51) % 2 == 1 or ((x + row * 3) % 5 == 0)
    local t = inF and 5 or 3
    if inF and x <= 17 then t = 6 end
    if y == 51 then t = t - 1 end
    if joint then t = inF and 3 or 2 end
    c:put(x, y, STONE[t])
  end
end end
-- corner line between faces
for y = 36, 55 do c:put(34, y, y >= 51 and STONE[2] or PL[3]) end

-- door: round top, planks
local door = c:rect(22, 45, 28, 55):add(c:ellipse(25, 45, 3, 3))
door:cut(c:rect(0, 0, 63, 41))
local dframe = door:grow(1):cut(door)
dframe:each(function(x, y) if y <= 55 then c:put(x, y, PL[2]) end end)
door:each(function(x, y)
  local t = 4
  if x == 22 then t = 5 end
  if x == 28 then t = 3 end
  if (x - 22) % 2 == 1 then t = t - 1 end
  if (x - 22) % 2 == 1 and X.hash(x, y, 2) < 0.3 then t = t - 1 end
  if y <= 44 and x >= 26 then t = t - 1 end
  c:put(x, y, WOOD[max(1, t)])
end)
for x = 22, 28 do c:put(x, 46, WOOD[2]) end           -- cross batten top
c:put(27, 50, "#f5b82e") c:put(27, 51, "#8f4a1f") c:put(26, 50, "#ffe38a")
-- doorstep
for x = 21, 29 do c:put(x, 55, x < 25 and STONE[6] or STONE[4]) end

-- round attic window in the gable
local aw = c:ellipse(25, 29, 2, 2)
aw:grow(1):cut(aw):each(function(x, y) c:put(x, y, WOOD[(x + y < 54) and 5 or 3]) end)
aw:each(function(x, y) c:put(x, y, GLASS[(x + y <= 53) and 5 or 3]) end)
c:put(24, 28, GLASS[6]) c:put(25, 29, WOOD[3]) c:put(25, 28, WOOD[4]) c:put(25, 30, WOOD[3]) c:put(24, 29, WOOD[4]) c:put(26, 29, WOOD[3])

-- side window (follows the wall slant)
local function sy(x) return floor((36 - 33) * (x - 35) / 14 + 0.5) end   -- wall top rises to the right
for x = 38, 45 do
  local o = -sy(x)
  for y = 40 + o, 46 + o do
    local frame = x == 38 or x == 45 or y == 40 + o or y == 46 + o or x == 41 or x == 42 and false or y == 43 + o
    local t
    if frame then t = WOOD[(x == 38 or y == 40 + o) and 2 or 3]
    else
      local g = 3
      if (x == 39 or x == 43) and y <= 42 + o then g = 5 end
      if x == 40 and y == 41 + o then g = 6 end
      if y >= 44 + o and x >= 43 then g = 2 end
      t = GLASS[g]
    end
    c:put(x, y, t)
  end
  c:put(x, 47 - sy(x), STONE[x < 41 and 5 or 4])            -- sill
  c:put(x, 48 - sy(x), PL[1])                                -- sill shadow
end

-- roof: tile courses, joints staggered, drip row dark
local rn = {}
roof:each(function(x, y)
  local u = y + 0.16 * (x - 25)          -- distance down the slope
  local row = floor((u - 15) / 3)
  local inrow = (u - 15) - row * 3
  local t = 4
  local lit = (x - 25) * 0.1
  if inrow >= 2.2 then t = 2
  elseif inrow < 0.9 then t = 5 end
  if ((x + row * 2) % 5 == 0) and inrow >= 0.9 then t = t - 1 end
  if y >= 34 and t > 3 then t = t - 1 end
  if X.hash(x, y, 9) < 0.05 then t = t - 1 end
  c:put(x, y, TILE[max(1, min(6, t))])
end)
-- ridge cap line
for x = 25, 43 do c:put(x, floor(17 - (x - 25) * 2 / 18 + 0.5), TILE[6]) end
-- eave shadow onto the side wall
for x = 36, 49 do local yy = floor(36 - (x - 35) * 3 / 14 + 0.5) + 1 c:put(x, yy, PL[1]) c:put(x, yy + 1, PL[2]) end

-- bargeboard: wood band along the front gable edges
local function band(a, b, w)
  local m, n, T, S = X.cyl(a[1], a[2], b[1], b[2], function() return w end)
  return m, n
end
local m1, n1 = band(EL, R1, 1.3)
local m2, n2 = band(R1, ER, 1.3)
local bm = m1:add(m2)
local bn = A.merge(n1, n2)
local bidx = A.shade(c, bm, bn, WOOD, { wrap = 0.35 })
-- gable shadow under the bargeboard
local under = bm:shift(0, 1):add(bm:shift(0, 2))
under:each(function(x, y) if front:has(x, y) and not bm:has(x, y) then c:put(x, y, PL[3]) end end)
bm:shift(0, 1):each(function(x, y) if front:has(x, y) and not bm:has(x, y) then c:put(x, y, PL[2]) end end)
-- finial knob at the apex
c:put(25, 15, WOOD[5]) c:put(25, 16, WOOD[4]) c:put(24, 16, WOOD[6])

-- quirk: blue tit on the chimney cap
local BT = { k = "#f5b82e", e = A.INK, h = "#b6f0e0", b = "#5fa8d8", s = "#3a6ea0", c = "#fff4d6", y = "#ffe38a", t = "#2a4a7a" }
local bird = {
  ".hb....",
  "kebbs..",
  ".ycysst",
  "..yyst.",
}
for yy, row in ipairs(bird) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if BT[ch] then c:put(38 + xx, 7 + yy, BT[ch]) end end end

A.save(c, "nav-today")
