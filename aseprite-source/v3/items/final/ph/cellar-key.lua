-- cellar-key (final, Opus single pass). An old wrought-iron cellar key laid on the diagonal: trefoil bow with three
-- pierced lobes and a sunken centre boss, a turned collar and a thin round shank, a stepped ward bit at the lower right.
-- Material: per-pixel iron light (6-tone cool iron), bevel on the bow, specular streak along the shank's lit side,
-- dark bores in the lobes, AO where the collar meets shank, freckles of rust in the crevices.
-- quirk: a tiny cellar spider dangles on a silk thread from the bow.
local NAME = "cellar-key"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r1_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local IRON = { "#262338", "#3d3a56", "#585a78", "#7d8199", "#a9adc0", "#dcdde8" }
local RUST = { "#6e2e24", "#a24a2a", "#cf7a3c" }
local tok = A.tok("iron")

-- shank axis
local ax, ay, bx, by = 21, 21, 50, 50
local L = sqrt((bx - ax)^2 + (by - ay)^2)
local ux, uy = (bx - ax) / L, (by - ay) / L
local px, py = -uy, ux                    -- across, +p = lower-left side
local function wfn(t)
  local a = t * L
  if a < 2.5 then return 2.9 end                         -- neck into bow
  if a >= 4.5 and a < 7.5 then return 3.0 end           -- turned collar
  if a >= 7.5 and a < 8.5 then return 2.2 end
  if a >= 10 and a < 11.6 then return 2.4 end           -- second thin ring
  return 1.55
end
local sm, sn, ST, SS = X.cyl(ax, ay, bx, by, wfn)
-- rounded tip
sm:each(function(x, y) local k = K(x, y) if ST[k] * L > L - 1 and abs(SS[k]) > 0.6 then sm.s[k] = nil end end)

-- bit: wards perpendicular to the shank on the +p side near the tip
local bit, bn = HP.mask(), {}
for y = 30, 62 do for x = 20, 62 do
  local rx, ry = x - ax, y - ay
  local a, b = rx * ux + ry * uy, rx * px + ry * py
  if a >= L - 9.5 and a <= L - 0.5 and b >= 1 and b <= 8.2 then
    local ok = true
    if b > 5.6 and a > L - 6.6 and a < L - 4.4 then ok = false end     -- ward notch
    if b > 3.4 and b < 4.6 and a > L - 2.6 then ok = false end          -- side cut
    if b > 6.8 and a < L - 8 then ok = false end                       -- chamfer
    if ok then bit:set(x, y) end
  end
end end
bit:cut(sm)
local bitN = X.pillow(bit, 1.6)

-- bow: three lobes + centre boss
local bcx, bcy = 16.5, 16.5
local bow, holes = HP.mask(), HP.mask()
local lobes = { { -1, -1 }, { 1.05, -0.95 }, { -0.95, 1.05 } }
for _, l in ipairs(lobes) do
  local d = 5.6 / sqrt(l[1]^2 + l[2]^2)
  local cx, cy = bcx + l[1] * d, bcy + l[2] * d
  bow:add(c:ellipse(cx, cy, 4.6, 4.6))
  holes:add(c:ellipse(cx + 0.2 * l[1], cy + 0.2 * l[2], 1.7, 1.7))
end
bow:add(c:ellipse(bcx, bcy, 4.6, 4.6))
bow:add(c:ellipse(bcx + 3.2, bcy + 3.2, 3.1, 3.1))
bow:cut(holes)
bow:cut(sm)
local bowN = X.pillow(bow, 2.4)

-- shading
local bias = {}
X.ao(bias, sm, bow, 1, -1)
local idx = {}
for k, v in pairs(A.shade(c, bow, bowN, IRON, { tok = tok, amb = 0.1, wrap = 0.3 })) do idx[k] = v end
-- boss: sunken disc in the bow centre
local boss = c:ellipse(bcx, bcy, 2, 2)
boss:each(function(x, y) local d = (x - bcx) + (y - bcy) c:put(x, y, d < -1 and IRON[2] or (d > 1 and IRON[5] or IRON[3]), tok) end)
c:px(floor(bcx), floor(bcy), IRON[4])
for k, v in pairs(A.shade(c, sm, sn, IRON, { tok = tok, bias = bias, amb = 0.12, wrap = 0.3 })) do idx[k] = v end
-- collar AO edges: dark ring row where the collar steps down
sm:each(function(x, y) local k = K(x, y) local a = ST[k] * L
  if (a >= 7.5 and a < 8.5) or (a >= 2.5 and a < 3.3) then A.step(c, idx, IRON, x, y, -2, tok) end
  if a >= 4.5 and a < 5.3 and SS[k] < 0.3 then A.step(c, idx, IRON, x, y, 1, tok) end
end)
for k, v in pairs(A.shade(c, bit, bitN, IRON, { tok = tok, amb = 0.1, wrap = 0.25 })) do idx[k] = v end
-- AO where bit meets shank
bit:each(function(x, y) if sm:grow(1):has(x, y) then A.step(c, idx, IRON, x, y, -1, tok) end end)
-- specular streak along the shank lit side
sm:each(function(x, y) local k = K(x, y) local a = ST[k] * L
  if a > 13 and a < 33 and SS[k] < -0.25 and SS[k] > -0.75 then c:put(x, y, IRON[6], tok) end end)
-- bevel highlight on the upper-left lobe rim
bow:edge():each(function(x, y) local k = K(x, y)
  if idx[k] and idx[k] >= 5 and X.hash(x, y, 3) > 0.35 then c:put(x, y, IRON[6], tok) end end)
-- bores in the lobes: dark inner rim on the lit (upper-left) side of each hole
holes:grow(1):cut(holes):each(function(x, y)
  if bow:has(x, y) then
    for _, l in ipairs(lobes) do end
    A.step(c, idx, IRON, x, y, -1, tok)
  end
end)
-- rust freckles in crevices (darker pixels only)
local rustAt = { { 12, 21 }, { 20, 23 }, { 26, 27 }, { 41, 46 }, { 44, 49 }, { 22, 12 } }
for _, p in ipairs(rustAt) do
  if bow:has(p[1], p[2]) or sm:has(p[1], p[2]) or bit:has(p[1], p[2]) then c:put(p[1], p[2], RUST[2], tok) end
end
bit:each(function(x, y) local k = K(x, y) if idx[k] and idx[k] <= 3 and X.hash(x, y, 9) > 0.8 then c:put(x, y, RUST[1], tok) end end)
c:px(13, 22, RUST[3])
-- glint
c:px(11, 10, A.CREAM) c:px(12, 10, IRON[6])

-- quirk: spider on a silk thread off the lower-left lobe
local SILK = "#cfd3e6"
local tx = 9
for y = 24, 34 do c:put(tx, y, SILK) end
local SP = { "#3a2340", "#5c3a5e", "#8a6290" }
-- body (abdomen 3x3, head 2x1) and legs
c:paint({
  "s..s..s",
  ".s.a.s.",
  "..bbb..",
  "sbbbbbs",
  "..bbb..",
  ".s...s.",
}, tx - 3, 35, { s = SP[2], a = SP[1], b = SP[1] })
c:px(tx - 1, 37, SP[3]) c:px(tx, 37, SP[2])

A.save(c, NAME)
