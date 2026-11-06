-- ico-box (final pass, Opus). A small wooden storage crate seen from above at a 2:1 angle.
-- Structure: plank lid with a lit cut edge and a cross batten, a lid skirt with a dark gap below it, two
-- horizontal planks per side, square corner posts, iron corner brackets with rivets, nail heads on the plank ends.
-- Material: plane light per face (top lit, left mid, right shade), bevelled plank edges, grain streaks along
-- each board, pale end grain on the post tops, iron bevel + bright edge, AO in the plank gaps, ground shadow.
-- quirk: a little pink mouse tail curls out of the gap under the lid.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA1_4.lua")
local HP, X, K, R = A.HP, A.X, A.K, A.R
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local c = A.new("ico-box")
local OK, IR, RO = R.oak, R.iron, R.rose

local AX, AY, BX, BY, CX, CY, DX, DY = 10, 24, 32, 13, 54, 24, 32, 35
local H = 20

c:groundShadow(33, 52, 22, 3)

local function put(x, y, i) c:put(x, y, OK[max(1, min(6, i))]) end
local function grain(x, y, seed) return X.hash(floor(x / 3), y, seed) end

-- side faces
for x = AX, CX do
  local left = x < DX
  local s = left and (x - AX) / (DX - AX) or (x - DX) / (CX - DX)
  local topy = left and (AY + s * (DY - AY)) or (DY + s * (CY - DY))
  local ty = floor(topy + 0.5)
  for y = ty, ty + H do
    local t = y - ty
    local base = left and 4 or 3
    local i = base
    -- corner posts (3 px) at each visible corner
    local px = left and (x - AX) or (CX - x)
    local fx = abs(x - DX)
    local post = px <= 2 or fx <= 2
    if post then
      i = base + 1
      if px == 2 or (fx == 2) then i = base - 1 end              -- post edge line
      if (x + floor(t / 5)) % 4 == 0 and t > 4 then i = i - 1 end  -- vertical grain
      if x == DX then i = 6 end                                  -- bright front edge
      if x == DX + 1 then i = base end
    else
      -- planks: skirt 0..3, gap 4, plank 5..11, gap 12, plank 13..H
      if t == 4 or t == 12 then i = 1
      elseif t == 5 or t == 13 then i = base + 1                 -- lit top bevel
      elseif t == 11 or t == H then i = base - 1                 -- under bevel
      elseif t == 0 then i = base + 1
      elseif t == 3 then i = base - 1 end
      if t ~= 4 and t ~= 12 and t ~= 0 then
        local g = grain(x, y, left and 3 or 9)
        if g < 0.22 then i = i - 1 elseif g > 0.93 then i = i + 1 end
      end
      -- AO near the front post and under the lid skirt
      if fx == 3 and not left then i = i - 1 end
      if t == 1 and not left then i = i end
    end
    if t == H then i = min(i, base - 1) end
    put(x, y, i)
  end
end

-- top lid: param (a along A->D, b along A->B)
local top = A.poly{ { AX, AY }, { BX, BY }, { CX, CY }, { DX, DY } }
local ux, uy = DX - AX, DY - AY
local vx, vy = BX - AX, BY - AY
local det = ux * vy - uy * vx
top:each(function(x, y)
  local rx, ry = x - AX, y - AY
  local a = (rx * vy - ry * vx) / det       -- 0 at A-B edge .. 1 at D-C edge
  local b = (ux * ry - uy * rx) / det       -- 0 at A-D edge .. 1 at B-C edge
  local i = 5
  -- planks run parallel to A-B: gaps at a = 1/3, 2/3
  local pa = a * 3
  local fr = pa - floor(pa)
  if abs(a - 1 / 3) < 0.03 or abs(a - 2 / 3) < 0.03 then i = 2
  elseif fr < 0.1 then i = 4 end
  -- cross batten along the middle (parallel to A-D)
  if abs(b - 0.5) < 0.09 then i = 6 if abs(b - 0.5) > 0.05 then i = (b > 0.5) and 4 or 6 end end
  local g = X.hash(floor(b * 14), floor(a * 22), 21)
  if i == 5 and g < 0.2 then i = 4 end
  if i == 5 and g > 0.95 then i = 6 end
  put(x, y, i)
end)
-- lit cut edge on the two front edges of the lid, darker on the back edges
top:edge():each(function(x, y)
  if not top:has(x, y + 1) then put(x, y, 6) elseif not top:has(x, y - 1) then put(x, y, 4) end
end)
-- pale end grain caps on the four corner posts (tiny squares on the lid corners)
for _, p in ipairs{ { AX + 1, AY }, { DX, DY - 1 }, { CX - 1, CY } } do
  c:put(p[1], p[2], OK[6]) c:put(p[1], p[2] + 1, "#f6dca8")
end

-- iron corner brackets on the front edge (top and bottom) and nail heads
local function bracket(y0, up)
  for d = 0, 4 do
    for w = 0, 2 do
      local yy = y0 + (up and -w or w)
      -- left arm follows the left face slope, right arm the right face slope
      local yl = yy + floor(d * (DY - AY) / (DX - AX) * -1 + 0.5)
      local yr = yy + floor(d * (CY - DY) / (CX - DX) * 1 + 0.5)
      local il = (w == 0) and 5 or (w == 1 and 4 or 3)
      local ir = (w == 0) and 4 or (w == 1 and 3 or 2)
      c:put(DX - d, yl, IR[il]) c:put(DX + d, yr, IR[ir])
    end
  end
  c:put(DX, y0 + (up and -1 or 1), IR[6])
end
bracket(DY + 2, false)
bracket(DY + H - 1, true)
-- rivets on brackets
for _, p in ipairs{ { DX - 3, DY + 2 }, { DX + 3, DY + 2 }, { DX - 3, DY + H - 3 }, { DX + 3, DY + H - 3 } } do
  c:put(p[1], p[2], IR[1]) c:put(p[1], p[2] - 1, IR[6])
end
-- nail heads at the plank ends near the back posts
for _, side in ipairs{ { AX + 4, 1 }, { CX - 4, -1 } } do
  local x = side[1]
  local left = x < DX
  local s = left and (x - AX) / (DX - AX) or (x - DX) / (CX - DX)
  local ty = floor((left and (AY + s * (DY - AY)) or (DY + s * (CY - DY))) + 0.5)
  for _, t in ipairs{ 8, 16 } do c:put(x, ty + t, IR[2]) c:put(x, ty + t - 1, IR[5]) end
end

-- quirk: mouse tail curling out of the lid gap on the right face
A.map(c, {
  "ab.....",
  "abbc...",
  ".bbccd.",
  "....cd.",
  "....cd.",
  "...cd..",
  "..dd...",
}, 46, 32, { a = RO[6], b = RO[5], c = RO[4], d = RO[3] })

A.save(c, "ico-box")
