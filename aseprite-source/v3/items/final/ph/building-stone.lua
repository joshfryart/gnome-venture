-- building-stone (final, Opus aB13_2 single pass). One dressed limestone ashlar block in 3/4 view: lit top,
-- mid front, shaded right side, each face with a smooth drafted margin (chamfer bevel, bright top-front edge) and a
-- pecked, tooled centre field (short diagonal chisel strokes); cool reflected light low on the side, AO in the
-- inner corners, a chipped top-right corner with its flake lying by the foot, fossil-shell speck, 2-tone ground shadow.
-- quirk: the mason's mark chiselled on the front is a tiny gnome hat.
local NAME = "building-stone"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aB13_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local c = A.new(NAME)

local ST = { "#3a3550", "#585470", "#7c7790", "#a29daa", "#c8c1c0", "#ebe3d4", "#fbf4e6" }
local COOL = "#7d8fb0"
local tok = { r = { name = "stone" } }

-- geometry: front x 10..41 y 27..48 ; depth offset (+12,-10)
local FX0, FX1, FY0, FY1, DX, DY = 10, 41, 27, 48, 12, -10
c:groundShadow(34, 50, 24, 2)

local front = c:rect(FX0, FY0, FX1, FY1)
local top = c:poly{ { FX0, FY0 - 1 }, { FX0 + DX, FY0 + DY - 1 }, { FX1 + DX, FY0 + DY - 1 }, { FX1, FY0 - 1 } }
top:cut(front)
local side = c:poly{ { FX1 + 1, FY0 - 1 }, { FX1 + DX, FY0 + DY }, { FX1 + DX, FY1 + DY }, { FX1 + 1, FY1 } }
side:cut(front):cut(top)
-- chipped corner (top-right-back of the top face meets side)
local chip = c:poly{ { FX1 + DX - 4, FY0 + DY - 1 }, { FX1 + DX, FY0 + DY - 1 }, { FX1 + DX, FY0 + DY + 4 } }
top:cut(chip) side:cut(chip)

-- face painter: base tone, drafted margin (2px, one step lighter & smooth), pecked field
local function face(m, base, margin, edgeFn)
  local inner = m:shrink(2)
  m:each(function(x, y)
    local i = base
    if inner:has(x, y) then
      -- tooled field: short diagonal chisel strokes
      local h = X.hash(x, y, 5)
      if ((x + y * 2) % 5 == 0) and h > 0.35 then i = base - 1
      elseif ((x + y * 2) % 5 == 1) and h > 0.55 then i = base + 1
      elseif h > 0.95 then i = base - 1 end
    else
      i = base + margin
    end
    i = edgeFn and edgeFn(x, y, i) or i
    c:put(x, y, ST[max(1, min(#ST, i))], tok)
  end)
end
face(top, 5, 1, function(x, y, i)
  if y == FY0 - 1 then return 7 end                 -- bright front edge of the top (bevel catch light)
  if y == FY0 + DY - 1 then return 4 end             -- far edge
  return i end)
face(front, 4, 0, function(x, y, i)
  if y == FY0 then return 6 end                      -- chamfer under the bright edge
  if x == FX0 then return 5 end
  if y == FY1 then return 2 end                      -- underside AO row
  if x == FX1 then return 3 end
  if y >= FY1 - 2 and i > 3 then return 3 end
  return i end)
face(side, 2, 1, function(x, y, i)
  if x == FX1 + 1 then return 2 end                  -- AO in the inner corner
  if x >= FX1 + DX - 1 and y > FY0 + 2 then return 3 end
  -- cool reflected light low on the side
  if y > FY1 - 5 + (x - FX1) * DY / DX and y <= FY1 + (x - FX1) * DY / DX - 1 and x > FX1 + 3 then return 0 end
  return i end)
side:each(function(x, y)
  if y > FY1 - 5 + (x - FX1) * DY / DX and y <= FY1 + (x - FX1) * DY / DX - 1 and x > FX1 + 3 and x < FX1 + DX - 1 then c:put(x, y, COOL, tok) end end)
-- chip scar: fresh pale break with a dark lip
for _, p in ipairs{ { FX1 + DX - 5, FY0 + DY }, { FX1 + DX - 4, FY0 + DY + 1 }, { FX1 + DX - 3, FY0 + DY + 2 }, { FX1 + DX - 2, FY0 + DY + 3 }, { FX1 + DX - 1, FY0 + DY + 4 } } do
  if top:has(p[1], p[2]) or side:has(p[1], p[2]) then c:put(p[1], p[2], ST[7], tok) end
  if side:has(p[1], p[2] + 1) then c:put(p[1], p[2] + 1, ST[2], tok) end
end
-- the flake, lying by the foot
local flake = { { 47, 47, 6 }, { 48, 47, 5 }, { 49, 47, 4 }, { 46, 48, 4 }, { 47, 48, 3 }, { 48, 48, 2 } }
for _, p in ipairs(flake) do c:put(p[1], p[2], ST[p[3]], { r = { name = "flake" } }) end
-- fossil shell speck on the front (tiny spiral)
c:px(16, 41, ST[2]) c:px(17, 41, ST[6]) c:px(17, 42, ST[2]) c:px(16, 42, ST[5])
-- quirk: mason's mark, a little gnome hat chiselled in (groove dark, lower lip lit)
local hat = {
  "...d...",
  "..d.d..",
  ".d...d.",
  "ddddddd",
  ".lllll.",
}
A.map(c, hat, 27, 34, { d = ST[2], l = ST[6] }, tok)
-- a hairline crack from the chip
for _, p in ipairs{ { FX1 + DX - 1, FY0 + DY + 6 }, { FX1 + DX - 2, FY0 + DY + 8 }, { FX1 + DX - 2, FY0 + DY + 9 } } do c:put(p[1], p[2], ST[1], tok) end

A.save(c, NAME)
