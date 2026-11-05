-- jar (flowers P2_F4)
local out = app.params["out"] or "./"
local V = dofile(out .. "_vessel_lib.lua")
local W, H, CX = 200, 150, 100
local GL = V.ramp{"#3c7a96","#5ea0ba","#86c2d2","#b0dde5","#d4f0f0","#eefaf6"}   -- glass wall
local BW = V.ramp{"#7fb4c6","#9cc9d6","#b6dce4","#cdeaee"}                       -- back wall, dry
local WT = V.ramp{"#2f7592","#4a93ae","#68afc3","#d6f0ee"}                       -- water (4 = surface glint)
local IN = V.ramp{"#4e8da4","#68a6ba","#84bfcf"}
local PA = V.ramp{"#b99a62","#d8bd84","#f3e6c4"}                                 -- label paper
local keys = {{56,23},{70,23.5},{74,27},{80,29},{132,29},{138,26},{141.5,22},{143,19}}
local function hw(y) return V.interp(keys, y + 0.5) end
local function body(x, y) if y < 60 or y > 141 then return false end local h = hw(y); return h and math.abs(x + 0.5 - CX) <= h end
local function eo(x, y) return V.ell(x, y, CX, 59, 24.5, 5.5) end
local function ei(x, y) return V.ell(x, y, CX, 59, 20.5, 3.2) end
local function solid(x, y) return (y >= 59 and body(x, y)) or eo(x, y) end
local function fsolid(x, y) return y >= 59 and (body(x, y) or eo(x, y)) and not ei(x, y) end
local function bsolid(x, y) return (y < 59 and eo(x, y)) or ei(x, y) or (y >= 59 and body(x, y)) end
local WATER = 85
local function surf(x) return WATER + ((x % 7) < 3 and 0 or 1) end

local back, front = V.layer(W, H), V.layer(W, H)
for y = 50, 142 do for x = 60, 140 do
  if bsolid(x, y) then
    local dx = x + 0.5 - CX
    if y < 59 and eo(x, y) and not ei(x, y) then
      V.set(back, x, y, GL[(dx < 0 and 4 or 3)])
    elseif ei(x, y) and y < 66 then
      V.set(back, x, y, IN[V.clamp(1 + (y - 55) / 3, 1, 3) // 1])
    else
      local h = hw(y) or 23
      local lit = V.clamp(math.floor(2.4 - (dx / h) * 1.2), 1, 3)
      if y >= surf(x) then
        local i = V.clamp(math.floor(1.6 - (dx / h) * 1.1 + (y < surf(x) + 2 and 1 or 0)), 1, 3)
        if y == surf(x) then i = 4 end
        if y >= 136 then i = 1 end
        V.set(back, x, y, WT[i])
      else
        V.set(back, x, y, BW[lit + (y < 66 and 0 or 0)])
      end
    end
  end
end end

-- front: glass walls, base, rim, streaks, label, bubble trail
local function label(x, y) return x >= 88 and x <= 112 and y >= 92 and y <= 112 end
local bub = {{87,121,2},{91,114,1},{85,108,1}}
for y = 59, 143 do for x = 60, 140 do
  if fsolid(x, y) then
    local dx = x + 0.5 - CX
    local h = hw(y) or 23
    local ringLower = eo(x, y) and not ei(x, y) and y < 64
    local d = V.dist(solid, x, y, 4)
    local c
    if ringLower then
      c = GL[(ei(x, y - 1)) and 6 or (dx < 0 and 4 or 3)]
      if y >= 62 and not ei(x, y - 1) and ei(x, y - 2) then c = GL[5] end
    elseif d <= 4 and (d <= 3 or not solid(x, y + d)) then
      local bottom = not solid(x, y + d) and y > 125
      if bottom then c = GL[({2,3,4,3})[d]]
      elseif dx < 0 then c = GL[({3,5,4,3})[d]]
      else c = GL[({2,3,2,2})[d]] end
      if y < 66 and d == 4 then c = nil end
    end
    if c then V.set(front, x, y, c) end
  end
end end
-- streaks (glass sheen)
for y = 78, 108 do V.set(front, 78, y, GL[6]); V.set(front, 79, y, GL[5]) end
V.set(front, 78, 112, GL[6]); V.set(front, 78, 113, GL[6])
for y = 86, 100 do V.set(front, 121, y, GL[4]) end
-- label (paper, taped on the glass) with two ink lines
for y = 92, 112 do for x = 88, 112 do
  local edge = (x == 88 or y == 92) and PA[3] or ((x == 112 or y == 112) and PA[1] or PA[3])
  if (x == 88 or x == 112) and (y == 92 or y == 112) then edge = PA[2] end
  V.set(front, x, y, edge)
end end
for x = 92, 106 do V.set(front, x, 98, PA[1]) end
for x = 92, 102 do V.set(front, x, 102, PA[1]) end
for x = 92, 99 do V.set(front, x, 106, PA[2]) end
-- QUIRK: trapped air-bubble trail rising in the glass (ring + glint)
for _, b in ipairs(bub) do
  local bx, by, r = b[1], b[2], b[3]
  if r == 2 then
    for _, p in ipairs{{-1,-2},{0,-2},{1,-2},{-2,-1},{2,-1},{-2,0},{2,0},{-1,1},{0,1},{1,1}} do V.set(front, bx + p[1], by + p[2], GL[4]) end
    V.set(front, bx - 1, by - 1, GL[6])
    V.set(front, bx + 1, by, GL[6]); V.set(front, bx - 1, by, GL[5]); V.set(front, bx, by - 1, GL[5])
  else
    V.set(front, bx, by, GL[6]); V.set(front, bx + 1, by, GL[4]); V.set(front, bx, by + 1, GL[4])
  end
end
V.outline(back, bsolid, 0, 59, function(x, y) return y <= 59 end)
V.outline(back, bsolid, 60, 150)
V.outline(front, fsolid, 59, 150, function(x, y) return not ei(x, y) or ei(x, y + 1) and false end)
-- ink on inside lower edge of the rim (front opening)
for y = 59, 66 do for x = 60, 140 do
  if ei(x, y) and not V.get(front, x, y) and V.get(front, x, y + 1) and y + 1 >= 59 and fsolid(x, y + 1) and eo(x, y + 1) and not ei(x, y + 1) then V.set(front, x, y, V.INK) end
end end
V.shadow(back, CX, 143.5, 34, 2.3)
V.save(out, "jar", {{name = "back", L = back}, {name = "front", L = front}})
