-- basket (flowers P2_F4)
local out = app.params["out"] or "./"
local V = dofile(out .. "_vessel_lib.lua")
local W, H, CX = 200, 150, 100
local WK = V.ramp{"#4f2c12","#7f5222","#b0803a","#d3a555","#e8c477","#f6e0a0"}   -- wicker
local IN = V.ramp{"#25130a","#3a2210","#55331a"}
local keys = {{88,52},{100,48.5},{115,43.5},{130,38},{138,34},{140.5,29},{141.5,24},{143,20}}
local function hw(y) return V.interp(keys, y + 0.5) end
local function body(x, y) if y < 88 or y > 141 then return false end local h = hw(y); return h and math.abs(x + 0.5 - CX) <= h end
local function eo(x, y) return V.ell(x, y, CX, 88, 53, 8) end
local function ei(x, y) return V.ell(x, y, CX, 88, 47, 5) end
-- quirk: one loose wicker strand sprouting from the rim
local strand = {{147,91},{150,85},{153,80},{157,78},{159,81}}
local function strandAt(x, y)
  for i = 1, #strand - 1 do
    local a, b = strand[i], strand[i+1]
    local vx, vy = b[1]-a[1], b[2]-a[2]
    local t = V.clamp(((x+0.5-a[1])*vx + (y+0.5-a[2])*vy) / (vx*vx+vy*vy), 0, 1)
    local dx, dy = x+0.5-(a[1]+vx*t), y+0.5-(a[2]+vy*t)
    if dx*dx+dy*dy <= 1.0 then return true end
  end
  return false
end
-- handle (back layer): twisted cane arch
local function handleRho(x, y)
  local dx, dy = x + 0.5 - CX, y + 0.5 - 88
  return math.sqrt((dx/45)^2 + (dy/39.5)^2), dx, dy
end
local function handle(x, y)
  if y > 88 then return false end
  local r = handleRho(x, y)
  return r >= 0.89 and r <= 1.11
end
local function fsolid(x, y) return (y >= 88 and (body(x, y) or eo(x, y)) and not ei(x, y)) or strandAt(x, y) end
local function bsolid(x, y) return (y < 88 and eo(x, y)) or ei(x, y) or handle(x, y) end

local function braid(x, y, dx, n)
  local s = (((x + y) // 3) % 2 == 0) and 1 or 0
  return V.clamp(4 + s - (dx > 20 and 1 or 0) - (dx > 40 and 1 or 0) + (dx < -20 and 1 or 0), 1, 6)
end

local back, front = V.layer(W, H), V.layer(W, H)
-- handle first, ring and interior over it
for y = 30, 90 do for x = 40, 160 do
  if handle(x, y) then
    local r, dx, dy = handleRho(x, y)
    local th = math.atan(-dy * 45 / 39.5, dx)
    local stripe = (math.floor((th * 45 + (r - 1) * 25) / 3) % 2 == 0) and 1 or 0
    local i = 3 + stripe + ((dx < -10 and dy < 0) and 1 or 0) - ((dx > 25 or dy > -6) and 1 or 0) - ((r > 1.06 and dx > 0) and 1 or 0)
    V.set(back, x, y, WK[V.clamp(i, 1, 6)])
  end
end end
for y = 70, 100 do for x = 40, 160 do
  local dx = x + 0.5 - CX
  if y < 88 and eo(x, y) and not ei(x, y) then V.set(back, x, y, WK[braid(x, y, dx) ])
  elseif ei(x, y) then
    local i = V.clamp(1 + (y - 82) / 4 + ((y % 3 == 0) and 1 or 0) - (dx > 30 and 1 or 0), 1, 3) // 1
    V.set(back, x, y, IN[i])
  end
end end

for y = 79, 143 do for x = 40, 165 do
  if fsolid(x, y) then
    local dx = x + 0.5 - CX
    local h = hw(y) or 53
    local n = V.clamp(dx / h, -1, 1)
    local c
    if strandAt(x, y) and not (y >= 88 and (body(x, y) or eo(x, y))) then
      c = WK[(x + y) % 3 == 0 and 5 or 4]
      if y >= 82 and x <= 150 then c = WK[3] end
    elseif eo(x, y) and not ei(x, y) and not (body(x, y) and y > 95) then
      local i = braid(x, y, dx, n)
      if not eo(x, y + 1) and not body(x, y + 1) then i = 2 end
      c = WK[i]
      if y >= 94 then c = WK[V.clamp(i - 1, 1, 6)] end
    else
      local b = V.clamp(math.floor(4.1 - 1.7 * n), 1, 5)
      local k = (y - 88) // 4
      local ry = (y - 88) % 4
      local i = (ry == 0) and b + 1 or ((ry == 3) and b - 2 or b)
      if (x + 3 * (k % 2)) % 6 == 0 then i = i - 1 end
      if y >= 96 and y <= 97 then i = i - 1 end                      -- shadow under rim
      if y >= 137 then i = (y == 137) and 5 - (n > 0.2 and 2 or 0) or 2 - ((n > 0.2) and 1 or 0) end -- base ring
      if y == 141 then i = 1 end
      c = WK[V.clamp(i, 1, 6)]
    end
    V.set(front, x, y, c)
  end
end end
V.outline(back, bsolid, 0, 87)
V.outline(front, fsolid, 70, 150, function(x, y) return y >= 88 or x >= 144 end)
V.shadow(back, CX, 143.5, 40, 2.4)
V.save(out, "basket", {{name = "back", L = back}, {name = "front", L = front}})
