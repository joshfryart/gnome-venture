-- acorn-cap (final pass, Opus). An empty oak cupule seen from the front and a little above: a slim scaly bowl
-- (rows of overlapping, downward-pointing scales with dark crevices and pale fuzzy tips, shrinking toward the base),
-- a thick scaly lip, a smooth pale inner bowl lit on its far (lower-right) wall with fine growth rings and an AO
-- band under the near lip, and a short twisted stalk at the base.
-- Material: per-pixel sphere light on the outside (6 tones), concave light inside (6 tones), scale relief by tone
-- bias, cool reflected light on the lower-right flank, AO where stalk meets bowl.
-- History: Sonnet draft replaced.
-- quirk: last night's rain still sits in the cup, a tiny pool with a glint.
local NAME = "acorn-cap"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR1_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, asin = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.asin
local c = A.new(NAME)

local SC   = { "#33201f", "#523528", "#73503a", "#94704e", "#b7966a", "#d8c094" }   -- scales (grey-brown)
local IN   = { "#5a3a2c", "#86603e", "#ad8656", "#c9a46e", "#e2c38c", "#f4e0b2" }   -- inner bowl
local ST   = { "#3a2422", "#5e3a2a", "#84552f", "#a87240", "#c8965a" }              -- stalk
local COOL = "#5c5872"
local WAT  = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }

local CX, CY = 32, 24
local ORX, ORY = 17.5, 7.6       -- outer lip ellipse
local IRX, IRY = 14.4, 5.7       -- inner opening
local BRY = 22                   -- bowl depth below the lip centre line

-- masks
local lip = c:ellipse(CX, CY, ORX, ORY)
local bowl = c:ellipse(CX, CY, ORX, BRY)
local below = HP.mask() bowl:each(function(x, y) if y >= CY then below:set(x, y) end end)
local outer = below:copy():cut(lip)            -- visible outside wall (front)
local inner = c:ellipse(CX, CY - 0.4, IRX, IRY)
local ring = lip:copy():cut(inner)              -- the lip itself

-- stalk (drawn first, bowl overlaps its foot)
local stok = { r = { name = "stalk" } }
local sp = { { 33, 43 }, { 34, 48 }, { 37, 51 }, { 41, 52 } }
local sm, sn, STT, SS = A.tube(sp, function(t) return 1.55 - 0.35 * t end)
sm:cut(bowl)
local sidx = A.shade(c, sm, sn, ST, { amb = 0.1, wrap = 0.3, cuts = { 0.25, 0.45, 0.65, 0.82 }, tok = stok })
-- twist: diagonal dark grooves along the stalk
sm:each(function(x, y) local k = K(x, y)
  local ph = STT[k] * 9 + SS[k] * 0.9
  if (ph - floor(ph)) < 0.28 then A.step(c, sidx, ST, x, y, -1, stok) end end)
-- cut end of the stalk: pale end grain
c:put(42, 51, ST[5], stok) c:put(42, 52, ST[4], stok) c:put(42, 53, ST[3], stok)

-- outside wall: sphere light + scale relief
local otok = { r = { name = "scales" } }
local on = X.sphere(CX - 1, CY + 2, ORX + 1, outer)
local ov = X.light(on, { amb = 0.1, wrap = 0.3 })
local bias = {}
local tipK = {}
outer:each(function(x, y) local k = K(x, y)
  local u = max(-0.999, min(0.999, (x - CX) / (ORX + 0.5)))
  local cu = sqrt(1 - u * u)
  local rho = (y - CY) / max(cu, 0.25)         -- latitude: ORY at the lip front .. BRY at the base
  local row = (rho - ORY + 0.8) / 3.9
  local ri = floor(row) local b = row - ri       -- b: 0 top of scale .. 1 tip
  local phi = asin(u) / (pi / (10 - ri * 1.4)) + (ri % 2) * 0.5
  local a = phi - floor(phi)                       -- 0..1 across the scale
  local half = 0.5 * (1 - b ^ 2.2 * 0.75)
  local d = abs(a - 0.5)
  if d > half then bias[k] = -3                    -- crevice between tips
  elseif b < 0.26 then bias[k] = -1                 -- shadow under the row above
  elseif b > 0.62 and d < 0.26 then bias[k] = 2 tipK[k] = true end  -- fuzzy pale tip
end)
-- AO under the lip front edge
X.ao(bias, outer, lip, 1, -1)
local oidx = X.tone(c, outer, ov, SC, { cuts = { 0.16, 0.32, 0.48, 0.64, 0.8 }, bias = bias, tok = otok })
-- cool reflected light on the lower-right flank
outer:edge():each(function(x, y) local k = K(x, y)
  if x > CX + 6 and y > CY + 6 and (oidx[k] or 1) <= 3 and not lip:has(x, y - 1) then c:put(x, y, COOL, otok) end end)

-- lip: scales seen end-on, radial crevices, lit top
local rtok = { r = { name = "lip" } }
local rn = {}
ring:each(function(x, y)
  local dx, dy = (x - CX) / ORX, (y - CY) / ORY
  rn[K(x, y)] = { A.norm(dx * 0.55, dy * 0.35 - 0.5, 1) }
end)
local rb = {}
ring:each(function(x, y) local k = K(x, y)
  local ang = math.atan(((y - CY) / ORY), ((x - CX) / ORX))
  local f = (ang / (2 * pi)) * 34
  rb[k] = -1
  if (f - floor(f)) < 0.24 then rb[k] = -2 end
  -- inner edge of the lip (top of the far wall) gets a dark row
  if not inner:has(x, y) and (inner:has(x, y + 1) or inner:has(x + 1, y) or inner:has(x - 1, y)) then rb[k] = -3 end
end)
local ridx = X.tone(c, ring, X.light(rn, { amb = 0.15, wrap = 0.3 }), SC, { cuts = { 0.15, 0.3, 0.46, 0.62, 0.8 }, bias = rb, tok = rtok })

-- inside: concave light (far lower-right wall lit), growth rings, AO under the near-left lip
local itok = { r = { name = "inside" } }
local inn = {}
inner:each(function(x, y)
  local dx, dy = (x - CX) / (IRX + 0.5), (y - CY + 0.4) / (IRY + 0.5)
  inn[K(x, y)] = { A.norm(-dx * 0.85, -dy * 0.7, 0.55) }
end)
local ib = {}
X.ao(ib, inner, ring, 1, -1)
inner:each(function(x, y) local k = K(x, y)
  local dx, dy = (x - CX) / (IRX + 0.5), (y - CY + 0.4) / (IRY + 0.5)
  local r = sqrt(dx * dx + dy * dy)
  if r < 0.88 and r > 0.25 and (r * 6.5) % 1 < 0.17 then ib[k] = (ib[k] or 0) - 1 end
  if y < CY - 3 then ib[k] = (ib[k] or 0) - 1 end          -- far wall under the lip, in the lip's shade
end)
local iidx = X.tone(c, inner, X.light(inn, { amb = 0.1, wrap = 0.3 }), IN, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = ib, tok = itok })

-- quirk: rain pool in the bottom of the cup (ink-dark meniscus edge, sky core, glint)
local wtok = { r = { name = "water" } }
local pool = c:ellipse(33, 26, 6.2, 1.8)
pool:each(function(x, y)
  local dx, dy = (x - 33) / 6.7, (y - 26) / 2.3
  local i = 3
  if dy < -0.35 then i = 2 end
  if dx > 0.45 and dy > -0.2 then i = 4 end
  if dx < -0.6 then i = 2 end
  c:put(x, y, WAT[i], wtok)
end)
pool:grow(1):cut(pool):each(function(x, y) if inner:has(x, y) and y >= 26 then c:put(x, y, IN[2], itok) end end)
c:put(30, 25, "#fff4d6", wtok) c:put(31, 25, WAT[4], wtok)

-- glint on the lip (one, upper-left)
c:put(20, 20, SC[6], rtok) c:put(21, 19, "#efe0b8", rtok)

A.save(c, "ph", NAME)
