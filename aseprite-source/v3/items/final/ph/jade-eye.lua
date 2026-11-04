-- jade-eye (final pass, Opus single pass). A carved jade eye amulet: a polished almond-shaped jade cabochon
-- (domed, 6-tone green with cloudy mottling, one bright specular streak), a carved eyelid groove (dark cut + lit lip)
-- framing a paler celadon "white", and an inset amber cat-eye iris (domed, slit pupil, glint). It hangs from a gold
-- bail (bevel, bright edge, dark eye hole) on a slim twisted red cord loop.
-- quirk: an old crack along the lower lid has been mended with a thin seam of gold (kintsugi).
local NAME = "jade-eye"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC13_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min, sin, cos, pi = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.cos, math.pi
local norm = A.norm
local c = A.new(NAME)
local JADE = { "#0f3a30", "#185440", "#22704c", "#34905a", "#5cb474", "#9edc9c" }
local PALE = { "#2e6a52", "#4a8a6a", "#6eaa84", "#96c89c", "#bfe2bc", "#e2f4d6" }
local AMB  = { "#5a2414", "#8f4a1f", "#c4741e", "#e8a12a", "#ffcf52", "#fff0a8" }
local GOLD = { "#5e3218", "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local CORD = { "#5a1830", "#8e2238", "#c4343c", "#ee6050" }

local CX, CY, W, HH = 32, 40, 23, 11.5
local function hh(x) local u = (x - CX) / (W + 0.5) return HH * (1 - u * u) ^ 1.1 end
-- jade body
local jm, jn = HP.mask(), {}
for y = CY - 14, CY + 14 do for x = CX - W - 1, CX + W + 1 do
  local h = hh(x)
  if abs(x - CX) <= W and abs(y + 0.5 - CY - 0.5) <= h then
    jm:set(x, y)
    local u, v = (x - CX) / (W + 0.5), (y - CY) / (h + 0.6)
    jn[K(x, y)] = { norm(u * 0.75, v * 0.95, sqrt(max(0.06, 1 - u * u * 0.7 - v * v * 0.85))) }
  end
end end
-- inner eye (carved): smaller almond
local IW, IH = 16, 7.2
local function ih(x) local u = (x - CX) / (IW + 0.5) return IH * max(0, 1 - u * u) ^ 1.05 end
local em = HP.mask()
jm:each(function(x, y) if abs(x - CX) <= IW and abs(y - CY) <= ih(x) then em:set(x, y) end end)
local groove = em:grow(1):cut(em)
-- tone the jade
local bias = {}
local jtok = { r = { name = "jade" } }
local v = X.light(jn, { amb = 0.1, wrap = 0.3 })
-- translucent cloudy mottle (low-frequency blobs)
jm:each(function(x, y) local k = K(x, y)
  local m1 = sin(x * 0.42 + y * 0.31) + sin(x * 0.17 - y * 0.55 + 1.3)
  if m1 > 1.35 then v[k] = v[k] + 0.12 elseif m1 < -1.45 then v[k] = v[k] - 0.1 end end)
local jidx = X.tone(c, jm, v, JADE, { cuts = { 0.16, 0.32, 0.5, 0.66, 0.84 }, tok = jtok })
-- groove: dark cut; lip just outside on the upper-left lit
groove:each(function(x, y) if jm:has(x, y) then c:put(x, y, JADE[1], jtok) end end)
local lip = groove:grow(1):cut(groove):cut(em)
lip:each(function(x, y) if jm:has(x, y) then local k = K(x, y)
  if y < CY and x < CX + 8 then c:put(x, y, JADE[min(6, (jidx[k] or 3) + 1)], jtok)
  elseif y > CY then c:put(x, y, JADE[max(1, (jidx[k] or 3) - 1)], jtok) end end end)
-- pale "white" of the eye: concave (lit from below-right inside the cut), AO under the upper lid
local en = {}
em:each(function(x, y) local u, vv = (x - CX) / (IW + 0.5), (y - CY) / (ih(x) + 0.5)
  en[K(x, y)] = { norm(-u * 0.25, -vv * 0.35 + 0.1, 1) } end)
local ebias = {}
em:each(function(x, y) if not em:has(x, y - 1) or not em:has(x, y - 2) then ebias[K(x, y)] = -1 end end)
local ptok = { r = { name = "pale" } }
A.shade(c, em, en, PALE, { tok = ptok, bias = ebias, cuts = { 0.2, 0.4, 0.58, 0.72, 0.86 }, amb = 0.25 })
-- iris: domed amber disc, slit pupil, darker limbal ring, radial streaks
local IR = 6.6
local im = HP.mask()
em:each(function(x, y) if (x - CX) ^ 2 + (y - CY + 0.3) ^ 2 <= (IR + 0.4) ^ 2 then im:set(x, y) end end)
local in_ = X.sphere(CX, CY - 0.3, IR, im)
local itok = { r = { name = "iris" } }
local ib = {}
im:each(function(x, y) if not em:has(x, y - 1) or not em:has(x, y - 2) then ib[K(x, y)] = -1 end end)
local iidx = A.shade(c, im, in_, AMB, { tok = itok, bias = ib, cuts = { 0.14, 0.3, 0.48, 0.64, 0.8 }, amb = 0.12 })
im:edge():each(function(x, y) c:put(x, y, AMB[max(1, (iidx[K(x, y)] or 3) - 2)], itok) end)
-- radial fibres
im:each(function(x, y) local dx, dy = x - CX, y - CY + 0.3 local r = sqrt(dx * dx + dy * dy)
  if r > 2.2 and r < IR - 1 then local a = math.atan(dy, dx)
    if (floor(a / (pi / 7) + 0.5)) % 2 == 0 and (floor(r) % 2 == 0) then
      local k = K(x, y) c:put(x, y, AMB[min(6, (iidx[k] or 3) + 1)], itok) end end end)
-- slit pupil
for y = CY - 5, CY + 5 do
  local w = (abs(y - CY) <= 2) and 1 or 0
  for x = CX - w, CX + (w > 0 and 0 or 0) do if im:has(x, y) then c:put(x, y, "#1c0f18", itok) end end
  if abs(y - CY) <= 3 and im:has(CX + 1, y) then c:put(CX + 1, y, AMB[1], itok) end
end
c:put(CX - 3, CY - 3, "#fff4d6", itok) c:put(CX - 2, CY - 3, AMB[6], itok) c:put(CX - 3, CY - 2, AMB[6], itok)
-- jade specular streak on the upper-left dome + one cream sparkle
for _, q in ipairs{ { -15, -6 }, { -14, -7 }, { -13, -7 }, { -12, -8 }, { -11, -8 } } do c:put(CX + q[1], CY + q[2], JADE[6], jtok) end
c:put(CX - 13, CY - 6, "#f4ffe8", jtok)
-- cool reflected light on the lower-right rim
local rim = X.rim(jn)
jm:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.55 and y > CY + 2 and x > CX - 6 then c:put(x, y, "#2f6a78", jtok) end end)
-- quirk: kintsugi seam along the lower jade, from the bottom edge up to the groove
local seam = { { 21, 50 }, { 22, 49 }, { 22, 48 }, { 23, 47 }, { 24, 47 }, { 25, 46 } }
for i, q in ipairs(seam) do c:put(q[1], q[2], i % 3 == 1 and GOLD[5] or GOLD[4], jtok) end
c:put(23, 48, GOLD[2], jtok) c:put(25, 47, GOLD[2], jtok)

-- gold bail (cap) on top of the jade
local bt = floor(CY - HH) -- top row of the jade
local bm = HP.mask()
for y = bt - 6, bt + 1 do for x = CX - 3, CX + 3 do
  local hw = (y <= bt - 4) and 2 or 3
  if abs(x - CX) <= hw then bm:set(x, y) end
end end
local bn = X.pillow(bm, 1.6)
local gtok = { r = { name = "gold" } }
local gidx = A.shade(c, bm, bn, GOLD, { tok = gtok, cuts = { 0.2, 0.42, 0.66, 0.86 } })
-- dark eye hole and bevel line
c:put(CX, bt - 4, GOLD[1], gtok) c:put(CX, bt - 5, GOLD[1], gtok)
for x = CX - 3, CX + 3 do if bm:has(x, bt - 3) then c:put(x, bt - 3, GOLD[2], gtok) end end
c:put(CX - 2, bt - 2, GOLD[5], gtok) c:put(CX - 2, bt - 1, GOLD[5], gtok)
-- contact shadow of the bail on the jade
for x = CX - 4, CX + 4 do if jm:has(x, bt + 2) and not bm:has(x, bt + 2) then c:put(x, bt + 2, JADE[2], jtok) end end
for x = CX - 3, CX + 3 do if jm:has(x, bt + 2) then c:put(x, bt + 2, JADE[2], jtok) end end

-- twisted cord loop above the bail
local LCX, LCY, RX, RY = CX, bt - 13, 7.5, 8.5
local ctok = { r = { name = "cord" } }
for y = LCY - 10, bt - 4 do for x = LCX - 10, LCX + 10 do
  local d = sqrt(((x - LCX) / RX) ^ 2 + ((y - LCY) / RY) ^ 2)
  if d >= 0.84 and d <= 1.0 and not bm:has(x, y) then
    local a = math.atan(y - LCY, x - LCX)
    local outer = d > 0.92
    local tw = floor((a + pi) * 9 / pi) % 2
    local lit = (x < LCX - 2 and y < LCY + 2) or (y < LCY - 6)
    local col = tw == 0 and (lit and CORD[4] or CORD[3]) or (outer and CORD[1] or CORD[2])
    c:put(x, y, col, ctok)
  end
end end
A.save(c, NAME)
