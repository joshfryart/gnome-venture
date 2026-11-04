-- ico-link (final, Opus). A short run of chain on the TL->BR diagonal: two face-on oval links with an edge-on link
-- threaded through both holes, passing over the first link's wire and under the last one (a true interlock).
-- Material: per-pixel lit polished steel (6 cool tones), torus normals on the face-on links (bevel ridge, bright
-- upper-left lip, dark inner rim), a cylinder bar with a dark slot for the edge-on link, specular glints,
-- contact shadow and AO where the links cross.
-- quirk: the last link was mended with a twist of copper wire.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA6_3.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, abs, floor, max, min, pi, atan, cos, sin = math.sqrt, math.abs, math.floor, math.max, math.min, math.pi, math.atan, math.cos, math.sin
local c = A.new("ico-link")
local ST = { "#2b2a46", "#47496d", "#6c7193", "#98a0bc", "#c6cde0", "#eef1f8" }
local SPEC = "#fff8e8"
local CU = { "#5a2420", "#9a4426", "#d0743a", "#f2a865" }
local OX, OY, ANG = 13.5, 13.5, pi / 4
local UX, UY = cos(ANG), sin(ANG)
local VX, VY = -UY, UX                  -- +v points lower-left
local function scr(u, v) return OX + u * UX + v * VX, OY + u * UY + v * VY end
local function loc(x, y) local dx, dy = x + .5 - OX, y + .5 - OY return dx * UX + dy * UY, dx * VX + dy * VY end

-- face-on oval ring centred at u=uc: outer semi-axes a (along), b (across), wire half thickness w
local function ring(uc, a, b, w)
  local m, n, R = HP.mask(), {}, {}
  local ca, cb = a - w, b - w
  local cx, cy = scr(uc, 0)
  for y = floor(cy - a - 2), floor(cy + a + 2) do for x = floor(cx - a - 2), floor(cx + a + 2) do
    local u, v = loc(x, y) u = u - uc
    local th = atan(v / cb, u / ca)
    -- refine nearest point on the centreline ellipse
    for _ = 1, 4 do
      local px, py = ca * cos(th), cb * sin(th)
      local tx, ty = -ca * sin(th), cb * cos(th)
      th = th + ((u - px) * tx + (v - py) * ty) / (tx * tx + ty * ty)
    end
    local du, dv = u - ca * cos(th), v - cb * sin(th)
    local r = sqrt(du * du + dv * dv)
    if r <= w + 0.15 then
      m:set(x, y)
      local s = min(0.97, r / (w + 0.45))
      local inu, inv = du / max(r, 1e-6), dv / max(r, 1e-6)
      local nx, ny = inu * UX + inv * VX, inu * UY + inv * VY
      n[K(x, y)] = { nx * s, ny * s, sqrt(1 - s * s) }
      R[K(x, y)] = { u = u, v = v, th = th }
    end
  end end
  return m, n, R
end

local W = 2.3
local mA, nA, RA = ring(10.5, 11, 8.4, W)
local mC, nC, RC = ring(41.5, 11, 8.4, W)
-- edge-on link B: stadium bar u 15..36, half width 3, with a 1 px slot
local mB, nB = HP.mask(), {}
local slot = HP.mask()
for y = 8, 56 do for x = 8, 56 do
  local u, v = loc(x, y)
  local uu = max(0, abs(u - 25.5) - 8.5)
  local r = sqrt(uu * uu + v * v)
  if r <= 3.05 then
    mB:set(x, y)
    local s = min(0.97, v / 3.5)
    local su = uu > 0 and (u > 25.5 and 1 or -1) * min(0.9, uu / 3.4) or 0
    local nx, ny = su * UX + s * VX, su * UY + s * VY
    nB[K(x, y)] = { nx, ny, sqrt(max(0.05, 1 - s * s - su * su)) }
    if abs(v) < 0.55 and abs(u - 25.5) < 7.5 then slot:set(x, y) end
  end
end end

local tokA, tokB, tokC = { r = { name = "linkA" } }, { r = { name = "linkB" } }, { r = { name = "linkC" } }
local cuts = { 0.3, 0.45, 0.59, 0.73, 0.88 }
-- paint order: A, then B over A (B passes over A's far wire), then C over B (B dips under C's near wire)
local bA = {}
A.X.ao(bA, mA, mB, 1, -1)
local iA = A.shade(c, mA, nA, ST, { tok = tokA, cuts = cuts, bias = bA, amb = 0.05, wrap = 0.18 })
-- contact shadow of B on A (B sits above): darken A pixels B would cover shifted down-right
mB:shift(1, 1):each(function(x, y) if mA:has(x, y) and not mB:has(x, y) then A.step(c, iA, ST, x, y, -2, tokA) end end)

local bB = {}
-- B goes into C's hole and under C's near wire: AO on B near C
A.X.ao(bB, mB, mC, 2, -1)
local iB = A.shade(c, mB, nB, ST, { tok = tokB, cuts = cuts, bias = bB, amb = 0.05, wrap = 0.18 })
-- B's tip inside A's hole is seen through the hole, slightly darker (it dips away)
mB:each(function(x, y) local u = loc(x, y) if u < 16.6 then A.step(c, iB, ST, x, y, -1, tokB) end end)
slot:each(function(x, y) c:put(x, y, ST[1], tokB) end)
-- separation: 1px deep line on B's border where it lies over A
mB:each(function(x, y) if not mB:has(x+1,y) and mA:has(x+1,y) or not mB:has(x-1,y) and mA:has(x-1,y)
  or not mB:has(x,y+1) and mA:has(x,y+1) or not mB:has(x,y-1) and mA:has(x,y-1) then c:put(x, y, ST[1], tokB) end end)
-- lit lip just above the slot
slot:shift(-1, 0):each(function(x, y) if mB:has(x, y) and not slot:has(x, y) then A.step(c, iB, ST, x, y, 1, tokB) end end)

local bC = {}
local iC = A.shade(c, mC, nC, ST, { tok = tokC, cuts = cuts, bias = bC, amb = 0.05, wrap = 0.18 })
mC:each(function(x, y) if not mC:has(x+1,y) and mB:has(x+1,y) or not mC:has(x-1,y) and mB:has(x-1,y)
  or not mC:has(x,y+1) and mB:has(x,y+1) or not mC:has(x,y-1) and mB:has(x,y-1) then c:put(x, y, ST[1], tokC) end end)
-- contact shadow of C onto B
mC:shift(1, 1):each(function(x, y) if mB:has(x, y) and not mC:has(x, y) then A.step(c, iB, ST, x, y, -2, tokB) end end)

-- specular glints on each lit shoulder
for _, p in ipairs{ { mA, nA }, { mC, nC }, { mB, nB } } do
  local bx, by = A.specAt(p[1], p[2], 30)
  if bx then c:put(bx, by, SPEC) end
end

-- quirk: copper wire twisted round C's far end (diagonal wraps = twist)
local wrap = HP.mask()
mC:each(function(x, y) local u = loc(x, y) if u > 48.2 and u < 51.4 then wrap:set(x, y) end end)
local wtok = { r = { name = "copper" } }
wrap:each(function(x, y)
  local u, v = loc(x, y)
  local ph = floor((u * 1.0 + v * 0.55 + 40)) % 2
  local lit = (iC[K(x, y)] or 3) >= 4
  c:put(x, y, ph == 0 and (lit and CU[2] or CU[1]) or (lit and CU[4] or CU[3]), wtok)
end)
-- a loose end of the wire sticking out
local lx, ly = scr(52.4, -3.4)
c:put(floor(lx + .5), floor(ly + .5), CU[3], wtok)
c:put(floor(lx + 1.5), floor(ly + .5), CU[4], wtok)
A.save(c, "ico-link")
