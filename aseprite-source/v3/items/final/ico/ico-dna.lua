-- ico-dna (final, Opus). A slim upright double helix, one and a half turns: a coral strand and a teal strand cross in front
-- of each other, joined by base-pair rungs (gold/moss halves). Material: per-pixel cylinder light along each strand
-- (6-tone ramps), the back half of each turn sinks a step darker, twisted-ribbon grooves across the strands, AO where
-- the rungs plug into the strands and a dark seam where the front strand crosses the back one; glossy specular on
-- the front crossings.
-- quirk: one rung is a mismatched pink pair, with a cream sparkle: a tiny mutation.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA3_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin, cos, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local c = A.new("ico-dna")
local CORAL = { "#5e1a34", "#9a2a3e", "#d04440", "#f26a4c", "#ff9a6a", "#ffcf9e" }
local TEAL  = { "#1e2f5c", "#24508a", "#2f7cae", "#45a8c4", "#78d0d4", "#c4f2e6" }
local GOLD  = { "#6e3a1e", "#a8601e", "#e0962a", "#f8c444", "#ffe68e" }
local MOSS  = { "#1e4a3e", "#2f7446", "#4fa050", "#84c860", "#c4e68a" }
local PINK  = { "#6e2450", "#b2427a", "#ec7aa0", "#ffb6cc", "#ffe0e8" }
local SPEC = "#fff4d6"

local Y0, Y1, CX, AMP, HW = 8, 56, 32, 11.5, 1.95
local TURNS = 1.5
local function ph(y) return (y - Y0) / (Y1 - Y0) * TURNS * 2 * pi + 0.0 end
-- strand samples
local function strand(off)
  local s = {}
  for i = 0, 600 do
    local y = Y0 + (Y1 - Y0) * i / 600
    local p = ph(y) + off
    s[#s + 1] = { x = CX + AMP * sin(p), y = y, z = cos(p), t = i / 600, dx = AMP * cos(p) * TURNS * 2 * pi / (Y1 - Y0) }
  end
  return s
end
local SA, SB = strand(0), strand(pi)
local function nearest(S, x, y)
  local best, bs = 1e9
  for _, s in ipairs(S) do local q = (x - s.x)^2 + (y - s.y)^2 if q < best then best, bs = q, s end end
  return sqrt(best), bs
end
-- masks + per-pixel data for both strands
local data = {}
local mA, mB = HP.mask(), HP.mask()
for y = Y0 - 4, Y1 + 4 do for x = CX - 16, CX + 16 do
  local px, py = x + 0.5, y + 0.5
  for si, S in ipairs{ SA, SB } do
    local d, s = nearest(S, px, py)
    -- width swells slightly when the strand faces the viewer
    local w = HW + 0.3 * s.z
    if d <= w then
      local tx, ty = s.dx, 1 local l = sqrt(tx * tx + 1) tx, ty = tx / l, ty / l
      local nx, ny = ty, -tx  -- perpendicular
      if nx + ny < 0 then nx, ny = -nx, -ny end
      local sd = ((px - s.x) * nx + (py - s.y) * ny) / (w + 0.5)
      sd = max(-0.95, min(0.95, sd))
      data[si] = data[si] or {}
      data[si][K(x, y)] = { n = { nx * sd, ny * sd, sqrt(1 - sd * sd) }, z = s.z, y = s.y, sd = sd }
      if si == 1 then mA:set(x, y) else mB:set(x, y) end
    end
  end
end end
-- rungs: base pairs spaced along y where the strands are apart
local rungs = {}
local ry = Y0 + 1
local ri = 0
while ry <= Y1 - 2 do
  local p = ph(ry + 1)
  if abs(sin(p)) > 0.36 then
    ri = ri + 1
    local xa, xb = CX + AMP * sin(p), CX - AMP * sin(p)
    rungs[#rungs + 1] = { y = ry, x0 = floor(min(xa, xb) + 0.5), x1 = floor(max(xa, xb) + 0.5), z = cos(p), i = ri, left = (xa < xb) and 1 or 2 }
  end
  ry = ry + 5
end
-- paint rungs first (they sit between/behind the strands)
local rtok = A.tok("rung")
local rungMask = HP.mask()
for _, r in ipairs(rungs) do
  local mid = floor((r.x0 + r.x1) / 2 + 0.5)
  local mut = (r.i == 5)
  for x = r.x0, r.x1 do
    local half = (x < mid) and 1 or 2
    local ramp
    if mut then ramp = PINK else ramp = (half == 1) == (r.i % 2 == 0) and GOLD or MOSS end
    for dy = 0, 2 do
      local y = r.y + dy
      local i = ({ 4, 3, 2 })[dy + 1]
      if dy == 0 and x < mid - 1 then i = 5 end
      if x == mid or x == mid - 1 and false then i = max(1, i - 1) end
      if x == mid then i = 1 end -- the pair junction
      rungMask:set(x, y)
      c:put(x, y, ramp[i], rtok)
    end
  end
  if mut then c:sparkle(mid + 1, r.y - 2) end
end
-- strands: back pixels first, then front; per pixel pick the strand nearer the viewer
local tokA, tokB = A.tok("strandA"), A.tok("strandB")
local function paintStrand(si, m, ramp, tok, front)
  local mm = HP.mask()
  m:each(function(x, y)
    local me = data[si][K(x, y)]
    local other = data[3 - si] and data[3 - si][K(x, y)]
    local isFront = me.z >= 0
    if isFront == front then
      if not other or other.z <= me.z or not front then mm:set(x, y) end
    end
  end)
  local n, bias = {}, {}
  mm:each(function(x, y) local k = K(x, y) n[k] = data[si][k].n
    if data[si][k].z < 0 then bias[k] = -1 end
    if data[si][k].z < -0.7 then bias[k] = -2 end
  end)
  -- AO where rungs plug in
  X.ao(bias, mm, rungMask, 1, -1)
  local idx = A.shade(c, mm, n, ramp, { amb = 0.1, wrap = 0.3, bias = bias, tok = tok, cuts = { 0.18, 0.34, 0.52, 0.7, 0.88 } })
  -- twisted ribbon grooves: a darker diagonal tick every 4 px of length
  mm:each(function(x, y) local k = K(x, y) local d = data[si][k]
    local g = (d.y + d.sd * 1.6 * (si == 1 and 1 or -1)) % 4.6
    if g < 0.9 and abs(d.sd) < 0.75 then A.step(c, idx, ramp, x, y, -1, tok) end
  end)
  return mm, idx
end
local backA = paintStrand(1, mA, CORAL, tokA, false)
local backB = paintStrand(2, mB, TEAL, tokB, false)
local frontA, iA = paintStrand(1, mA, CORAL, tokA, true)
local frontB, iB = paintStrand(2, mB, TEAL, tokB, true)
-- dark seam on back strand pixels touching a front strand of the other colour
local function seam(back, front, ramp, tok)
  back:each(function(x, y)
    if (front:has(x + 1, y) or front:has(x - 1, y) or front:has(x, y + 1) or front:has(x, y - 1))
      and not front:has(x, y) then c:put(x, y, ramp[1], tok) end
  end)
end
seam(backA, frontB, CORAL, tokA) seam(backB, frontA, TEAL, tokB)
-- also the rung under a front strand gets a dark row (contact shadow)
rungMask:each(function(x, y)
  if (frontA:has(x - 1, y) or frontB:has(x - 1, y) or frontA:has(x + 1, y) or frontB:has(x + 1, y))
    and not frontA:has(x, y) and not frontB:has(x, y) and not backA:has(x, y) and not backB:has(x, y) then
    local cur = c:get(x, y)
    for _, R in ipairs{ GOLD, MOSS, PINK } do for i, h in ipairs(R) do if h == cur then c:put(x, y, R[max(1, i - 2)], rtok) end end end
  end
end)
-- glossy specular on the front crossings (where z ~ 1, strand centre-lit)
local function glints(front, si)
  local done = {}
  front:each(function(x, y) local d = data[si][K(x, y)]
    if d.z > 0.97 and d.sd < -0.25 and d.sd > -0.6 then
      local band = floor(d.y / 12)
      if not done[band] then done[band] = { x, y } elseif y < done[band][2] then done[band] = { x, y } end
    end
  end)
  for _, p in pairs(done) do c:put(p[1], p[2], SPEC, si == 1 and tokA or tokB) c:put(p[1], p[2] + 1, (si == 1 and CORAL or TEAL)[6], si == 1 and tokA or tokB) end
end
glints(frontA, 1) glints(frontB, 2)
A.save(c, "ico-dna")
