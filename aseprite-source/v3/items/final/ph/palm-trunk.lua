-- palm-trunk (final pass, Opus). A slim section of palm trunk lying on a shallow diagonal, the sawn end facing
-- the viewer at the upper-right.
-- Material: per-pixel cylinder light on a 6-tone grey-brown bark ramp; stacked leaf-base scar rings that bow with
-- the cylinder (dark groove + lit lip) and little chevron notches between them; fibre strands along the length; cool
-- reflected light on the underside. The sawn end shows palm wood: no growth rings, a dark bark rind, then a pale
-- fibrous face speckled with vascular-bundle dots (denser near the rind), lit bevel on the upper-left of the cut.
-- quirk: a tiny green gecko is sunbathing on top of the log.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC31_4.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "palm-trunk"
local c = A.new(NAME)
local BK   = { "#2e1f22", "#4b3330", "#6c4c3e", "#8e6a50", "#b08b68", "#d2b088" }
local FACE = { "#8a5a34", "#b8854e", "#dcae72", "#f0cc92", "#fbe4b4" }
local COOL = "#6a6a8a"
local btok = { r = { name = "bark" } }
local ftok = { r = { name = "face" } }

local AX, AY = 12, 41          -- far (left) end centre
local BX, BY = 48, 26          -- cut end centre
local R = 7.2
local dx, dy = BX - AX, BY - AY
local L = sqrt(dx*dx + dy*dy)
local tx, ty = dx / L, dy / L
local px, py = -ty, tx
if px + py < 0 then px, py = -px, -py end          -- +s = lower-right (shade side)
local E = 0.42                                       -- ellipse squash of the end caps along the axis
local function cap(x, y, t0) local a = (x - AX) * tx + (y - AY) * ty - t0 local s = (x - AX) * px + (y - AY) * py
  return (a / (R * E))^2 + (s / R)^2 <= 1.0 end
local body, face = HP.mask(), HP.mask()
local T, S = {}, {}
for y = 0, 63 do for x = 0, 63 do
  local a = (x - AX) * tx + (y - AY) * ty
  local s = (x - AX) * px + (y - AY) * py
  local inb = (a >= 0 and a <= L and abs(s) <= R) or cap(x, y, 0)
  if cap(x, y, L) then face:set(x, y) elseif inb then body:set(x, y) end
  if inb or cap(x, y, L) then T[K(x, y)], S[K(x, y)] = a, s end
end end
-- cylinder normals
local n = {}
body:each(function(x, y) local k = K(x, y) local sn = max(-0.97, min(0.97, S[k] / (R + 0.4)))
  n[k] = { px * sn, py * sn, sqrt(1 - sn*sn) } end)
local bias = {}
-- far end slightly darker (rounded off)
body:each(function(x, y) if T[K(x, y)] < 1 then bias[K(x, y)] = -1 end end)
-- the rim right behind the cut is in the face's shadow on the lower side
local idx = A.shade(c, body, n, BK, { amb = 0.06, wrap = 0.2, bias = bias, tok = btok })

-- leaf-base scar rings, bowed with the cylinder
local RS = 5.2
body:each(function(x, y) local k = K(x, y)
  local a, s = T[k], S[k]
  local q = a - (s / R)^2 * 1.8 - 2
  local ph = q % RS
  local ring = floor(q / RS)
  if a > 1.5 and a < L - 1 then
    if ph < 0.9 then A.step(c, idx, BK, x, y, -2, btok)
    elseif ph < 1.9 and idx[k] >= 3 then A.step(c, idx, BK, x, y, 1, btok)
    else
      -- chevron notch per ring band (leaf-base boot)
      local zz = (s + (ring % 2) * 2.5) % 5
      if abs(ph - 3.3 - abs(zz - 2.5) * 0.5) < 0.45 and abs(s) < R - 1 then A.step(c, idx, BK, x, y, -1, btok) end
    end
  end
  -- fibre flecks
  if X.hash(x, y, 5) < 0.06 and idx[k] >= 3 then A.step(c, idx, BK, x, y, -1, btok) end
end)
-- cool bounce on the underside
local rim = X.rim(n)
body:edge():each(function(x, y) local k = K(x, y) if rim[k] and rim[k] > 0.62 and T[k] > 2 and T[k] < L - 2 then c:put(x, y, COOL, btok) end end)

-- sawn end face: rind ring + pale fibrous face
face:each(function(x, y) local k = K(x, y)
  local a = T[k] - L local s = S[k]
  local rr = sqrt((a / (R * E))^2 + (s / R)^2)
  local col
  if rr > 0.8 then
    col = s < -2 and BK[3] or BK[2]
  else
    local lit = -(s / R) * 0.7 - (a / (R * E)) * 0.2
    local i = 3
    if lit > 0.35 then i = 4 end
    if lit < -0.3 then i = 2 end
    if rr > 0.62 and s < 0 then i = 5 end            -- lit bevel inside the rind, upper-left
    local h = X.hash(x, y, 9)
    if rr < 0.62 and h < 0.12 + rr * 0.25 then i = max(1, i - 2) end   -- vascular bundles
    col = FACE[i]
  end
  c:put(x, y, col, ftok)
end)
-- AO where bark meets the cut on the shade side
body:each(function(x, y) local k = K(x, y) if T[k] > L - 2.2 and S[k] > 1 then A.step(c, idx, BK, x, y, -1, btok) end end)
-- specular on the lit bark top
local spx = floor(AX + tx * L * 0.45 + px * -R * 0.55 + .5)
local spy = floor(AY + ty * L * 0.45 + py * -R * 0.55 + .5)
c:put(spx, spy, BK[6], btok) c:put(spx + 1, spy, BK[6], btok)

-- quirk: a tiny green gecko basking on the top of the log (head toward the cut end)
local GK = { o = "#24544a", d = "#3f9150", b = "#7cc35a", h = "#c4e07a", K = "#2b1c26", c = "#fff4d6", y = "#f5b82e" }
A.map(c, {
  "........bh.",
  ".....obbbhb",
  "..dbbbb.o..",
  "dd.o.......",
}, 25, 24, GK, { r = { name = "gecko" } })
c:put(34, 24, GK.K)       -- eye
c:put(33, 26, GK.d) c:put(31, 26, GK.d)   -- belly shade
A.save(c, NAME)
