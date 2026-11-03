-- ico-chair (final pass, Opus). Spindle-back kitchen chair in a three-quarter view: curved crest rail, two slim
-- uprights, three turned spindles, a thick plank seat (lit top, front edge, darker side with pale end grain),
-- four turned legs with a bead and an H-stretcher. Wood: per-pixel cylinder light on every turned part, 6-tone
-- honey wood with violet shade, grain streaks along each part, end-grain rings, AO where rails and legs meet the
-- seat, contact shadow on the floor.
-- quirk: the back-right leg is a bit short, so it stands on an acorn cap.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA2_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local c = A.new("ico-chair")
local WD = { "#45232a", "#6c372c", "#955233", "#bd7a46", "#dc9f5e", "#f3c886" }
local CAP = { "#3e3022", "#6a5232", "#957442", "#c1a060", "#e2c886" }
local wtok = A.tok("wood")
local CUT = { 0.16, 0.32, 0.48, 0.64, 0.82 }
local all = HP.mask()

c:groundShadow(36, 51, 13, 1)
c:groundShadow(28, 56, 18, 1.5)

local function grain(m, idx, vertical, seed)
  m:each(function(x, y)
    local a, b = vertical and x or y, vertical and floor(y / 4) or floor(x / 4)
    if X.hash(a, b, seed) < 0.22 then A.step(c, idx, WD, x, y, -1, wtok) end
  end)
end
local function vpart(x0, x1, y0, y1, seed, bead)
  local m = A.fn(x0, y0, x1, y1, function() return true end)
  if bead then for _, by in ipairs(bead) do m:set(x0 - 1, by) m:set(x1 + 1, by) end end
  local idx = A.shade(c, m, A.vcyl(m, x0, x1), WD, { tok = wtok, cuts = CUT })
  grain(m, idx, true, seed)
  if bead then for _, by in ipairs(bead) do
    for x = x0 - 1, x1 + 1 do A.step(c, idx, WD, x, by - 1, x <= x0 and 1 or 0, wtok) A.step(c, idx, WD, x, by + 1, -1, wtok) end
  end end
  all:add(m)
  return m, idx
end
local function hpart(x0, x1, y0, y1, seed)
  local m = A.fn(x0, y0, x1, y1, function() return true end)
  local idx = A.shade(c, m, A.hcyl(m, y0, y1), WD, { tok = wtok, cuts = CUT })
  grain(m, idx, false, seed)
  all:add(m)
  return m, idx
end

-- back legs (far) first
local blm, blidx = vpart(21, 23, 41, 50, 3)
local brm, bridx = vpart(45, 47, 34, 47, 4)
-- side stretcher (right, front-right leg to back-right leg) and front stretcher
local sstr, sidx = hpart(40, 44, 44, 46, 11)
for y = 44, 46 do A.step(c, sidx, WD, 44, y, -1, wtok) end
local fsm, fsidx = hpart(16, 36, 49, 51, 5)
-- front legs
local flm, flidx = vpart(13, 16, 41, 56, 1, { 47 })
local frm, fridx = vpart(36, 39, 41, 56, 2, { 47 })
-- AO on stretcher ends where they enter legs
for _, p in ipairs{ { 17, 49 }, { 17, 50 }, { 17, 51 }, { 35, 49 }, { 35, 50 }, { 35, 51 } } do A.step(c, fsidx, WD, p[1], p[2], -1, wtok) end

-- back: uprights, crest rail, spindles, lower rail
local ulm, ulidx = vpart(20, 23, 10, 32, 6)
local urm, uridx = vpart(45, 48, 10, 32, 7)
for _, sx in ipairs{ 27, 32, 37 } do
  local m, idx = vpart(sx, sx + 2, 14, 27, 10 + sx)
  for x = sx, sx + 2 do A.step(c, idx, WD, x, 14, -2, wtok) A.step(c, idx, WD, x, 15, -1, wtok) A.step(c, idx, WD, x, 27, -1, wtok) end
end
local crest = A.fn(18, 6, 50, 14, function(x, y)
  local top = 7 + ((x - 34) / 16) ^ 2 * 3
  local bot = top + 5.5 - ((x - 34) / 16) ^ 2 * 0.8
  return y >= floor(top + 0.5) and y <= bot
end)
local cidx = A.shade(c, crest, A.nfn(crest, function(x, y)
  local top = 7 + ((x - 34) / 16) ^ 2 * 3
  local mid = top + 2.7
  local s = max(-0.95, min(0.95, (y - mid) / 3.4))
  return (x - 34) / 40, s, sqrt(1 - s*s)
end), WD, { tok = wtok, cuts = CUT })
grain(crest, cidx, false, 8)
all:add(crest)
-- end grain caps on the crest ends
for _, x in ipairs{ 18, 50 } do crest:each(function(px, py) if px == x then c:put(px, py, x == 18 and WD[6] or WD[4], wtok) end end) end
-- AO on uprights/spindles just under the crest
for _, m in ipairs{ ulm, urm } do m:each(function(x, y) if crest:has(x, y - 1) and not crest:has(x, y) then c:put(x, y, WD[2], wtok) end end) end
local lrm, lridx = hpart(24, 44, 27, 29, 9)

-- seat: top face (parallelogram), front edge, right side
local top = c:poly{ { 12, 37 }, { 40, 37 }, { 48, 31 }, { 20, 31 } }
local tidx = A.shade(c, top, A.plane(top, { -0.1, -0.55, 1 }, 1.2), WD, { tok = wtok, cuts = { 0.16, 0.32, 0.48, 0.62, 0.8 } })
-- seat grain: lines parallel to the front edge, broken
top:each(function(x, y)
  if (y % 2 == 0) and X.hash(floor((x + y) / 5), y, 4) < 0.45 then A.step(c, tidx, WD, x, y, -1, wtok) end
end)
-- seat front lip highlight + top
for x = 13, 39 do A.set(c, tidx, WD, x, 37, 6, wtok) end
-- AO on the seat where the back uprights and lower rail rise from it
for x = 20, 48 do A.step(c, tidx, WD, x, 31, -2, wtok) A.step(c, tidx, WD, x, 32, -1, wtok) end
local front = A.fn(12, 38, 40, 40, function() return true end)
local fidx = A.shade(c, front, A.hcyl(front, 38, 40), WD, { tok = wtok, cuts = { 0.2, 0.36, 0.52, 0.7, 0.88 } })
grain(front, fidx, false, 12)
local side = c:poly{ { 41, 37 }, { 48, 31 }, { 48, 34 }, { 41, 40 } }
side:cut(front)
local sdidx = A.shade(c, side, A.plane(side, { 1, -0.2, 0.5 }), WD, { tok = wtok, cuts = { 0.3, 0.5, 0.7, 0.85, 0.95 } })
-- end grain rings on the side (pale arcs)
side:each(function(x, y) if (x + y) % 3 == 0 then A.step(c, sdidx, WD, x, y, 1, wtok) end end)
for x = 41, 48 do local y = floor(37 - (x - 41) * 6 / 7 + 0.5) if side:has(x, y) then c:put(x, y, WD[5], wtok) end end
-- AO under the seat on legs
for _, t in ipairs{ { flm, flidx }, { frm, fridx }, { blm, blidx }, { brm, bridx } } do
  t[1]:each(function(x, y)
    if front:has(x, y - 1) or side:has(x, y - 1) or top:has(x, y - 1) then A.step(c, t[2], WD, x, y, -2, wtok)
    elseif front:has(x, y - 2) or side:has(x, y - 2) then A.step(c, t[2], WD, x, y, -1, wtok) end
  end)
end
-- pop: 2x1 hi on the crest + cream sparkle on the seat front lip
c:put(23, 8, WD[6]) c:put(24, 8, WD[6])
c:put(15, 37, A.CREAM)

-- quirk: acorn cap under the short back-right leg (upside down cup, scaly)
A.map(c, {
  "..aaaa..",
  ".aBbBba.",
  "abAbAbAb",
  "bAbAbAbA",
  ".AdddddA",
}, 42, 47, { a = CAP[4], b = CAP[3], B = CAP[5], A = CAP[2], d = CAP[1] }, A.tok("cap"))
for x = 45, 47 do c:put(x, 46, WD[1], wtok) end

A.save(c, "ico-chair")
