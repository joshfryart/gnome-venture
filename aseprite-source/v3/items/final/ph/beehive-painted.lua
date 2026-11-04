-- beehive-painted (final pass, Opus). A painted wooden box hive in three-quarter view: pink brood box, butter-yellow
-- honey super with a row of blue dots, teal gabled roof, wooden landing board and two feet.
-- Material: each face pillow-lit (bevelled edges) with the side faces a step darker; paint over wood shows faint
-- grain streaks and a plank seam; two paint chips show bare wood; recessed hand-holds with a lit lower lip; dark
-- entrance slot; AO under the roof eave and along the box joint; a painted daisy on the front; ground shadow.
-- quirk: the teal roof paint is still wet: one drip has run down onto the pink box.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR4_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new("beehive-painted")
local W = A.WOOD
local PINK  = { "#5a2346", "#8c3466", "#c4507f", "#ea7499", "#ffa2bb", "#ffd2de" }
local BUT   = { "#6a4030", "#a0703c", "#d4a85a", "#f0d27e", "#fbe8a8", "#fff6d0" }
local TEAL  = { "#1d3a50", "#235c68", "#2c8584", "#45ad9f", "#7fd3bd", "#c2f0dc" }

local function face(m, ramp, R, bias0, o)
  local n = X.pillow(m, R or 2)
  local bias = {}
  if bias0 and bias0 ~= 0 then m:each(function(x, y) bias[K(x, y)] = bias0 end) end
  if o and o.extra then for k, v in pairs(o.extra) do bias[k] = (bias[k] or 0) + v end end
  return A.tone(c, m, n, ramp, { bias = bias, amb = 0.1, wrap = 0.35, cuts = { 0.16, 0.3, 0.46, 0.62, 0.86 } })
end

local FX0, FX1 = 20, 39          -- front faces
local DX, DY = 5, -3             -- receding side offset
c:groundShadow(32, 55, 18, 2)
-- feet
for _, fx in ipairs{ 20, 34 } do
  local m = c:rect(fx, 50, fx + 3, 53)
  m:each(function(x, y) c:put(x, y, y == 50 and W[1] or (x == fx and W[4] or (x == fx + 3 and W[2] or W[3]))) end)
end
-- side faces (behind the fronts)
local sideLo = c:poly{ { FX1 + 1, 34 }, { FX1 + DX, 34 + DY }, { FX1 + DX, 47 + DY }, { FX1 + 1, 47 } }
local sideUp = c:poly{ { FX1 + 1, 25 }, { FX1 + DX, 25 + DY }, { FX1 + DX, 33 + DY }, { FX1 + 1, 33 } }
local iLoS = face(sideLo, PINK, 1, -2)
local iUpS = face(sideUp, BUT, 1, -2)
-- hand-holds on the side faces: recessed dark slot with a lit lower lip
for _, h in ipairs{ { 39, 0 }, { 28, 0 } } do
  local y = h[1]
  c:put(FX1 + 2, y, "#3a1d2a") c:put(FX1 + 3, y - 1, "#3a1d2a")
end
c:put(FX1 + 2, 40, PINK[4]) c:put(FX1 + 3, 39, PINK[4])
c:put(FX1 + 2, 29, BUT[4]) c:put(FX1 + 3, 28, BUT[4])
-- fronts
local lo = c:rect(FX0, 34, FX1, 47)
local up = c:rect(FX0, 25, FX1, 33)
local aoLo, aoUp = {}, {}
for x = FX0, FX1 do aoLo[K(x, 34)] = -2 aoLo[K(x, 35)] = -1 aoUp[K(x, 25)] = -2 aoUp[K(x, 26)] = -1 end
local iLo = face(lo, PINK, 2, 0, { extra = aoLo })
local iUp = face(up, BUT, 2, 0, { extra = aoUp })
-- paint over wood: faint horizontal grain streaks, one plank seam on the brood box
for y = 36, 46 do for x = FX0 + 1, FX1 - 1 do
  if y == 41 then A.step(c, iLo, PINK, x, y, -1, 2)
  elseif (y % 3 == 0) and X.hash(x // 3, y, 11) > 0.62 then A.step(c, iLo, PINK, x, y, -1, 2) end
end end
for x = FX0, FX1 do c:put(x, 42, iLo[K(x, 42)] and PINK[min(6, iLo[K(x, 42)] + 1)] or PINK[4]) end
for y = 27, 32 do for x = FX0 + 1, FX1 - 1 do
  if (y % 3 == 1) and X.hash(x // 3, y, 13) > 0.65 then A.step(c, iUp, BUT, x, y, -1, 2) end
end end
-- blue painted dots on the super
for i = 0, 4 do local x = FX0 + 3 + i * 4
  c:put(x, 29, "#3a86b0") c:put(x + 1, 29, "#3a86b0") c:put(x, 30, "#2a5a8f") c:put(x + 1, 30, "#2a5a8f") c:put(x, 29, "#7cc8e8")
end
-- painted daisy on the brood box
local dcx, dcy = 25, 38
for _, p in ipairs{ { 0, -2 }, { 0, -3 }, { 2, 0 }, { 3, 0 }, { 0, 2 }, { 0, 3 }, { -2, 0 }, { -3, 0 }, { 1, -1 }, { 1, 1 }, { -1, 1 }, { -1, -1 }, { 2, -2 }, { -2, 2 }, { 2, 2 }, { -2, -2 } } do
  local x, y = dcx + p[1], dcy + p[2]
  local lit = (p[1] + p[2] <= 0)
  c:put(x, y, (abs(p[1]) == 2 and abs(p[2]) == 2) and (lit and "#f6e6c8" or "#e0c8b0") or (lit and "#fff4d6" or "#f0dcc0"))
end
c:put(dcx, dcy, "#f5b82e") c:put(dcx - 1, dcy, "#f5b82e") c:put(dcx, dcy - 1, "#ffe38a") c:put(dcx + 1, dcy, "#d98322") c:put(dcx, dcy + 1, "#d98322")
-- paint chips showing bare wood (corner of the brood box, edge of the super)
c:put(FX0, 44, W[4]) c:put(FX0, 45, W[3]) c:put(FX0 + 1, 45, W[5])
c:put(FX1, 27, W[4]) c:put(FX1 - 1, 27, W[3])
-- entrance slot + landing board
for x = 23, 34 do c:put(x, 46, "#2a1520") c:put(x, 47, "#3a1d24") end
local lb = c:rect(21, 48, 36, 49)
lb:each(function(x, y) c:put(x, y, y == 48 and W[5] or W[3]) end)
c:put(36, 49, W[2]) c:put(36, 48, W[6])
for x = 22, 30, 3 do c:put(x, 49, W[2]) end

-- roof: receding right plane (shaded), then the lit gable end in front
local AX, AY = 28.5, 13
local roofR = c:poly{ { AX + 1, AY - 0 }, { AX + 1 + DX, AY + DY }, { FX1 + 3 + DX, 25 + DY }, { FX1 + 3, 25 } }
local iRR = face(roofR, TEAL, 1, -1)
-- shingle courses on the receding plane
roofR:each(function(x, y) if (x + y) % 3 == 0 then A.step(c, iRR, TEAL, x, y, -1, 1) end end)
local gable = c:poly{ { FX0 - 4, 26 }, { AX, AY - 1 }, { FX1 + 3, 26 } }
local gin = gable:shrink(2)
local iG = face(gable, TEAL, 2, 0)
-- gable board: inner triangle is the painted front board (butter), framed by the teal barge boards
local gb = gin:copy():clip(gable)
local iGB = face(gb, BUT, 1, -1)
-- eave AO on the gable board bottom
gb:each(function(x, y) if not gb:has(x, y + 1) then c:put(x, y, BUT[2]) end end)
gable:each(function(x, y) if y == 26 then c:put(x, y, TEAL[2]) end end)
-- small round vent in the gable
c:put(28, 19, "#3a1d2a") c:put(29, 19, "#3a1d2a") c:put(28, 20, "#3a1d2a") c:put(29, 20, "#2a1520") c:put(28, 18, BUT[2])
-- barge board edge highlight + specular
for i = 0, 10 do c:put(floor(FX0 - 3 + i * 1.2), 25 - i, TEAL[5]) end
c:put(20, 21, TEAL[6]) c:put(21, 20, TEAL[6])
-- ridge cap knob

-- quirk: wet teal drip run down from the eave onto the pink box
for y = 27, 35 do c:put(35, y, y < 31 and TEAL[4] or TEAL[3]) end
c:put(35, 36, TEAL[3]) c:put(36, 36, TEAL[2]) c:put(34, 36, TEAL[4]) c:put(35, 37, TEAL[2]) c:put(36, 37, TEAL[1]) c:put(34, 37, TEAL[3])
c:put(35, 38, TEAL[1]) c:put(34, 36, TEAL[6])
for y = 29, 35 do c:put(36, y, TEAL[2]) end
A.save(c, "beehive-painted")
