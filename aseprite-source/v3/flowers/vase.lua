-- vase (flowers P2_F4)
local out = app.params["out"] or "./"
local V = dofile(out .. "_vessel_lib.lua")
local W, H, CX = 200, 150, 100
local GL = V.ramp{"#1d3552","#2a5a7a","#3a7f9c","#5aa3b8","#8cc9d2","#c6ecea"}   -- blue glaze
local CR = V.ramp{"#8c7a52","#c2b07a","#e8dcb0","#f6eecb"}                        -- cream glaze
local CL = V.ramp{"#6e3626","#a05635","#c97a4a"}                                  -- bare clay foot
local IN = V.ramp{"#0e1c2c","#17304a","#234563"}                                  -- inside
local keys = {{58,17},{64,13},{72,11.5},{80,13},{90,22},{100,31},{112,36},{124,35},{134,30},{141.5,22},{143,18}}
local function hw(y) return V.interp(keys, y + 0.5) end
local function body(x, y) if y < 60 or y > 141 then return false end local h = hw(y); return h and math.abs(x + 0.5 - CX) <= h end
local function eo(x, y) return V.ell(x, y, CX, 60, 18, 5) end
local function ei(x, y) return V.ell(x, y, CX, 60, 14, 3) end
local function fsolid(x, y) return y >= 60 and (body(x, y) or eo(x, y)) and not ei(x, y) end
local function bsolid(x, y) return (y < 60 and eo(x, y)) or ei(x, y) end
local function idxc(v, n) return V.clamp(math.floor(v), 1, n) end

local back, front = V.layer(W, H), V.layer(W, H)
for y = 50, 66 do for x = 70, 130 do
  if bsolid(x, y) then
    local dx = x + 0.5 - CX
    if ei(x, y) then V.set(back, x, y, IN[idxc(1 + (y - 57) / 2.5 + (dx < -6 and 0.6 or 0), 3)])
    else V.set(back, x, y, CR[(dx < -2 and 3 or 2) + ((y <= 56 and dx < 4) and 1 or 0)]) end
  end
end end

local function drip(x, y) return (x == 106 and y <= 78) or (x >= 105 and x <= 107 and y <= 74) end
for y = 60, 143 do for x = 60, 140 do
  if fsolid(x, y) then
    local dx = x + 0.5 - CX
    local h = hw(y) or 17
    local n = V.clamp(dx / h, -1, 1)
    local c
    local bandY = 66 + math.floor(V.hash(x, 0, 1) * 2.99)
    if eo(x, y) and not ei(x, y) and y < 66 then
      local i = (n < -0.2) and 3 or 2
      if ei(x, y - 1) then i = 4 end
      c = CR[i]
    elseif y <= bandY or drip(x, y) then
      c = CR[n < -0.4 and 4 or (n < 0.3 and 3 or (n < 0.75 and 2 or 1))]
    elseif y >= 136 + math.floor(V.hash(x, 3, 2) * 1.99) then
      c = CL[n < -0.3 and 3 or (n < 0.5 and 2 or 1)]
      if y == 141 then c = CL[1] end
    else
      local v = 0.82 - 0.55 * (((n + 1) / 2) ^ 1.2) - 0.12 * math.max(0, (y - 122) / 20)
      local i = idxc(math.floor(v * 6) + 1, 6)
      if n > 0.86 then i = i + 1 end                                  -- cool bounce light
      if V.hash(x, y, 7) > 0.985 then i = i - 1 end                   -- glaze speck
      if y >= 88 and y <= 112 and math.abs(dx + 0.55 * h) <= 1.0 then i = 6 end -- streak
      if y == 114 and math.abs(dx + 0.55 * h) <= 0.6 then i = 5 end
      if y == 135 then i = 1 end                                      -- pooled glaze
      c = GL[V.clamp(i, 1, 6)]
    end
    V.set(front, x, y, c)
  end
end end
V.outline(back, bsolid, 0, 59)
V.outline(front, fsolid, 60, 150)
V.shadow(back, CX, 143.5, 28, 2.3)
V.save(out, "vase", {{name = "back", L = back}, {name = "front", L = front}})
