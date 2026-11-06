-- ico-log (final, Opus). A cut log lying on its side, sawn end turned toward the light (upper-left), the trunk
-- running back to a rounded far end. Slim: 21 px tall, 46 px long.
-- Material: per-pixel cylinder light on the bark (6 warm-brown tones, cool-violet underside), long bark fissures
-- (dark groove + lit lip) with a raised knot; the sawn end is pale end grain with off-centre growth rings, dark pith,
-- a radial drying crack and saw marks, inside a thin dark bark rim (AO where face meets bark). 2-tone ground shadow.
-- quirk: a tiny red toadstool has sprouted on the top of the bark.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA6_4.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, abs, floor, max, min, pi, cos, sin = math.sqrt, math.abs, math.floor, math.max, math.min, math.pi, math.cos, math.sin
local c = A.new("ico-log")
local BK = { "#2f1c24", "#4e2b27", "#6f3f2c", "#935a36", "#b67a48", "#d49f68" }
local EW = { "#8a5232", "#b0773f", "#cf9a5c", "#e6b97c", "#f4d49c", "#fff0c8" }
local tokB, tokE = { r = { name = "bark" } }, { r = { name = "end" } }
local CY, HW = 36, 10.5
local FX, FRX = 15, 7.2           -- sawn face centre x, half width
local EX = 51                     -- far end

c:groundShadow(31, 47, 23, 2)

-- bark
local bm = HP.mask()
local bn, BT = {}, {}
for y = floor(CY - HW) - 1, floor(CY + HW) + 1 do for x = FX, EX + 4 do
  local sy = (y + .5 - CY) / (HW + .3)
  local ex = x > EX - 2 and (x + .5 - EX + 2) / 5.6 or 0
  if sy * sy + ex * ex <= 1 then
    bm:set(x, y)
    local sn = max(-0.97, min(0.97, sy))
    local nx = ex * 0.9
    local nz = sqrt(max(0.03, 1 - sn * sn - nx * nx))
    local l = sqrt(nx * nx + sn * sn + nz * nz)
    bn[K(x, y)] = { nx / l, sn / l, nz / l }
  end
end end
local bias = {}
local bidx = A.shade(c, bm, bn, BK, { amb = 0.08, wrap = 0.2, bias = bias, cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 }, tok = tokB })
-- fissures: long wavy grooves following the cylinder, broken into plates
local fis = { -0.78, -0.5, -0.2, 0.1, 0.4, 0.68 }
for i, f in ipairs(fis) do
  for x = FX + 3, EX + 2 do
    local wav = sin(x * 0.45 + i * 1.7) * 0.06
    local y = floor(CY + (f + wav) * HW + .5)
    local gap = X.hash(floor((x + i * 5) / 7), i, 3) < 0.28
    if not gap and bm:has(x, y) and bm:has(x, y + 1) then
      A.step(c, bidx, BK, x, y, -2, tokB)
      if bm:has(x, y - 1) and f < 0.3 then A.step(c, bidx, BK, x, y - 1, 1, tokB) end
    end
  end
end
-- knot: raised oval with a dark eye
local km = A.ell(38.5, 40, 2.6, 1.6)
km:each(function(x, y) local k = K(x, y)
  local dx, dy = x + .5 - 38.5, y - 40
  c:put(x, y, (dx + dy < -0.5) and BK[5] or BK[3], tokB) end)
c:put(38, 40, BK[1], tokB) c:put(39, 40, BK[2], tokB)
km:grow(1):cut(km):each(function(x, y) if x + y > 79 then c:put(x, y, BK[2], tokB) end end)
-- warm lit streak along the top of the bark
for x = FX + 6, EX - 6 do if X.hash(x, 1, 9) > 0.35 then c:put(x, CY - 8, BK[6], tokB) end end

-- sawn face: dark bark rim, then pale end grain
local rim = A.ell(FX, CY, FRX, HW)
rim:each(function(x, y) c:put(x, y, BK[3], tokB) end)
rim:edge():each(function(x, y) if x + y < FX + CY then c:put(x, y, BK[4], tokB) else c:put(x, y, BK[2], tokB) end end)
local fm = A.ell(FX, CY, FRX - 1.2, HW - 1.3)
local fn = {}
local PX, PY = FX + 0.6, CY + 1.2       -- pith, a touch off centre
fm:each(function(x, y) local k = K(x, y)
  local dx, dy = (x + .5 - FX) / (FRX - 0.7), (y + .5 - CY) / (HW - 0.8)
  local q = sqrt(dx * dx + dy * dy)
  -- face plane points left-forward; slight dome so the rim edge darkens
  local nx, ny = -0.55 + dx * 0.25, dy * 0.25 - 0.1
  local nz = sqrt(max(0.05, 1 - nx * nx - ny * ny))
  fn[k] = { nx, ny, nz }
end)
local fbias = {}
local fidx = A.shade(c, fm, fn, EW, { amb = 0.1, wrap = 0.2, cuts = { 0.25, 0.42, 0.58, 0.74, 0.9 }, bias = fbias, tok = tokE })
-- growth rings (radius in the face's own ellipse frame, measured from the pith)
-- (clean 1 px ellipse outlines, nested around the pith, a few gaps so they read as grain not targets)
for i, f in ipairs{ 0.34, 0.6, 0.84 } do
  local ring = A.ell(PX - 0.2 * i, PY - 0.35 * i, (FRX - 1.2) * f, (HW - 1.3) * f)
  ring:edge():clip(fm):each(function(x, y)
    if X.hash(x, y, i) > 0.12 then A.step(c, fidx, EW, x, y, -2, tokE) end end)
end
-- heartwood + pith
A.ell(PX, PY, 1.3, 1.8):clip(fm):each(function(x, y) c:put(x, y, EW[2], tokE) end)
c:put(floor(PX), floor(PY), EW[1], tokE)
-- radial drying crack from the pith to the upper-right
for i = 1, 7 do local x, y = floor(PX + i * 0.55 + .5), floor(PY - i * 1.05 + .5)
  if fm:has(x, y) then c:put(x, y, BK[2], tokE) if fm:has(x - 1, y) and i < 4 then c:put(x - 1, y, EW[2], tokE) end end end
-- bright saw-cut edge on the lit upper-left of the face + one glint
fm:edge():each(function(x, y) if (x + .5 - FX) * 0.7 + (y + .5 - CY) * 0.45 < -4.5 then c:put(x, y, EW[6], tokE) end end)
c:put(11, 30, "#fffbe8", tokE)
-- AO where face meets bark on the right (bark side just behind the rim)
rim:grow(1):cut(rim):each(function(x, y) if bm:has(x, y) and x > FX then A.step(c, bidx, BK, x, y, -1, tokB) end end)

-- quirk: tiny red toadstool on top of the bark
local map = {
  "..rRRr..",
  ".rRcRRr.",
  "rRhRRcRd",
  "dddddddd",
  "...sS...",
  "...sS...",
  "..gsSg..",
}
A.map(c, map, 37, 20, { r = "#b52e3f", R = "#e8493b", h = "#ff8a5c", c = "#fff4d6", d = "#6e2038",
  s = "#f2e2c0", S = "#c9ad8c", g = "#5aa04f" })
A.save(c, "ico-log")
