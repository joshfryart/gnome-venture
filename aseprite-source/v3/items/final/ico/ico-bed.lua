-- ico-bed (Opus single pass). Side view: tall slim headboard post with a turned finial (left), shorter footboard
-- post (right), plank side rail on slim legs with air underneath. Plump cream pillow leaning on the headboard,
-- a blue quilt draped over the mattress with hanging folds, turned-back sheet cuff and one gold hem stitch.
-- Material: wood grain streaks + knot, pale end grain on the finials, bevelled rail; cloth fold lines; AO where
-- pillow/quilt meet wood, contact shadow on the rail under the quilt hem.
-- quirk: a red striped nightcap hangs off the headboard finial.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA1_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, abs, max, min, sqrt, pi = math.floor, math.sin, math.cos, math.abs, math.max, math.min, math.sqrt, math.pi
local c = A.new("ico-bed")
local WOOD = { "#3e2228", "#5e3529", "#86512f", "#ac713f", "#cf9758", "#ecc185" }
local QUILT = { "#1e2a58", "#283f86", "#3360b4", "#4683d6", "#73aef0", "#b4dcfa" }
local CLOTH = { "#7a5a68", "#ad8f8e", "#d6bea6", "#eedbbb", "#faecd2", "#fff8e8" }
local CAP = { "#5a1a32", "#8e2438", "#c2363c", "#e8553f", "#ff8a5c", "#ffb990" }
local GOLD = "#f5b82e"

c:groundShadow(31, 55, 24, 1)

-- legs + posts (wood), drawn first; cloth paints over where it sits in front
local function post(x0, x1, y0, y1)
  local m = c:rect(x0, y0, x1, y1)
  local n = {}
  m:each(function(x, y)
    local t = ((x - x0) / (x1 - x0)) * 2 - 1
    t = max(-.95, min(.95, t)) n[K(x, y)] = { t, 0, sqrt(1 - t * t) } end)
  local idx = A.shade(m, n, WOOD, { amb = 0.1, wrap = 0.3 })
  -- grain: a wavering streak one tone down, with breaks
  for y = y0 + 2, y1 - 1 do
    local gx = floor(x0 + 1.6 + 0.9 * sin(y * 0.45) + .5)
    if X.hash(gx, y, 3) > 0.18 then A.sh(idx, WOOD, gx, y, -1) end
  end
  return m, idx
end
local hm, hidx = post(9, 12, 15, 54)
local fm, fidx = post(50, 53, 30, 54)
-- finials: turned ball + neck collar, end grain paler on top
local function finial(cx, cy, r, ny)
  local col = c:rect(floor(cx) - 2, ny, floor(cx) + 2, ny + 1)
  local cn = {}
  col:each(function(x, y) local t = max(-.95, min(.95, (x - cx) / 2.6)) cn[K(x, y)] = { t, -0.3, sqrt(1 - t * t) } end)
  local cidx = A.shade(col, cn, WOOD)
  local bm = c:ellipse(cx, cy, r, r)
  local bn = X.sphere(cx - .3, cy - .3, r, bm)
  local bidx = A.shade(bm, bn, WOOD, { amb = 0.06 })
  A.ao(bidx, WOOD, bm, col, 1, -1)
  -- end-grain rings on the cap
  c:px(floor(cx) - 1, floor(cy - r) + 1, WOOD[6]) c:px(floor(cx), floor(cy - r) + 1, WOOD[6])
  return bm, bidx
end
local hb = finial(10.5, 11.5, 3, 14)
local fb = finial(51.5, 27, 2.5, 29)

-- side rail plank, bevelled, horizontal grain + knot
local rail = c:rect(13, 42, 49, 47)
local rn = {}
rail:each(function(x, y)
  local t = (y - 42) / 5
  local ny = t < 0.25 and -0.75 or (t > 0.8 and 0.8 or 0)
  rn[K(x, y)] = { 0, ny, sqrt(1 - ny * ny) } end)
local ridx = A.shade(rail, rn, WOOD, { amb = 0.12 })
for x = 14, 48 do
  local gy = floor(44.5 + 0.8 * sin(x * 0.28) + .5)
  if X.hash(x, gy, 7) > 0.22 then A.sh(ridx, WOOD, x, gy, -1) end
end
c:px(20, 45, WOOD[2]) c:px(21, 45, WOOD[2]) c:px(19, 45, WOOD[3]) c:px(22, 45, WOOD[3]) c:px(20, 44, WOOD[3])
A.ao(ridx, WOOD, rail, hm, 1, -1) A.ao(ridx, WOOD, rail, fm, 1, -1)
A.ao(hidx, WOOD, hm, rail, 1, -1) A.ao(fidx, WOOD, fm, rail, 1, -1)

-- mattress (cream, quilted tick)
local TICK = { "#3e3466", "#5d5390", "#8378b4", "#a89ed0", "#c9c2e6", "#e6e1f4" }
local mat = c:rrect(13, 34, 49, 42, 1)
local mn = X.pillow(mat, 2)
local midx = A.shade(mat, mn, TICK)
A.ao(midx, TICK, mat, hm, 1, -1)
for x = 15, 23, 3 do for y = 35, 41 do A.sh(midx, TICK, x, y, -1) end end
for x = 14, 23 do A.sh(midx, TICK, x, 34, 1) end

-- pillow: puffy, pinched corners, leaning on the headboard
local pil = A.egg(19.5, 30, 6.6, 3.8, -0.15, 0.8)
pil:set(26, 26) pil:set(13, 33)
local pn = X.pillow(pil, 3)
local pbias = {}
local pidx = A.shade(pil, pn, CLOTH, { bias = pbias })
A.ao(pidx, CLOTH, pil, hm, 1, -1)
-- pillow dent seam
A.ln(16, 30, 21, 32, CLOTH[3], pil) A.ln(21, 32, 23, 31, CLOTH[3], pil)
A.ao(midx, TICK, mat, pil, 1, -1)

-- quilt: top surface + hanging drape with folds, wavy hem, turned-back cuff
local q = HP.mask()
for x = 24, 49 do
  local top = 32 + (x < 27 and 1 or 0) + ((x > 33 and x < 44) and -1 or 0)
  local bot = 43 + ((x % 6 == 2 or x % 6 == 3) and 1 or 0)
  for y = top, bot do q:set(x, y) end
end
local qn, qd = X.pillow(q, 2)
for k, nn in pairs(qn) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  if y >= 35 then
    local f = sin((x - 24) * 2 * pi / 6)
    nn[1] = nn[1] + f * 0.55
    local l = sqrt(nn[1]^2 + nn[2]^2 + nn[3]^2) nn[1], nn[2], nn[3] = nn[1]/l, nn[2]/l, nn[3]/l
  else
    nn[2] = nn[2] - 0.5 local l = sqrt(nn[1]^2 + nn[2]^2 + nn[3]^2) nn[1], nn[2], nn[3] = nn[1]/l, nn[2]/l, nn[3]/l
  end
end
local qidx = A.shade(q, qn, QUILT, { amb = 0.1, wrap = 0.3 })
-- edge between top surface and drape (the mattress corner)
for x = 27, 49 do A.sh(qidx, QUILT, x, 35, -1) end
for x = 28, 48 do if X.hash(x, 34, 2) > 0.5 then A.sh(qidx, QUILT, x, 33, 1) end end
A.ao(qidx, QUILT, q, fm, 1, -1)
-- cuff (turned-back sheet)
local cuff = HP.mask()
for y = 33, 44 do for x = 24, 26 do if q:has(x, y) then cuff:set(x, y) end end end
local cn = {}
cuff:each(function(x, y) local t = (x - 25) / 1.6 cn[K(x, y)] = { t * 0.8, 0, sqrt(1 - min(.9, (t * .8)^2)) } end)
local cidx = A.shade(cuff, cn, CLOTH)
for y = 33, 44 do if q:has(27, y) then A.sh(qidx, QUILT, 27, y, -2) end end
-- one hem stitch
for x = 29, 47 do if (x - 29) % 3 ~= 2 then c:px(x, 41, GOLD) end end
-- contact shadow on the rail under the hem
for x = 24, 49 do local by = 44 + ((x % 6 == 2 or x % 6 == 3) and 1 or 0)
  if rail:has(x, by + 1) then A.sh(ridx, WOOD, x, by + 1, -2) end end

-- quirk: red striped nightcap hanging off the headboard finial, cream pompom
local capm = c:poly{ { 7, 10 }, { 8, 7 }, { 11, 5 }, { 14, 6 }, { 17, 9 }, { 19, 14 }, { 20, 19 }, { 18, 19 }, { 16, 14 }, { 14, 11 }, { 8, 11 } }
local capn = X.pillow(capm, 1.6)
local capidx = A.shade(capm, capn, CAP)
capm:each(function(x, y) if (x + y) % 5 == 0 then A.sh(capidx, CAP, x, y, 2) end end)
local pom = c:ellipse(18.5, 21, 1.6, 1.6)
local pomn = X.sphere(18, 20.5, 1.8, pom)
A.shade(pom, pomn, CLOTH)
A.ao(capidx, CAP, capm, pom, 1, -1)
-- cream brim band around the finial
for x = 7, 14 do if capm:has(x, 10) then c:px(x, 10, x < 10 and CLOTH[6] or CLOTH[4]) end
  if capm:has(x, 11) then c:px(x, 11, x < 10 and CLOTH[4] or CLOTH[3]) end end

A.save("ico-bed")
