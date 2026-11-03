-- beeswax (final pass, Opus). A round cake of beeswax cast in a bowl, 3/4 view: the side tapers a hair toward
-- the foot (mould draft); the top face is pressed with a honeycomb mould (staggered hexagon dimples: shadowed upper
-- wall, lit lower wall) inside a smooth bevelled lip. Side lit per pixel on a 6-tone honey-gold ramp: specular
-- streak + 2x1 glint, whitish waxy bloom specks, an interrupted pour seam, cool reflected light lower-right, a dark
-- contact row on a 2-tone ground shadow.
-- quirk: a fresh shaving has rolled off and lies curled against the foot.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR4_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min = math.floor, math.abs, math.sqrt, math.max, math.min
local norm = A.norm
local NAME = "beeswax"
local c = A.new(NAME)
local W = A.WAX
local BLOOM, BOUNCE, SPEC = "#f6e6bc", "#b4847e", "#fffbe6"

local CX, RX, RXB, RY, RYB, Y0, Y1 = 29.5, 15, 14, 7, 7, 23, 38
c:groundShadow(33, Y1 + RYB + 1, 19, 2)

-- masks: top ellipse + tapered side
local top, side, ns = HP.mask(), HP.mask(), {}
for y = Y0 - RY - 1, Y1 + RYB + 1 do for x = floor(CX - RX - 1), floor(CX + RX + 1) do
  local tq = ((x - CX) / (RX + 0.5))^2 + ((y - Y0) / (RY + 0.5))^2
  if tq <= 1 then top:set(x, y)
  else
    local t = max(0, min(1, (y - Y0) / (Y1 - Y0)))
    local r = RX + (RXB - RX) * t
    local inside
    if y <= Y1 then inside = y >= Y0 and abs(x - CX) <= r + 0.5
    else inside = ((x - CX) / (RXB + 0.5))^2 + ((y - Y1) / (RYB + 0.5))^2 <= 1 end
    if inside then
      side:set(x, y)
      local sx = max(-0.98, min(0.98, (x - CX) / (r + 0.5)))
      local sh = min(0.98, sx + 0.12)
      ns[K(x, y)] = { norm(sh, 0.1, sqrt(1 - sh*sh)) }
    end
  end
end end

-- side: cylinder light; contact AO on the bottom two rows
local sb = {}
side:each(function(x, y)
  if not side:has(x, y + 1) then sb[K(x, y)] = -2 elseif not side:has(x, y + 2) then sb[K(x, y)] = -1 end
end)
local sidx = A.tone(c, side, ns, W, { bias = sb, amb = 0.06, wrap = 0.12, cuts = { 0.12, 0.28, 0.46, 0.64, 0.86 }, hi = 5 })
-- bevel row where the side meets the lip
side:each(function(x, y) if top:has(x, y - 1) then
  local sx = (x - CX) / RX
  A.set(c, sidx, W, x, y, sx < -0.3 and 4 or (sx < 0.5 and 3 or 2))
end end)

-- top face: flat plane facing up (bright), a step darker toward the back-right; lip rings
local tidx = {}
top:each(function(x, y)
  local sx, sy = (x - CX) / RX, (y - Y0) / RY
  local i = (sx - sy * 0.3 > 0.55) and 4 or 5
  tidx[K(x, y)] = i c:put(x, y, W[i])
end)
local lip1 = top:edge()
local lip2 = top:copy():cut(lip1):edge()
lip1:each(function(x, y)
  local sx, sy = (x - CX) / RX, (y - Y0) / RY
  local i = 5
  if sx + sy < -0.5 or (sy > 0.5 and sx < 0.4) then i = 6 elseif sx > 0.55 and sy < 0.3 then i = 4 end
  A.set(c, tidx, W, x, y, i)
end)
lip2:each(function(x, y) if (y - Y0) / RY > 0.2 then A.set(c, tidx, W, x, y, 6) end end)

-- honeycomb mould: staggered hexagon dimples, foreshortened 6x4 stamps
local face = top:copy():cut(lip1):cut(lip2)
local HEX = { ".dddd.", "dbbbbl", ".llll." }
local function stamp(x0, y0)
  for r = 1, #HEX do for q = 1, #HEX[r] do
    local ch, x, y = HEX[r]:sub(q, q), x0 + q - 1, y0 + r - 1
    local back = (x - CX) / RX > 0.5
    if not face:has(x, y) then ch = "." end
    if ch == "d" then A.set(c, tidx, W, x, y, back and 2 or 3)
    elseif ch == "l" then A.set(c, tidx, W, x, y, back and 5 or 6)
    elseif ch == "b" then A.set(c, tidx, W, x, y, 4) end
  end end
  return true
end
for j = -1, 6 do for i = -4, 4 do
  stamp(floor(CX - 3 + i * 7 + (j % 2) * 3.5 + 0.5), Y0 - RY + 1 + j * 3)
end end

-- side cues: specular streak + 2x1 glint on the lit flank, bloom specks, pour seam, cool bounce
for y = Y0 + RY + 1, Y1 do
  local t = (y - Y0) / (Y1 - Y0)
  local r = RX + (RXB - RX) * t
  local x = floor(CX - r * 0.62 + 0.5)
  if side:has(x, y) then A.set(c, sidx, W, x, y, 6) end
end
c:put(20, Y0 + RY + 3, SPEC) c:put(21, Y0 + RY + 3, SPEC)
side:each(function(x, y)
  local k = K(x, y)
  if sidx[k] and sidx[k] >= 3 and sidx[k] <= 5 and side:has(x, y - 2) and side:has(x, y + 3) and X.hash(x, y, 5) > 0.93 then c:put(x, y, BLOOM) end
end)
for x = floor(CX - RXB), floor(CX + RXB) do
  local sx = (x - CX) / (RXB + 0.5)
  local y = floor(Y1 + RYB * sqrt(max(0, 1 - sx*sx)) - 4 + .5)
  if side:has(x, y) and (x % 7) ~= 3 then A.step(c, sidx, W, x, y, -1, 2) end
end
side:edge():each(function(x, y)
  local t = max(0, min(1, (y - Y0) / (Y1 - Y0)))
  local r = RX + (RXB - RX) * t
  if (x - CX) / r > 0.85 and y > Y0 + RY - 1 and y < Y1 + 2 then c:put(x, y, BOUNCE) end
end)

-- quirk: a rolled shaving lying against the foot (lit roll, spiral end on the right)
local ROLL = {
  ".aaaaaaab..",
  "abbbbbbcfee",
  "bccccccfeaf",
  "cdddddefaef",
  ".eeeeeeffe.",
}
local map = { a = W[6], b = W[5], c = W[4], d = W[3], e = W[2], f = W[1] }
local rx0, ry0 = 38, 42
for r = 1, #ROLL do for q = 1, #ROLL[r] do
  local ch = ROLL[r]:sub(q, q)
  if map[ch] then c:put(rx0 + q - 1, ry0 + r - 1, map[ch]) end
end end
-- AO on the cake foot just above/behind the roll
for x = rx0, rx0 + 9 do if side:has(x, ry0 - 1) then A.set(c, sidx, W, x, ry0 - 1, 1) end end

A.save(c, NAME)
