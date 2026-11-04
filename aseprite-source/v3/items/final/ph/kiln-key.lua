-- kiln-key (final, Opus single pass). A long blackened-iron key on the diagonal: round bevelled bow pierced by an
-- arched kiln-door hole (dark eye with a lit sill), a slim round shaft with a raised collar, and a stepped bit with
-- two teeth. Per-pixel bevel light (6-tone iron), bright upper-left edge, one specular streak down the shaft,
-- forge scale specks. A loop of twisted jute twine runs through the bow hole and hangs off it with a knot.
-- quirk: the bit is still glowing from the kiln (ember ramp heat at the teeth), with a curl of smoke rising.
local NAME = "kiln-key"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC14_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local IRON = { "#1f1d2c", "#33303f", "#4b4659", "#686277", "#8f8a9e", "#c4c0d0" }
local HOT  = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c", "#ffc070", "#ffe8a0" }
local JUTE = { "#5e3d26", "#8a5c34", "#b98a4e", "#dcb676", "#f2dca0" }
local SMOKE = { "#9a96aa", "#c6c2d2", "#e4e2ea" }
local SPEC = "#f4f2ff"

local F = A.frame(21, 21, pi / 4)        -- u: bow -> tip (lower right), v: across (+v = lower left)
local itok = { r = { name = "iron" } }

-- ---------------------------------------------------------------- masks (key-local)
local function hole(u, v)               -- kiln-door: flat sill toward the shaft, arched toward the top
  if u >= -1.0 and u <= 3.4 and abs(v) <= 3.4 then return true end
  return (u + 1.0)^2 + v * v <= 3.4^2
end
local bow = F.mask(function(u, v) return u * u + v * v <= 9.6^2 and not hole(u, v) end)
local holeM = F.mask(function(u, v) return hole(u, v) and u * u + v * v <= 9.6^2 end)
local shaft = F.mask(function(u, v) return u > 8.6 and u <= 36.5 and abs(v) <= 1.75 end)
local collar = F.mask(function(u, v) return u >= 11.5 and u <= 13.8 and abs(v) <= 3.0 end)
local tipM = F.mask(function(u, v) return (u - 36.2)^2 + v * v <= 2.6^2 end)
local function bitf(u, v)
  if v < 1.0 or u < 27.2 or u > 35.6 then return false end
  if v > 9.0 then return false end
  if v > 5.2 and u > 30.0 and u < 32.8 then return false end    -- gap between the two teeth
  if v > 7.2 and u < 29.4 then return false end                   -- stepped first tooth
  return true
end
local bit = F.mask(bitf)
local hot = F.mask(function(u, v) return bitf(u, v) and v > 5.0 end)

-- ---------------------------------------------------------------- normals
local nB = X.pillow(bow, 3.2)
-- shaft: round in v
local nS = {}
shaft:each(function(x, y) local u, v = F.uv(x, y) local s = max(-0.95, min(0.95, v / 2.2)) nS[K(x, y)] = F.n(0, s, sqrt(1 - s * s)) end)
local nC = {}
collar:each(function(x, y) local u, v = F.uv(x, y) local s = max(-0.95, min(0.95, v / 3.4)) local a = max(-0.6, min(0.6, (u - 12.65) / 1.8))
  nC[K(x, y)] = F.n(a, s, sqrt(max(0.05, 1 - s * s - a * a))) end)
local tx0, ty0 = F.xy(36.0, -0.3)
local nT = X.sphere(tx0, ty0, 3.0, tipM)
local nBit = X.pillow(bit, 1.6)

-- ---------------------------------------------------------------- twine behind the bow (back strand)
local jtok = { r = { name = "twine" } }
local function rope(pts, w, front)
  local m, n, T, S = A.tube(pts, function(t) return w end)
  local v = X.light(n, { amb = 0.15, wrap = 0.3 })
  local idx = X.tone(c, m, v, JUTE, { cuts = { 0.3, 0.5, 0.7, 0.88 }, tok = jtok })
  -- twist: diagonal dark grooves across the strand
  m:each(function(x, y) local k = K(x, y) local ph = (T[k] * 22 + S[k] * 1.1) % 1
    if ph < 0.25 then c:put(x, y, JUTE[max(1, idx[k] - 2)], jtok) end end)
  return m
end
-- back strand: from behind the bow out to the right, down to the knot
local backM = rope({ { 25, 17 }, { 33, 11 }, { 42, 13 }, { 44, 21 } }, 1.1)

-- ---------------------------------------------------------------- paint iron
local function iron(m, n, bias, cuts)
  return A.shade(c, m, n, IRON, { amb = 0.05, wrap = 0.2, tok = itok, bias = bias, cuts = cuts or { 0.24, 0.4, 0.56, 0.72, 0.88 } })
end
local sbias = {}
X.ao(sbias, shaft, collar, 1, -1) X.ao(sbias, shaft, bow, 2, -1)
iron(shaft, nS, sbias)
iron(tipM, nT)
local bbias = {}
X.ao(bbias, bit, shaft, 1, -1)
local bidx = iron(bit, nBit, bbias)
iron(collar, nC)
-- bow: dark eye rim on the hole edge (AO inside), bright upper-left outer edge
local bwb = {}
X.ao(bwb, bow, holeM, 1, -1)
local bidxB = iron(bow, nB, bwb)
-- forge scale specks
for _, m in ipairs{ bow, shaft } do
  m:copy():shrink(1):each(function(x, y) if X.hash(x, y, 21) > 0.93 then c:put(x, y, IRON[2], itok) end end)
end
-- specular streak down the lit side of the shaft (u 16..30, v = -1)
for u = 16, 30, 0.5 do local x, y = F.xy(u, -1.0) x, y = floor(x + .5), floor(y + .5)
  if shaft:has(x, y) and not collar:has(x, y) then c:put(x, y, (u > 19 and u < 25) and SPEC or IRON[6], itok) end end
-- bow specular (2x1) upper-left + sparkle
c:put(15, 15, SPEC, itok) c:put(16, 14, SPEC, itok) c:put(14, 16, IRON[6], itok)

-- ---------------------------------------------------------------- hot bit (quirk)
local htok = { r = { name = "heat" } }
local nH = X.pillow(hot, 1.4)
local hv = X.light(nH, { amb = 0.3, wrap = 0.4 })
hot:each(function(x, y) local k = K(x, y) local u, v = F.uv(x, y)
  local heat = (v - 5.0) / 3.6 + hv[k] * 0.4
  local i = max(1, min(6, floor(heat * 4.2) + 2))
  c:put(x, y, HOT[i], htok)
end)
-- heat bleeding into the iron just above the glow (dull red transition row)
bit:each(function(x, y) local u, v = F.uv(x, y) if v > 4.0 and v <= 5.0 then c:put(x, y, HOT[1], htok) end end)
-- smoke curl off the teeth
local smk = { { 32, 45, 1 }, { 31, 44, 2 }, { 31, 43, 2 }, { 32, 42, 3 }, { 32, 41, 3 }, { 31, 40, 2 }, { 30, 39, 2 }, { 30, 38, 1 }, { 31, 37, 1 } }

-- ---------------------------------------------------------------- twine front strand over the bow + knot + tails
local frontM = rope({ { 24, 21 }, { 25, 19 }, { 26, 18 }, { 27, 17 } }, 1.1)
-- contact shadow of the front strand on the bow
frontM:shift(1, 1):each(function(x, y) if bow:has(x, y) and not frontM:has(x, y) then c:put(x, y, IRON[1], itok) end end)
-- knot and two frayed tails hanging below the back strand
local knot = c:ellipse(44, 22, 2, 2)
A.shade(c, knot, X.sphere(43.6, 21.6, 2.2, knot), JUTE, { cuts = { 0.3, 0.5, 0.7, 0.88 }, tok = jtok })
c:put(44, 22, JUTE[1], jtok) c:put(43, 21, JUTE[5], jtok)
rope({ { 44, 24 }, { 45, 27 }, { 45, 30 }, { 46, 32 } }, 0.7)
rope({ { 45, 24 }, { 47, 26 }, { 49, 28 }, { 50, 31 } }, 0.7)
for _, q in ipairs{ { 46, 33, 3 }, { 45, 34, 2 }, { 50, 32, 3 }, { 51, 33, 2 } } do c:put(q[1], q[2], JUTE[q[3]], jtok) end

-- smoke: soft grey curl (not outlined as solid, but drawn as hard pixels with ink skipped by finish? keep: real pixels)
for _, q in ipairs(smk) do c:put(q[1], q[2], SMOKE[q[3]], { r = { name = "smoke" } }) end

A.save(c, NAME)
