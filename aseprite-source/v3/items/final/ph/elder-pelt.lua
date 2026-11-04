-- elder-pelt (final pass, Opus single pass). The pelt of an old forest beast laid out flat and slightly turned:
-- an oval hide with four tapering leg flaps, a neck flap with two ear points and a thin tail; the left hind flap is
-- turned up to show the tanned leather underside.
-- Material: mossy grey-green fur lit per pixel (pillow normals, 6 tones), a dark parted spine with lit fur either
-- side, fur strands combed outward from the spine, faint darker bands across the back, tufted edge pixels;
-- leather flap with a crease, a lit fold edge and AO where it lies on the fur.
-- quirk: a tiny brown-capped mushroom has sprouted from the old fur at the shoulder.
local NAME = "elder-pelt"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB2r0_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min, sin, cos = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.cos
local c = A.new(NAME)

local FUR  = { "#1f2e36", "#33493f", "#4c6a47", "#6c8c52", "#97ae66", "#c8d590" }
local LEA  = { "#4e2a26", "#7e4a36", "#a8704a", "#cc9a66", "#ebc790" }
local MUSH = { "#5a2e22", "#8a4a2c", "#c27a44", "#f0b878" }
local tokF, tokL = { r = { name = "fur" } }, { r = { name = "leather" } }

local CX, CY, TH = 32, 32, 0.28
local ct, st = cos(TH), sin(TH)
local function W(lx, ly) return CX + lx * ct - ly * st, CY + lx * st + ly * ct end       -- local -> canvas
local function L(x, y) local dx, dy = x - CX, y - CY return dx * ct + dy * st, -dx * st + dy * ct end

-- hide silhouette
local fur = HP.mask()
local wx, wy = W(0, 0)
fur:add(A.rell(wx, wy, ct, st, 13.5, 16))
local function flap(ax, ay, bx, by, w0, w1)
  local x0, y0 = W(ax, ay) local x3, y3 = W(bx, by)
  local x1, y1 = W(ax + (bx - ax) * 0.5, ay + (by - ay) * 0.35)
  local m = A.tube({ { x0, y0 }, { x1, y1 }, { x1 + (x3 - x1) * 0.5, y1 + (y3 - y1) * 0.6 }, { x3, y3 } },
    function(t) return w0 + (w1 - w0) * t end)
  return m
end
fur:add(flap(-8, -9, -17, -14, 5.4, 2.8))   -- fore legs
fur:add(flap(8, -9, 17, -14, 5.4, 2.8))
fur:add(flap(8, 9, 17, 16, 5.6, 2.8))       -- hind right
fur:add(flap(0, -14, 0, -20, 5.2, 3.8))   -- neck
do local x, y = W(-3, -22.5) fur:set(floor(x + .5), floor(y + .5)) x, y = W(3, -22.5) fur:set(floor(x + .5), floor(y + .5))
   x, y = W(-2.8, -21.6) fur:set(floor(x + .5), floor(y + .5)) x, y = W(2.8, -21.6) fur:set(floor(x + .5), floor(y + .5)) end
fur:add(flap(0, 15, 3, 23.5, 2.8, 0.8))     -- tail
local hindL = flap(-8, 9, -17, 16, 5.6, 2.8)
fur:add(hindL)
-- tufted edge: a few pixels pushed out along the border
fur:edge():each(function(x, y)
  if X.hash(x, y, 21) < 0.16 then
    local lx, ly = L(x, y)
    local ox, oy = (lx > 0) and 1 or -1, (ly > 0) and 1 or 0
    fur:set(x + (X.hash(x, y, 4) < 0.5 and ox or 0), y + oy)
  end
end)

local n = X.pillow(fur, 4, 0.8)
local bias = {}
fur:each(function(x, y) local lx, ly = L(x, y)
  local k = K(x, y)
  if abs(lx) < 0.9 and ly > -17 and ly < 14 then bias[k] = -2                       -- parted spine
  elseif abs(lx) < 2.1 and ly > -17 and ly < 14 then bias[k] = 1 end               -- lit fur beside it
  if abs(lx) < 8 and abs(lx) >= 2.1 and ly > -10 and ly < 10 and floor(ly + 40) % 5 == 0 then bias[k] = (bias[k] or 0) - 1 end   -- bands
end)
local idx = A.shade(c, fur, n, FUR, { bias = bias, tok = tokF, amb = 0.1, wrap = 0.3 })
-- fur strands combed outward from the spine
fur:each(function(x, y)
  local lx, ly = L(x, y)
  if abs(lx) > 2.5 and X.hash(x, y, 13) < 0.2 then
    local sx = (lx > 0) and 1 or -1
    local i = idx[K(x, y)] or 3
    if fur:has(x + sx, y + 1) and idx[K(x + sx, y + 1)] then
      c:put(x, y, FUR[min(6, i + 1)], tokF)
      c:put(x + sx, y + 1, FUR[max(1, (idx[K(x + sx, y + 1)] or 3) - 1)], tokF)
    end
  end
end)

-- turned-up left hind flap: leather underside
local flapM = flap(-10, 11, -17, 16.5, 4.2, 2.2)
local inner = flapM:copy():clip(hindL)
local fb = {}
inner:each(function(x, y) local lx, ly = L(x, y) if lx > -12 then fb[K(x, y)] = -1 end end)   -- crease at the root
local fn = X.pillow(inner, 2)
local lidx = A.shade(c, inner, fn, LEA, { bias = fb, tok = tokL, amb = 0.2, wrap = 0.3, cuts = { 0.25, 0.45, 0.65, 0.85 } })
inner:each(function(x, y)                                           -- lit fold edge on top
  if not inner:has(x, y - 1) and (lidx[K(x, y)] or 3) >= 3 then c:put(x, y, LEA[5], tokL) end end)
inner:grow(1):cut(inner):each(function(x, y)                        -- AO on the fur where the flap lies
  if fur:has(x, y) and y > 0 and not hindL:has(x, y) then local i = idx[K(x, y)] or 3 c:put(x, y, FUR[max(1, i - 2)], tokF) end end)

-- quirk: tiny mushroom at the left shoulder edge (cap pokes past the silhouette)
local mx, my = W(-13.5, -4)
mx, my = floor(mx + .5) - 2, floor(my + .5) - 4
A.map(c, {
  ".dcb.",
  "dccba",
  "aaaaa",
  "..e..",
  "..e..",
}, mx, my, { d = MUSH[4], c = MUSH[3], b = MUSH[2], a = MUSH[1], e = "#efe2c4" }, tokF)
A.save(c, NAME)
